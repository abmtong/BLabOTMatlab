function out = simbrownian(n, H )

%Is just cumsum(randn(1,1e4)) random brownian motion?

%And then can we correlate it by some factor h ?
if nargin < 1
    n = 1e4;
end

if nargin < 2
    H = 0.5;
end

%Base off of gaussian noise
out = randn(1,n);

%Process dx's based on h. Let's define h in the usual way for fBM:
% H is (0,1) with dividing line H = 1/2 is brownian, higher superdiffusive, lower subdiffusive
% e.g. jNPs might be subdiffusive, so let's focus on getting a non-linear MSD plot for H in (0, 0.5)

%Hm this only correlates adjacent points, need some longer, time-decaying amount. Can I 'exponential filter' them?

%Exponential decay filter, with exponent H. Really only makes sense for subdiffusive
for i = 2:n
    out(i) = sum(out(1:i) .* exp(H*((1:i)-i))) / sum(exp(H*((1:i)-i)));
end


%Check: plot cumsum and loglog
cs = cumsum(msd(out));
figure, loglog(cs, 'o')

end

