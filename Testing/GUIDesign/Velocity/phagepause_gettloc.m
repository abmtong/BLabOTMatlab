function [out, outf, outuf] = phagepause_gettloc(data, fdata, inOpts)
%Takes in data, and determines whether the phage is paused, translocating, or backtracking at a given pt
%Generates stats on backtrack segments
%Based on Ronen's polymerase pausing code

if nargin < 2 || isempty(fdata)
    fdata = cellfun(@(x) 0 * x, data, 'uni', 0);
end

%verbose flags
opts.verbose.vdist = 1;
opts.verbose.traces = 1;
opts.verbose.output = 1;

%vdist opts
opts.sgf = {1 401};
opts.vbinsz = 2;
opts.Fs = 2500;

%phagepause opts
%ispaused threshold
%zero peak velocity thresh.
%bt minpts
%bt minsz

if nargin >= 3
    opts = handleOpts(opts, inOpts);
end

%Filter the inputs
[p, x, dvel, dfil, dcrop] = vdist(data, opts);
[~, ~, ~, ffil, ~] = vdist(fdata, opts);

%Fit vel pdf to two gaussians [fiddle with sgf filter width to make the peaks nice)
% Peaks are the paused and translocating sections
npdf = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3);
bigauss = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3) + normpdf(y, x0(4), x0(5))*x0(6) ;
xg = [0 20 .4 -80 30 .5];
lb = [0 0 0 -300 0 0];
ub = [0 inf 1 0 inf 1];

% %fit to three gaussians
% bigauss = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3) + normpdf(y, x0(4), x0(5))*x0(6) + normpdf(y, x0(7), x0(8))*x0(9);
% xg = [0 20 .4 -80 30 .5 30 20 .1];
% lb = [0 0 0 -300 0 0 0 0 0];
% ub = [0 inf 1 0 inf 1 inf inf 1];

%Fit using @lsqcurvefit
lsqopts = optimoptions('lsqcurvefit');
lsqopts.Display = 'none';
fit = lsqcurvefit(bigauss, xg, x, p, lb, ub, lsqopts);
fp = bigauss(fit, x);


%Fit just the 0 peak
dv = 10;
inds = find(x == -dv):find(x==dv);
fit2 = lsqcurvefit(npdf, [0 30 0.3], x(inds), p(inds),[], [], lsqopts);
% %Consider fitting the second peak only after the zero peak is fit (worse)
% fit3 = lsqcurvefit(npdf, [-100 20 .6], x, p-npdf(fit2, x));

%Plot the velocity distribution and fits
if opts.verbose.vdist
    figure, plot(x, p), hold on, plot(x, fp), plot(x, npdf(fit(1:3),x)), plot(x, npdf(fit(4:6),x)), %plot(x, npdf(fit(7:9),x))
    plot(x, npdf(fit2, x))
    %put text at peak locations
    text(fit(1), npdf(fit(1:3), fit(1)), sprintf('Mean %0.2f, SD %0.2f, Proportion %0.2f', fit(1:3)))
    text(fit(4), npdf(fit(4:6), fit(4)), sprintf('Mean %0.2f, SD %0.2f, Proportion %0.2f', fit(4:6)))
    text(fit2(1), npdf(fit2, fit2(1)), sprintf('Mean %0.2f, SD %0.2f, Proportion %0.2f', fit2))
end
% figure, plot(x, p), hold on, plot(x, npdf(fit2, x)), 

%just use fitting of center gaussian
fp = npdf(fit2, x);

%so take the tail and compare it to the rest
fpp=fp./p;
% figure, plot(x, fpp)
% xlim([0 inf])
pthr = 0.6;
vthri = find( x > 0 & fpp < pthr, 1, 'first');
vthr = x (vthri);
% vthr = 40;
isbt = cellfun(@(x) x > vthr, dvel, 'uni', 0);

