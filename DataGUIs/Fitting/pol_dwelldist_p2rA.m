function out = pol_dwelldist_p2rA(p1tr, inOpts)
%First rulerAlign, then fit staircase with [~, ~, p1tr] = pol_dwelldist_p1, then go here

%Do per-bp dwelldist fitting, and plot as a function of bp
% To plot, x-axis is position, y is value, color is nth mode

opts.Fs = 1e3;
opts.minpts = 20; %Minimum pts to fit for

%Repeats options
opts.per = 64;
opts.nrep = 8;

%Exp fitting options
opts.fit.n = 8; %Max exps to fit
opts.fit.xrange = [.01 10];
opts.fit.xrangefit = [0 inf];
opts.fit.prcmax = 99.9;
opts.fit.verbose = 0; %Dont plot

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Extract means and dwells
[in, me] = cellfun(@tra2ind, p1tr, 'Un', 0);
dw = cellfun(@diff , in , 'Un', 0);
dw = [dw{:}]/opts.Fs;
me = [me{:}];

%Assign sections
pre = min(me):0;
rpt = 1:opts.per*opts.nrep;
pos = rpt(end)+1:max(me);

%Collapse repeat section onto itself
xx = [pre rpt(1:opts.per) pos]; %Remove repeat copies
me( me >= 1 & me <= opts.per*opts.nrep ) = mod( me( me >= 1 & me <= opts.per*opts.nrep )-1 , opts.per) + 1;
len = length(xx);

%Sort dwells by position
dwsort = cell(1,len);
out = cell(1,len);
outci = cell(1,len);
for i = 1:len
    %Get the dwells as this loc
    dwsort{i} = dw( me == xx(i) );
    %Fit to nexp
    if length(dwsort{i}) >= opts.minpts
        [t, tr] = fitnexp_hybridV2(dwsort{i}, opts.fit);
        %Sort in descending k order
        ks = t(2:2:end);
        [~, si] = sort(ks, 'descend');
        ki = [si*2-1; si*2];
        ki = ki(:)';
        %Extract CI
        nopt = length(t)/2;
        out{i} = t(ki);
        outci{i} = tr.mfcis{nopt}(ki);
        
        
    else
        out{i} = nan(1,2);
        outci{i} = nan(1,2);
    end
end

%Plot

%Make xx continuous for plotting
xx = [pre rpt(1:opts.per) pos-pos(1)+rpt(opts.per)+1];
%For ease, pad the values and transform into matrix
maxlen = max(cellfun(@length, out));
op = cellfun(@(x) [x nan(1,maxlen-length(x))]', out, 'Un' , 0);
op = [op{:}]'; %Each col = a1, k1, etc.
oc = cellfun(@(x) [x nan(1, maxlen-length(x))]', outci, 'Un', 0);
oc = [oc{:}]';

%Normalize a's
op(:, 1:2:end) = bsxfun(@rdivide, op(:, 1:2:end) , sum(op(:, 1:2:end), 2, 'omitnan'));

figure Name k
axk = gca; hold on
figure Name a
axa = gca; hold on
for i = 1:maxlen/2
    %Plot a's
    plot(axa, xx, op(:, (i-1)*2+1) , 'o')
%     errorbar(axa, xx, op(:, (i-1)*2+1) , oc(:,(i-1)*2+1), 'o', 'LineStyle', 'none')
    
    %Plot k's
    plot(axk, xx, op(:, (i-1)*2+2) , 'o')
%     errorbar(axk, xx, op(:, (i-1)*2+2) , oc(:,(i-1)*2+2), 'o', 'LineStyle', 'none')
    
end
j=0;


%Ugh have to fix the errorbar widths ... maybe not errorbar for now


