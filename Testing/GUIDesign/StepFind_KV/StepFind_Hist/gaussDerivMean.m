function out = gaussDerivMean(data)
%To be used with @windowFilter, use largeish values (at least, say, 7)

%If width = 0 (unfiltered) do nothing
if length(data) == 1
    out = data;
    return;
end

%Make data odd length if necessary
if rem(length(data),2)
    data = data(1:end-1);
end

width = (length(data) - 1) / 2;
weights = diff(diff(normpdf(-width-1:width+1,0,width/2)));

out = (weights(:)' * data(:))/sum(weights);