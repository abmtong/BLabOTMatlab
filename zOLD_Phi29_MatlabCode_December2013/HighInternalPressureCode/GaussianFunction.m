function y=GaussianFunction(a,x)
% Used for fitting, simple Gaussian function
% a(1) - amplitude
% a(2) - Sigma
% a(3) - peak of the gaussian, x-coordinate
%
% USE: y=GaussianFunction(a,x)
%
% Gheorghe Chistol, December, 21 2009

y = a(1)*exp(-0.5*a(2)^(-2)*(x-a(3)).^2);