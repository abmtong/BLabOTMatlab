function out = gaussDerivMean(data)
%To be used with @windowFilter, use largeish values (at least, say, 7)

%If width = 0 (unfiltered) do nothing
if length(data) == 1
    out = data;
    return
end

len = length(data);
weights = diff(diff(normpdf(linspace(-1, 1, len+2), 0,0.5)));

out = (weights * data(:))/sum(weights);