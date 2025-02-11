function out = bitresample(x, n)
%'Resamples' the vector x to be 1xn via repetition

%Basically just create an index vector 1 1 1 ... 2 2 2....3 3 3... etc.
tmp = linspace( 1, length(x)+1, n+1);
out = x( floor( tmp(1:end-1) ) );
out = out(:)';