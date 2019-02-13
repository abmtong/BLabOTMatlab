function outData = medianFilter( inData, window )
% Filters by a centered window (it uses the greatest odd number below window)
width = floor((window-1)/2);
len = length(inData);
outData = zeros(1,len);
for i = 1:length(inData)
    startInd = max(1,i-width);
    endInd = min(i+width, len);
    outData(i-width) = median(inData(startInd:endInd));
end

end

