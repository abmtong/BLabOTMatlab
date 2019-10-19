function [me, sd] = jkmean(iny)

len = length(iny);
%generate subgroup means: mean of the set minus one element
ymns = (sum(iny) - iny)/(len-1);
%jackmean is the mean of this
me = mean(ymns);
%jacksd is sqrt((n-1)/n) * the sd of this
sd = std(ymns) * sqrt((len-1)/len);

me = mean(iny);
%Consider using @jackknife instead.

%in one line as a function handle:
% jkmn = @(x) mean(sum(x) - x)/(length(x)-1);
%  jkmn = len * mean(x) - mean(x) / length(x) -1 = mean(x). uhh...
% jksd = @(x) sqrt(var(sum(x) - x)/(length(x)-1));