function outN = eNoise(inData, inWidths)

len = length(inWidths);
outN = zeros(1, len);

for i = 1:len
    outN(i) = var(inData-smooth(inData, inWidths(i))');
end
