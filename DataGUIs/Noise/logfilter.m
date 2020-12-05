function out = logfilter(x, splitnum, filtfact)

%Filter for plotting the whole, filters down to splitnum * (len/2) ^ (1/splitnum) points
if nargin < 2
    splitnum = 5;
end
if nargin < 3
    filtfact = 5;
end

len = length(x);
binfacts = round( filtfact .^(0:splitnum-1) );

Xall = cell(1, splitnum);
%divide Pf into exponentially equivalent length
inds = round(len .^ ((0:splitnum )/ splitnum));
%filter
for i = 1:splitnum
    Xall{i} = windowFilter(@mean, x(inds(i):inds(i+1)), [], binfacts(min(i, length(binfacts))));
end
%join
out = [Xall{:}]';
