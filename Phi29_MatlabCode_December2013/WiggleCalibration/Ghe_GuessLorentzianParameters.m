function [fc D] = Ghe_GuessLorentzianParameters(f,P)
% Finds the cornerfrequency and Diffusion constant from closed formulas
% The resulting values are used as initial parameters for the fit
%
% USE: [fc D] = Ghe_GuessLorentzianParameters(f,P)
%
% Gheorghe Chistol, 27 April 2011

for p = 0 : 2,
    for q = 0 : 2,
        eval(['s' num2str(p) num2str(q) ' = sum ((f .^ (2*' num2str(p) ')) .* (P .^ (' num2str(q) ')));']);
    end;
end;

a   = (s01 * s22 - s11 * s12) / (s02 * s22 - s12.^2);
b   = (s11 * s02 - s01 * s12) / (s02 * s22 - s12.^2);

fc  = sqrt(a/b);
D   = (1/b) * 2 * (pi.^2);

%Pfit = 1 ./ (a + b .* f.^2);