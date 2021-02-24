function out = pol_dwelldist(data, inOpts)

%% CHANGING INPUTS
%Input is a group of fit staircases (raw output of fitVitterbi_batch)
%If the input is a struct of these, it will handle them as cells

%For each struct in dwstruct...
%Started as AnalyzeAAP

%For each fieldname in dwstruct, do exp fitting and kn comparisons and save figs

%Because of artifacts(?) , short fitting is a bit wonk, leading to fitting of additional very fast decays.
% Maybe try limiting decay spds / further cropping short times?
   % Handling now as : rates >>100, ignore; rates similar to the 'major' , add their populations (e.g. a 40/s, 20% + 20/s, 60% = 20/s, 80%)

%If it's not a struct, make it one
if ~isstruct(data)
    data = struct('data', data);
end

%Data options
opts.Fs = 4000/3; %For converting pts to time
opts.roi = [-inf inf]; %Steps of interest: Useful for e.g. aligning region vs. ROI
%Fitting options
opts.xrng = [2e-3 inf]; %Crop some of the shorter dwells, because fitting is wonk
opts.nmax = 10; %max exponentials to fit


if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Convert staircases to ind, mea
[dws, mes] = structfun(@(x) tra2ind(x), data, 'Un', 0);
%Convert to dwells
dws = structfun(@(x) diff(x) / opts.Fs, dws, 'Un', 0);
%Apply roi
dws = structfun(@(x,y) x(y>=opts.roi(1) & y <= opts.roi(2)), dws, mes, 'Un', 0);

%Prep for loop
fn = fieldnames(dws);
len = length(fn);
out = cell(1,len);

for i = len:-1:1
    %Get fieldname
    f = fn{i};
    dw = dws.(f);
    
    %Fit each trace separately
    [o, or] = cellfun(@(x) fitnexp_cfit(x( x > opts.xrng(1) & x < opts.xrng(2) ), opts.nmax, 0), dw, 'Un', 0);

    %Fit together
    dwa = [dw{:}];
    [oa, ora] = fitnexp_cfit(dwa( dwa > opts.xrng(1) & dwa < opts.xrng(2) ), opts.nmax);
    set(gcf, 'Name', f);
    
    %% From curvefit output, use this as a guess for mle
    
    %Save results in out
    res = [];
    res.fit = oa;
    res.fitraw = ora;
    res.sfit = o;
    res.sfitraw = or;
    res.name = f;
    out{i} = res;
end

