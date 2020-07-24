function xoverL = ForceExt_WLC_Wikipedia(F, P, S, kT, option)

%Option is here for legacy with ForceEXT_XWLC, wont be used
if nargin == 5 && option ==2
    error 'sorry, cant return KP in this one';
end

% Default Values
if nargin < 4
    kT = 4.14; %in pN*nm at 300K
end
if nargin < 3
    S = 1200; %in pN
end
if nargin < 2
    P = 53; %in nm
    %P=35;
end

%Simplification var.
C = F.*P/kT;

t1 = 4./3;
t2 = - 4./(3.*sqrt(C+1)) ;
t3 = - 10.*exp(nthroot(900./C,4))./(sqrt(C).*(exp(nthroot(900./C,4))-1).^2);
t4 = C.^1.62 ./ (3.55 + 3.8 .* C.^2.2) ;
t5 = F./S;

xoverL = t1 + t2 + t3 + t4;
