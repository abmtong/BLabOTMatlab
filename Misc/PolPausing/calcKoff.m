function out = calcKoff(times, offordied)

%Get time to fall off, and whether it unbound (1) or broke (0)

%To calculate, we need to assume some sort of distribution , which should be 1exp?
% and then use MLE

lpdf = @(x0,x) log(x0) + (-x0*x); %Probability of seeing something of time S
lccdf = @(x0,x) (-x0*x); %Probability of something to go greater than X seconds

ft = mle(times, 'pdf', lpdf, 'survival', lccdf, 'Censoring', offordied);



% offordied = logical(offordied);
% fitfcn = @(x0) sum( [lpdf( x0, times(offordied) ) lccdf(x0, times(~offordied)) ] );
% out = lsqnonlin(fitfcn, 10, 0, inf, optimoptions('lsqnonlin', 'Display', 'off') );