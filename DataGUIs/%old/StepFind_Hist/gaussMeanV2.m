function out = gaussMeanV2(data)
%To be used with @windowFilter

len = length(data);
%If width = 0 (unfiltered) do nothing
if len == 1
    out = data;
    return;
end

weights = normpdf(linspace(-1, 1, len), 0, 0.5); %row vector
out = (weights * data(:))/sum(weights);