function outP = LorentzianB(inParams, inF, inOpts)
%Params = [fc D f3] (see paper)

fc = inParams(1);
D  = inParams(2);
f3 = inParams(3);

Fs = inOpts.Fs;
nAlias = inOpts.nAlias;

inFF = bsxfun(@plus, inF, Fs*(-nAlias:nAlias)');
outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (1 ./ (1+ (inFF/f3).^2)) );