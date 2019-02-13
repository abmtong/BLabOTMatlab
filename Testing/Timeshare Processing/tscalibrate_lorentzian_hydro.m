function outP = tscalibrate_lorentzian_hydro(inParams, inF, inOpts)
%Params = [fc D al f3] (see paper)

fc = inParams(1);
D  = inParams(2);
fv = inParams(3);
fm = inParams(4);

Fs = inOpts.Fs;
nAlias = inOpts.nAlias;

inFF = bsxfun(@plus, inF, Fs*(0:2*nAlias)');

inFF = abs(inFF);% Aliasing goes over +- n*Fsamp, so abs here -> double power?
% outP = sum( D/2/pi^2./(fc^2+inFF.^2));
% outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (al^2 + (1-al^2) ./ (1+ (inFF/f3).^2)) );
%Assumes R/l (radius / distance to surface) is very small, so Fv terms are simple
regg = 1 + sqrt(inFF/fv);
imgg = -sqrt(inFF/fv);
outP = sum( 2*D/2/pi^2*regg./( (fc + inFF.*imgg - inFF.^2/fm).^2 + (inFF .* regg).^2 ) );