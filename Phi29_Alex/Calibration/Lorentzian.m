function outP = Lorentzian(inParams, inF, inOpts)
%Params = [fc D al f3] (see paper)

fc = inParams(1);
D  = inParams(2);
al = inParams(3);
f3 = inParams(4);
if isfield(inOpts, 'lortype')
    lortype = inOpts.lortype;
else
    lortype = 3;
end

Fs = inOpts.Fs;
nAlias = inOpts.nAlias;

inFF = bsxfun(@plus, inF, Fs*(-nAlias:nAlias)');
switch lortype
    case 2
        %Lorentzian with one filter
        outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (1 ./ (1+ (inFF/f3).^2)) );
    case 3
        %Lorentzian with filtered delayed response (usual)
        outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (al^2 + (1-al^2) ./ (1+ (inFF/f3).^2)) );
    case 4
        %Lorentzian with two filters
        outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (1 ./ (1+ (inFF/f3).^2)) .* (1 ./ (1+ (inFF/al).^2)) );
    otherwise
        %Unaltered Lorentzian
        outP = sum( D/2/pi^2./(fc^2+inFF.^2));
end