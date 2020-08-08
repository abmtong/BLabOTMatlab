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
    case 2 %Lorentzian with one filter
        outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (1 ./ (1+ (inFF/f3).^2)) );
    case 3 %Lorentzian with filtered delayed response (used in HiRes)
        outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (al^2 + (1-al^2) ./ (1+ (inFF/f3).^2)) );
    case 4 %Lorentzian with two filters
        outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (1 ./ (1+ (inFF/f3).^2)) .* (1 ./ (1+ (inFF/al).^2)) );
    case 5 %Lorentzian with filtered delayed response with two diffusion modes
        % Case 3 is only with one diffusion mode, see doi:10.1063/1.2204589
        % Extra params for new diffusion modes
        f0 = f3;
        g0 = inParams(5);
        f1 = inParams(6);
        g1 = inParams(7);
        c = (g1 + g0)^-1;
        outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (al^2 + (1-al)^2 * c^2 .* ( g0^2 ./ (1+ (inFF/f0).^2) + g1^2 ./ (1+ (inFF/f1).^2) + 2 * g0 * g1 * (1+ (inFF.^2/f0/f1)) ./ (1+ (inFF/f1).^2) ./ (1+ (inFF/f0).^2) ) ...
            + 2 * al * (1-al) * c * ( g0 ./ (1+ (inFF/f0).^2) + g1 ./ (1+ (inFF/f1).^2) ) ) );
    case 6 %Lorentzian with filtered delayed response with n diffusion modes
        %need n f's and g's appended after al
        %Extra params for new diffusion modes
        fg = inParams(4:end);
        fg = reshape(fg, 2, []);
        f = fg(1,:);
        g = fg(2,:);
        c = 1/sum(g);
        p1 = D/2/pi^2./(fc^2+inFF.^2);
        p2 = al^2;
        p3 = zeros(size(inFF));
        for i = 1:length(f)
            p3 = p3 + ga(i)^2 ./ (1 + (inFF/f(i)) .^2);
        end
        p3b = zeros(size(inFF));
        for i = 1:length(f)
            for j = 1:i-1
                p3b = p3b + 2 * g(j) * g(i) * (1+ (inFF.^2/f(i)/f(j))) ./ (1+ (inFF/f(i)).^2) ./ (1+ (inFF/f(j)).^2);
            end
        end
        p3 = (1-al)^2*c^2 * (p3 + p3b);
        p4 = zeros(size(inFF));
        for i = 1:length(f)
            p4 = p4 + g(i) ./ (1+ (inFF/f(i)).^2);
        end
        p4 = 2*al*(1-al)*c *p4;
        outP = sum(p1 + p2 + p3 + p4);
    case 7 %Lorentzian #3 + 1/f noise
        %Extra params: inverse F noise
        finv = inParams(5);
        outP = sum( D/2/pi^2./(fc^2+inFF.^2) .* (al^2 + (1-al^2) ./ (1+ (inFF/f3).^2)) + finv./inFF );
    otherwise %'case 1'
        %Pure Lorentzian, no filters. Used in Timeshareds (?)
        outP = sum( D/2/pi^2./(fc^2+inFF.^2));
end