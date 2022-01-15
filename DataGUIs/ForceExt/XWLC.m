function outXpL = XWLC(F, P, S, kT, method)
%Calculates the XWLC extension-to-contour conversion for a given force(s) and XWLC parameters.
%Inputs: Force, XWLC parameters (Persistence length, Stretch modulus, kT), and XWLC method
% Force can be a vector, and this will work element-by-element on it.
%Example usage: Given extension E and force F, contour =  e./ XWLC(F)
%Method doesn't really matter, especially if you're fitting to DNA first (all it needs to do is match the shape)

if nargin < 5 || isempty(method)
    method = 3; %method 1: classic, 2: what phage used, 3: wikipedia
end

%Defaults
if nargin < 4 || isempty(kT)
    kT = 4.14; %pNnm, = .0138pNnm/K * 300K
end
if nargin < 3 || isempty(S)
    S = 900; %pN
end
if nargin < 2 || isempty(P)
    P = 50; %nm
end
if nargin < 1 || all(F == -1)
    F = 0.1:0.1:45;
    testplot = 1;
else
    testplot = 0;
end

%Handle out-of-range F
if any(F <= 0)
    F = abs(F);
    if any(F == 0)
        F(F==0) = eps(1);
    end
    warning('Negative forces detected, taking absolute value')
end

switch method
    case 2 %Legacy (used in Phage before me, kept here for historical reasons)
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
    case 3 %From Wikipedia, eh sure
        %Simplification var.s
        C1 = F*P/kT;
        C2 = exp(nthroot(900./C1,4));
        outXpL = 4/3 ...
            + -4./(3.*sqrt(C1+1)) ...
            + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
            + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
            + F./S;
    otherwise %Basic theory
        outXpL = 1-.5*(kT./F/P).^.5 + F/S;
end

if testplot
    figure('Name', sprintf('XWLC %dnm %dpN', P, S));
    plot(outXpL,0.1:0.1:45)
end
end