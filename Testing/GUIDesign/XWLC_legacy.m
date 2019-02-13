function xpL = XWLC_legacy(F, P, K, kT)

if nargin < 4
    kT = 4.14;
end
if nargin < 3
    K = 1200;
end
if nargin < 2
    P = 50;
end

xpL = 1-.5*(kT./F/P).^.5 + F/K;