function xoverL = ForceExt_XWLC_Wikipedia(F, P, S)
%Calculates the extension per contour of an XWLC with persistence length P, stretch modulus S. Accepts vector F, scalar P, S.
%Source: Petrosyan, 2016. doi:10.1007/s00397-016-0977-9

kT = 4.14; %pN*nm, 300K

if nargin < 3
    S = 800;
end
if nargin < 2
    P = 50;
end

%Simplification var.s
C1 = F*P/kT;
C2 = exp(nthroot(900./C1,4));

%Calculate term by term, for readability
xoverL = 4/3 ...
        + -4./(3.*sqrt(C1+1)) ...
        + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
        + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
        + F./S; %this last term is the extensible part