%take the translocation peak and compare it to the rest
%lsqcurvefit might switch the two peaks, make sure it's the leftmost peak
ind = 1 + 3 * (fit(1)<fit(4));
tlg = normpdf(x, fit(ind), fit(ind+1))*fit(ind+2);
tlgp = tlg ./ p;
% figure, plot(x, tlgp)
pthr = 0.6;
vthrp = find( x < 0 & tlgp > pthr, 1, 'last');
vthrp = x(vthrp);
% vthrp = -40;
istl = cellfun(@(x) x < vthrp, dvel, 'uni', 0);

%Plot traces colored by state (translocating vs. paused vs. backtracked
if opts.verbose.traces
    isbtp = double([isbt{:}]) - double([istl{:}]);
    dfilp = [dfil{:}];
    % dcropp = [dcrop{:}];
    figure, %plot(dcropp,'Color', [.7 .7 .7]), hold on
    surface([1:length(dfilp);1:length(isbtp)],[dfilp;dfilp],zeros(2,length(dfilp)),[isbtp;isbtp] ,'edgecol', 'interp')
end

fprintf('Velocity threshs %0.2f %0.2f\n', vthr, vthrp)

%get stats on tloc runs
len=length(dcrop);
out = cell(1,len);
outf = cell(1,len);
outuf = cell(1,len);
for i = 1:len
    if isempty(isbt{i})
        continue
    end
    %start of tloc is istl 0 -> 1
    indSta = find(diff(istl{i}) == 1);
    %end of tloc is istl 1 -> 0
    indEnds = [find(diff(istl{i}) == -1) length(isbt{i})];
    
    if istl{i}(1) == 1
        indSta = [1 indSta]; %#ok<AGROW>
    end
    
    %find the closest end bit after each start bit
    indEnd = arrayfun(@(x) indEnds(find ( indEnds > x ,1,'first')), indSta);
    
    if isempty(indSta)
        continue
    end
    
    %join tl events that are separated very small in time & remove overlapping ones (just rm overlap if minpts = 0
    minpts = 200; %minimum pts
    keepind =indEnd(1:end-1) + minpts < indSta(2:end);
    indSta = indSta([true keepind]);
    indEnd = indEnd([keepind true]);
    
%     %ignore backtracks that are very small
%     minsz = 000;
%     keepind = (indEnd - indSta) > minsz;
%     indSta = indSta(keepind);
%     indEnd = indEnd(keepind);
    
    %gather these bits
    hei = length(indSta);
    tmp = cell(1,hei);
    tmpf = cell(1,hei);
    tmpuf = cell(1,hei);
    for j = 1:hei
        tmp{j} = dfil{i}(indSta(j):indEnd(j));
        tmpf{j} = ffil{i}(indSta(j):indEnd(j));
        tmpuf{j} = dcrop{i}(indSta(j):indEnd(j));
    end
    out{i} = tmp;
    outf{i} = tmpf;
    outuf{i} = tmpuf;
    
    %plot every 10th for debug
    if 0 %~mod(i,10)
        figure, plot(dfil{i}), hold on
        isbttl = double([isbt{i}]) - double([istl{i}]);
        surface([1:length(isbttl);1:length(isbttl)],[dfil{i};dfil{i}],zeros(2,length(isbttl)),[isbttl;isbttl] ,'edgecol', 'interp')

        yl = get(gca, 'YLim');
        for j=1:length(tmp)
            %draw blue lines for starts, green lines for ends
            line(indSta(j) * [1 1], yl)
            line(indEnd(j) * [1 1], yl, 'Color', 'g')
        end
    end
end

return %for now, just need the cropped bits for PWD-ing

%get stats on these bits
tmp = [out{:}];
tmpf = [outf{:}];

len = length(tmp);
bts = zeros(4,len); %dt dc vel f0
for i = 1:len
    xt = tmp{i};
    bts(:,i) = [ length(xt) / 2500, max(xt)-min(xt), 0, tmpf{i}(1) ];
end

bts(3,:) = bts(2,:) ./ bts(1,:);

% figure, plot( mean(bts(3,:)) )
%bin by force

figure, scatter(bts(2,:),bts(4,:))

fbins = [5 15 25 35];

%plot ccdfs
bbd = arrayfun(@(z,zz) bts(:,bts(4,:)>z & bts(4,:)< zz), fbins(1:end-1), fbins(2:end), 'Uni', 0);
szs = cellfun(@(x)size(x,2),bbd, 'uni', 0);
figure, subplot(3,1,1), hold on, cellfun(@(x,y) plot(sort(x(1,:)), (1:y)/y), bbd, szs)
subplot(3,1,2), hold on, cellfun(@(x,y) plot(sort(x(2,:)), (1:y)/y), bbd, szs)
subplot(3,1,3), hold on, cellfun(@(x,y) plot(sort(x(3,:)), (1:y)/y), bbd, szs)

bts2 = arrayfun(@(z,zz) mean(bts(:,bts(4,:)>z & bts(4,:)< zz),2), fbins(1:end-1), fbins(2:end), 'Uni', 0);
bts2=[bts2{:}];
btv2 = arrayfun(@(z,zz) std(bts(:,bts(4,:)>z & bts(4,:)< zz),[],2), fbins(1:end-1), fbins(2:end), 'Uni', 0);
btv2 = [btv2{:}];
ste = @(x) std(x,[],2)/sqrt(size(x,2));
bte2 = arrayfun(@(z,zz) ste(bts(:,bts(4,:)>z & bts(4,:)< zz)), fbins(1:end-1), fbins(2:end), 'Uni', 0);
bte2 = [bte2{:}];


mad = @(x) median(abs(bsxfun(@plus, median(x,2),-x)),2) /.67449 ;
made = @(x) median(abs(bsxfun(@plus, median(x,2),-x)),2) /.67449 /sqrt(size(x,2));
btm2 = arrayfun(@(z,zz) median(bts(:,bts(4,:)>z & bts(4,:)< zz),2), fbins(1:end-1), fbins(2:end), 'Uni', 0);
btml2 = arrayfun(@(z,zz) mad(bts(:,bts(4,:)>z & bts(4,:)< zz)), fbins(1:end-1), fbins(2:end), 'Uni', 0);
btme2 = arrayfun(@(z,zz) made(bts(:,bts(4,:)>z & bts(4,:)< zz)), fbins(1:end-1), fbins(2:end), 'Uni', 0);
btm2=[btm2{:}];
btml2=[btml2{:}];
btme2=[btme2{:}];

figure, subplot(3,1,1), errorbar(bts2(1,:), btv2(1,:)), hold on,  errorbar(bts2(1,:), bte2(1,:))
subplot(3,1,2), errorbar(bts2(2,:), btv2(2,:)), hold on,  errorbar(bts2(2,:), bte2(2,:))
subplot(3,1,3), errorbar(bts2(3,:), btv2(3,:)), hold on,  errorbar(bts2(3,:), bte2(3,:))

%median-based calcs
% figure, subplot(3,1,1), errorbar(btm2(1,:), btml2(1,:)), hold on,  errorbar(btm2(1,:), btme2(1,:))
% subplot(3,1,2), errorbar(btm2(2,:), btml2(2,:)), hold on,  errorbar(btm2(2,:), btme2(2,:))
% subplot(3,1,3), errorbar(btm2(3,:), btml2(3,:)), hold on,  errorbar(btm2(3,:), btme2(3,:))


%n events per bp
df = dfil(~cellfun(@isempty, dfil));
sumbp = cellfun(@(x)x(1)-min(x), df);
sumbp = sum(sumbp);

fprintf( '%0.2f events per kb\n' , 1000 * sum([szs{:}]) / sumbp);






