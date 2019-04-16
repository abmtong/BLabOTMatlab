function outP = Lorentzian(inParams, inF, inOpts)
%Params = [fc D al f3] (see paper)

fc = inParams(1);
D  = inParams(2);
al = inParams(3);
f3 = inParams(4);

Fs = inOpts.Fs;
nAlias = inOpts.nAlias;

inFF = bsxfun(@plus, inF, Fs*(-nAlias:nAlias)');
%Pure lorentzian
% outP = sum( D/2/pi^2./(fc^2+inFF.^2));
%Lorentzian with just filter 
% outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (1 ./ (1+ (inFF/f3).^2)) );
%Lorentzian with filtered delayed response (usual)
outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (al^2 + (1-al^2) ./ (1+ (inFF/f3).^2)) );