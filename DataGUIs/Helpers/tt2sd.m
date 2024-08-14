function outp = tt2sd(m1, m2, sd1, sd2, n1, n2)
%Performs a two-tailed Welch's t-test from sample means + std's, not from individual data

%Basically taken from @ttest2 with unequal variances

%Difference
x = m1 - m2;

%Standard error
var1n = sd1^2 / n1;
var2n = sd2^2 / n2;
se = sqrt( var1n + var2n );

%Degrees of freedom
v = (var1n + var2n)^2 / (var1n^2/(n1-1) + var2n^2/(n2-1) );

%T-score
t = x/se;

%p-value
outp = 2 * tcdf(-abs(t), v);