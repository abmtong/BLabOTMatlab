function out = getDist(distName)
%Returns a struct 'out' with fields pdf, cdf, ccdf, and a comment about the parameters
% Returns mle (@(x,a,b,c,...)) parameterization
% Also absolute lower/upper bounds, if applicable

%Add ./Distributions
p = fileparts(mfilename('fullpath'));
addpath(fullfile(p, 'Distributions'));

%Some basic distributions, as shortcuts
exppdf = @(x,a,k) a * k * exp(-x*k);
expcdf = @(x,a,k) a * (1 - exp(-x*k));

%Check for string '%dexp'
ts = textscan(distName, '%dexp');
if ~isempty(ts{1})
    out = nexpdist(ts{1});
    return
end


switch distName
    case {1 'exp'}
        out.pdf = @(x0,x)exppdf(x, x0(1), x0(2));
        out.cdf = @(x0,x)expcdf(x, x0(1), x0(2));
        out.lb = [0 0];
        out.ub = [1 inf];
        out.cmt = 'Single exponential, height x0(1) and rate x0(2)';
    case {2 'biexp'}
        out.mlepdf = @(x,a1,k1,a2,k2) exppdf(x,a1,k1) + exppdf(x,a2,k2);
        out.mlecdf = @(x,a1,k1,a2,k2) expcdf(x,a1,k1) + expcdf(x,a2,k2);
        out.fitpdf = @(x0,x)exppdf(x, x0(1), x0(2));
        out.fitcdf = @(x0,x)expcdf(x, x0(1), x0(2));
        out.lb = [0 0];
        out.ub = [1 inf];
        out.cmt = 'Single exponential, height x0(1) and rate x0(2)';
end