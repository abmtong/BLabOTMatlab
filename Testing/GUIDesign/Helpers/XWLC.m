function outXpL = XWLC(F, P, S, kT)

if nargin < 2
    P = 60;
end
if nargin < 3
    S = 550;
end
if nargin < 4
    kT =(273+27)*.0138;
end

%Simplification var.s
C1 = F*P/kT;
C2 = exp(nthroot(900./C1,4));
outXpL = 4/3 ...
    + -4./(3.*sqrt(C1+1)) ...
    + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
    + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
    + F./S;
end