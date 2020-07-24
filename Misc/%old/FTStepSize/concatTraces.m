function out = concatTraces(inX, inY, sampRate)

if (nargin < 3)
    sampRate = 2500;
end

len = round(2500*inX{end}(end));
out = zeros(1,len);

for i = 1:length(inX)
    ind = round(inX{i}*sampRate);
    out(ind) = inY{i};
end
