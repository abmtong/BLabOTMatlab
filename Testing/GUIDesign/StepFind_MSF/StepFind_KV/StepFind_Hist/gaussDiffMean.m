function out = gaussDiffMean(data)
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
weights = normpdf(-width:width,0,width/8) - 0.44 * normpdf(-width:width, width * 3.52 / 8, width * 1.55/8);

out = (weights(:)' * data(:))/sum(weights);