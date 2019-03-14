function [out, outf] = phagepause(data, sgf, fdata)
if nargin < 3
    fdata = cellfun(@(x) 0 * x, data, 'uni', 0);
end
[p, x, dvel, dfil, dcrop] = vdist(data, sgf);
[~, ~, ~, ffil, ~] = vdist(fdata, sgf);
xbinsz = 2;

p = p / sum(p) / xbinsz;

%fit to two gaussians [fiddle with sgf filter width to make the peaks nice)
npdf = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3);
bigauss = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3) + normpdf(y, x0(4), x0(5))*x0(6) ;
xg = [0 20 .4 -80 30 .5];
lb = [0 0 0 -300 0 0];
ub = [0 inf 1 0 inf 1];

% bigauss = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3) + normpdf(y, x0(4), x0(5))*x0(6) + normpdf(y, x0(7), x0(8))*x0(9);
% xg = [0 20 .4 -80 30 .5 30 20 .1];
% lb = [0 0 0 -300 0 0 0 0 0];
% ub = [0 inf 1 0 inf 1 inf inf 1];



opts = optimoptions('lsqcurvefit');
opts.Display = 'none';
fit = lsqcurvefit(bigauss, xg, x, p, lb, ub, opts);
fp = bigauss(fit, x);


% consider just fitting the 0 peak first, to make sure it's of proper height
dv = 10;
inds = find(x == -dv):find(x==dv);
fit2 = lsqcurvefit(npdf, [0 30 0.3], x(inds), p(inds),[], [], opts);
% fit3 = lsqcurvefit(npdf, [-100 20 .6], x, p-npdf(fit2, x));

%plot
figure, plot(x, p), hold on, plot(x, fp), plot(x, npdf(fit(1:3),x)), plot(x, npdf(fit(4:6),x)), %plot(x, npdf(fit(7:9),x))
plot(x, npdf(fit2, x))
%put text at peak locations
text(fit(1), npdf(fit(1:3), fit(1)), sprintf('Mean %0.2f, SD %0.2f, Proportion %0.2f', fit(1:3)))
text(fit(4), npdf(fit(4:6), fit(4)), sprintf('Mean %0.2f, SD %0.2f, Proportion %0.2f', fit(4:6)))
text(fit2(1), npdf(fit2, fit2(1)), sprintf('Mean %0.2f, SD %0.2f, Proportion %0.2f', fit2))

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
if fit(1) < fit(4)
    ind = 1;
else
    ind = 4;
end %could do like ind = 1 + 3 * fit(1)<fit(4) but lol
tlg = normpdf(x, fit(ind), fit(ind+1))*fit(ind+2);
tlgp = tlg ./ p;
% figure, plot(x, tlgp)
pthr = 0.6;
vthrp = find( x < 0 & tlgp > pthr, 1, 'last');
vthrp = x(vthrp);
% vthrp = -40;
istl = cellfun(@(x) x < vthrp, dvel, 'uni', 0);

%plot them all
isbtp = double([isbt{:}]) - double([istl{:}]);
dfilp = [dfil{:}];
dcropp = [dcrop{:}];
figure, %plot(dcropp,'Color', [.7 .7 .7]), hold on
surface([1:length(dfilp);1:length(isbtp)],[dfilp;dfilp],zeros(2,length(dfilp)),[isbtp;isbtp] ,'edgecol', 'interp')

fprintf('Velocity threshs %0.2f %0.2f\n', vthr, vthrp)

%get stats on bt runs
len=length(dcrop);
out = cell(1,len);
outf = cell(1,len);
for i = 1:len
    if isempty(isbt{i})
        continue
    end
    %start of backtracks is isbt 0 -> 1
    indSta = find(diff(isbt{i}) == 1);
    %end of backtracks is istl 0 -> 1
    indEnds = [find(diff(istl{i}) == 1) length(isbt{i})];
    
    if isbt{i}(1) == 1
        indSta = [1 indSta];
    end
    
    %find the closest end bit after each start bit
    indEnd = arrayfun(@(x) indEnds(find ( indEnds > x ,1,'first')), indSta);
    
    if isempty(indSta)
        continue
    end
    %join backtracks that are separated very small in time & remove overlapping ones (just rm overlap if minpts = 0
    minpts = 200; %minimum pts
    keepind =indEnd(1:end-1) + minpts < indSta(2:end);
    indSta = indSta([true keepind]);
    indEnd = indEnd([keepind true]);
    
    %ignore backtracks that are very small
    minsz = 000;
    keepind = (indEnd - indSta) > minsz;
    indSta = indSta(keepind);
    indEnd = indEnd(keepind);
    
    %gather these bits
    hei = length(indSta);
    tmp = cell(1,hei);
    tmpf = cell(1,hei);
    for j = 1:hei
        tmp{j} = dfil{i}(indSta(j):indEnd(j));
        tmpf{j} = ffil{i}(indSta(j):indEnd(j));
    end
    out{i} = tmp;
    outf{i} = tmpf;
    
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


mle = @(x) median(abs(bsxfun(@plus, median(x,2),-x)),2) /.67449 ;
mlee = @(x) median(abs(bsxfun(@plus, median(x,2),-x)),2) /.67449 /sqrt(size(x,2));
btm2 = arrayfun(@(z,zz) median(bts(:,bts(4,:)>z & bts(4,:)< zz),2), fbins(1:end-1), fbins(2:end), 'Uni', 0);
btml2 = arrayfun(@(z,zz) mle(bts(:,bts(4,:)>z & bts(4,:)< zz)), fbins(1:end-1), fbins(2:end), 'Uni', 0);
btme2 = arrayfun(@(z,zz) mlee(bts(:,bts(4,:)>z & bts(4,:)< zz)), fbins(1:end-1), fbins(2:end), 'Uni', 0);
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






