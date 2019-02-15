function out = gaussMean(data)
%To be used with @windowFilter

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
weights = normpdf(-width:width,0,width/2);
out = (weights(:)' * data(:))/sum(weights);