function [ext, bdef] = TetherSim(inOpts)
%Given trap params, outputs the tether extension

opts.trapsep = 1400; %nm, traps - bead diameters

opts.tcontour = 4000*.34; %nm

opts.trapk = 0.5; %pN/nm

opts.xwlcparams = {50 700}; %PL SM

opts.verbose = 1;

if nargin
    opts = handleOpts(opts, inOpts);
end

%use lsqnonlin to find equilibrium xwlc param
%want tether length = trapsep-beaddiam-2*x = XWLC(kx, XWLCparams{:}) * contour length
fitfcn = @(x) opts.trapsep - 2 * x - XWLC(opts.trapk * x, opts.xwlcparams{:}) * opts.tcontour;
lsqopts = optimoptions('lsqnonlin');
lsqopts.Display = 'none';
bdef = lsqnonlin(fitfcn, 1, [], [], lsqopts);
ext = opts.trapsep - 2 * bdef;
if opts.verbose
    fprintf('Bead deflection %0.2fnm, tether extension %0.2fnm, force %0.2fpN', bdef, ext, opts.trapk * bdef);
end






