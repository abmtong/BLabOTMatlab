function [y] = poisson(x, mean)

%  Generates a probability distribution with a mean according
%  to the continuous POISSON distribution
%
%  function [y] = poisson(x, mean)
%  x = vector for the distribution to the evaluated at
%  mean = mean of the POISSON distribution
%  y = the probability distribution for the vector x

     for i = 1:length(x),
      val = x(i);
      y(i) = exp(val * log(mean) - mean - gammaln(val+1));

     end

% This is from Bevington, Robinson, eq. 2.16  -- just taking the
% log and then exponentiating it to see where it comes from.
%
% gammaln is the logarithm of the gamma function, which is the
% continuous version of the factorial. for more information, type
% 'help  gammaln' and for questions, e-mail bilge@mit.edu.