function [frc, ext] = TetherSim_double(inOpts)
%Given trap params, outputs the tether extension
%Has another tether of constant size

opts.ext1 = 1200; %nm, tether extensions
opts.ext2 = 1600;
opts.dext = 1;

opts.tcontour1 = 4000*.34; %nm
opts.tcontour2 = 4400 * .34;
opts.ssz = 1;

opts.xwlcparams = {40 700}; %PL SM

opts.verbose = 1;

if nargin
    opts = handleOpts(opts, inOpts);
end

%we need to go from ext to f, so make a lookup table
xf = 1e-3:1e-3:1e3;
xxpl = XWLC(xf, opts.xwlcparams{:});
x1 =  opts.tcontour1 * xxpl;
x2 =  opts.tcontour2 * xxpl;

ext = opts.ext1:opts.dext:opts.ext2;
len = length(ext);
frc = zeros(1,len);
for i = 1:len
    frc(i) = xf(find(x1>ext(i), 1, 'first')) + xf(find(x2>ext(i), 1, 'first'));
end

if opts.verbose
    figure, plot(ext, frc);
end




