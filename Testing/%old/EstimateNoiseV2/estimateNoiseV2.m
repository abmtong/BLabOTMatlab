function outNoise = estimateNoiseV2(inData)
%Empirically, it seems that the graph of estimateNoise as a fcn of filter width looks like two lines,
% the first of which is very steep and short, the second shallow and extends to infinity.
% The Y-intercept of the second line pretty well matches the noise, so we'll use that strategy.

%Not much different from estimateNoise in most cases, but works better for highly downsampled data (dont need to supply inDec)


len = length(inData);

%purely empirical, works fine (most values work fine)
xs = unique(round((len/50):(len/50):(len/5))); %length(xs) = 37

len = length(xs);
vars = zeros(1, len);
for i = 1:len
    dec = ceil(xs(i)/10);
    vars(i) = var(inData(dec:dec:end) - windowFilter(@mean,inData, round(xs(i)/2), dec));
%     vars(i) = var(inData - smooth(inData, (xs(i)))');
end

pf = polyfit(xs, vars, 1);
figure, plot(xs, vars), line([0 xs(end)],pf(1)*[0 xs(end)] + pf(2))
outNoise = pf(2);