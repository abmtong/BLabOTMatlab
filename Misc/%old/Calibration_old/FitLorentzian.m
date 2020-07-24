function [fc,D] = FitLorentzian(f,P)
%from tweezercalib2.1, modified
%Finds the cornerfrequency and Diffusion constant from closed formulas
%The resulting values are used as initial parameters for the fit


%Generate intermediates
for i = 0:2
    for j = 0:2
        c.(sprintf('s%d%d',i,j)) = sum( (f.^(2*i)) .* (P.^j) );
    end
end

a   = (c.s01 * c.s22 - c.s11 * c.s12) / (c.s02 * c.s22 - c.s12.^2);
b   = (c.s11 * c.s02 - c.s01 * c.s12) / (c.s02 * c.s22 - c.s12.^2);

%Corner freq.
fc  = sqrt(a/b);
%Diffusion coeff.
D   = (1/b) * 2 * (pi.^2);

%{
%In source code, but aren't used here (for debug / quality control)
Pfit = 1 ./ (a + b .* f.^2);

%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
% S.D.

x   = min(f) / fc;
y   = max(f) / fc;
s   = sqrt(pi) * ( (2*y) / (1 + y^2) - (2*x) / (1 + x^2) + 2 * atan((y - x) / (1 + x*y)) - ...
        (4/(y - x)) * (atan((y - x) / (1 + x*y)))^2) ^ (-1/2); 

sfc = s * fc / sqrt(pi * fc * T);

g   = sqrt( ((2*y)/(1 + y^2)-(2*x)/(1 + x^2) + 2*atan((y - x) / (1 + x*y)) )/((1 + pi/2)*(y - x)) );

sD  = D * sqrt( (1 + pi/2) / (pi * fc * T) )*g*s;

%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%}