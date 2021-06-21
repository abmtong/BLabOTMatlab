function out = fitRestarts(rs, inOpts)


opts.Fs = 4000/3;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end
%rs is a struct with fields {force, ind, islong} , output of getRestartByHand

%ASSUME that forces are close , i.e. run thus thru plotRestarts

%Time to restart ('dwells')
dws = cellfun(@diff, {rs.ind})/opts.Fs;
%Censoring (true = censored), see @mle
isl = [rs.islong];


%Make CCD

%Model to fit: cdf = 1 - c * exp(-kx): i.e. some will never restart, others 1exp
% Or fit as a biexp, and see if one k is very slow?
fitpdf = @(x, k, a) a + (1-a) * exp(-k*x); %is this the right way to do this? Or just fit cdf?
fitcdf = @(x, k, a) 1 - a * exp(-k*x);

lb = [0 0];
ub = [inf inf];

[ft fti] = mle(dws, 'cdf', fitcdf, 'Censoring', isl, 'LowerBound', lb, 'UpperBound', ub);

%mle(xdata, 'pdf', mcf.pdf, 'start', mlgu, 'LowerBound', mcf.lb, 'UpperBound', mcf.ub, 'Options', mleopts);