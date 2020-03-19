function outXpL = XWLC(F, P, S, kT, method)
%Writes

if nargin < 5 || isempty(method)
    method = 3; %method 1: classic, 2: what phage used, 3: wikipedia
end

if nargin < 4 || isempty(kT)
    kT = 4.14;
end
if nargin < 3 || isempty(S)
    S = 900;
end
if nargin < 2 || isempty(P)
    P = 50;
end
if nargin < 1 || isempty(F)
    F = 0.1:0.1:45;
    testplot=1;
else
    testplot = 0;
end

switch method
    case 2 %phage, legacy
        % Simplification Variables
        a = -4*(F*P/kT-0.75);
        b = 4;
        m = 2*sqrt(-a/3);
        q = acos(3*b./(m.*a));
        sgn = 2*(a <= 0)-1; %accounts for change of sign and uses correct soln (YRC 10/06)
        outXpL = 1+F./S+1./(m.*cos(q/3+sgn*2*pi/3));
%         % at some point, they wanted this to output K*L; saved here (comment)
%         k = kT/P*(0.5./(1-outXpL+F/S).^3+1)./(1+kT/P/S*(0.5./(1-outXpL+F/S).^3+1));
%         outXpL = k;
    case 3 %wikipedia
        %Simplification var.s
        C1 = F*P/kT;
        C2 = exp(nthroot(900./C1,4));
        outXpL = 4/3 ...
            + -4./(3.*sqrt(C1+1)) ...
            + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
            + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
            + F./S;
    otherwise %pure theory
        outXpL = 1-.5*(kT./F/P).^.5 + F/S;
end

if testplot
    figure('Name', sprintf('XWLC %dnm %dpN', P, S));
    plot(outXpL,0.1:0.1:45)
end
end