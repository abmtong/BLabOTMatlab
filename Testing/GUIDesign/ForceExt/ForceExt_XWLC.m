function xoverL = ForceExt_XWLC(F, P, S, kT, option)
% Calculates extension over contour (x/L) given force F (pN), persistence length P (nm), and stretch modulus S (pN).
% from Ghe's code. Involves imaginaries (which eventually cancel, within float error) which isn't great imo

% If option = 1 returns extension over contour x/L;
% if option = 2 returns stiffness times contour KL.

% Default Values
if nargin < 4
    kT = 4.14;
end
if nargin < 3
    S = 800;
    %S = 1200; %in pN
end
if nargin < 2
    P=45;
end

% Simplification Variables
a = -4*(F*P/kT-0.75);
b = 4;
m = 2*sqrt(-a/3);
q = acos(3*b./(m.*a));

sgn = 2*(a <= 0)-1; %accounts for change of sign and uses correct soln (YRC 10/06)
xoverL = 1+F./S+1./(m.*cos(q/3+sgn*2*pi/3));

if nargin == 5 && option == 2 %return KL
    % x = 1./(1/S-8*P./(3*kT*m.^3)*(1+tan(q/3+2*pi/3)/3/sqrt(m.^6/4^4-1))./cos(q/3+2*pi/3));
    k = kT/P*(0.5./(1-xoverL+F/S).^3+1)./(1+kT/P/S*(0.5./(1-xoverL+F/S).^3+1));
    xoverL = k;
end;    