function [ft, plotdata] = fitPFFDV2(inx, iny, frng, fmid)
%Fit each trace separately
% V2: Adapted from fitNuc, takes full pulling data
% Changed ft to 1x6, might error in some fcns

if nargin < 3 || isempty(frng)
    frng = [1.5 50]; %Fmin, Fmax -- actually not used
else
    warning('force fit range not implemented, oops')
end
if nargin < 4 || isempty(fmid)
    fmid = 4; %For better rip detection, ignore this part before WLC + stepfinding
end

%Grab data
ext = double( inx );
frc = double( iny );

%Crop frng


%Crop around LF
i1 = find(frc > fmid, 1, 'first');

%Find HF in i1:end. Let's assume it's a single point = make sure fil is large enough

[~, mi] = max(diff( ext(i1:end) ) );
% Crop out a pt on each side of this diff, too
irip = (i1+mi-2);

%Crop data
xx = {ext(1:irip) ext(irip+4:end)};
ff = {frc(1:irip) frc(irip+4:end)};
sz = cellfun(@length, xx);

th1 = [zeros(1, sz(1))  ones(1, sz(2))];
% th2 = [zeros(1, sz(1)) zeros(1, sz(2))];

%Create fitfcn
fitfcn = @(x0, x) XWLC(x-x0(6), x0(1),x0(2)).*x0(3) + th1 .* XWLC(x-x0(6), x0(4),inf) * x0(5);
xg = [50 700 ext(fmid) .5 30   0]; %PL (nm), SM (pN), CL (nm), PL(protein) CL(protein) dF
lb = [0     0    0     .4  0  -2];
ub = [100 1e4  3e3     .8 1e3  0];
opop = optimoptions('lsqcurvefit', 'Display', 'none');
%Fit
ft = lsqcurvefit(fitfcn, xg, [ff{:}], [xx{:}], lb, ub, opop);

%Hacky output plot data
if nargout > 1
    plotdata = [ fitfcn(ft,[ff{:}])' [ff{:}]' ];
end
