function x = XWLCContour(F, P, S, kT, option)
% x = XWLCContour(F, P, S, kT, option)
%     or
% x = XWLCContour(F, P, S, kT)
%     or
% x = XWLCContour(F, P, S)
%     or
% x = XWLCContour(F, P)
%     or
% x = XWLCContour(F) %the defaults are used in this case
%
% Defaults: KT=4.14
%           S=1200
%           P=53
%           Returns x/L by default
%
% Calculates extension over contour x/L given force F (pN), 
% persistence length P (nm) and stretch modulus S (pN).
%
% If option = 1 returns extension over contour x/L;
% if option = 2 returns stiffness times contour KL.

% Default Values
if nargin < 4
    kT = 4.14;
end
if nargin < 3
    S = 1200;
end
if nargin < 2
    P = 53;
    %P=35;
end

% Simplification Variables

a = -4*(F*P/kT-0.75);
b = 4;
m = 2*sqrt(-a/3);
q = acos(3*b./(m.*a));

sgn = 2*(a <= 0)-1; %accounts for change of sign and uses correct soln (YRC 10/06)
x = 1+F./S+1./(m.*cos(q/3+sgn*2*pi/3));

if nargin == 5 && option == 2 %return KL
    % x = 1./(1/S-8*P./(3*kT*m.^3)*(1+tan(q/3+2*pi/3)/3/sqrt(m.^6/4^4-1))./cos(q/3+2*pi/3));
    k = kT/P*(0.5./(1-x+F/S).^3+1)./(1+kT/P/S*(0.5./(1-x+F/S).^3+1));
    x = k;
end;    