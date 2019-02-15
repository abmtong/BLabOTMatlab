function g = TWLC_calcG(x, F, P, S, L, C)
%Twistable WLC, for overstretching. Other params taken from other fits/literature

if nargin < 6
    C = 440;
end

kT = 4.14;

c1 = (F*P/kT).^-.5;

% g = S*C-C*F.*(x/L -1 + 0.5*c1).^-1;
t1 = S*C;
t2 = -C*F;
t3 = x/L;
t4 = -1;
t5 = 0.5*c1;

t345 = t3 + t4 + t5;
t345i = t345.^-1;

g = t1 + t2 .* t345i;