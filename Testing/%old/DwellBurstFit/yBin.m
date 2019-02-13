function out = yBin (yData, numBins)
%Bins yData in numBins equally spaced bins.

yMax = max(yData);
yMin = min(yData);

%Default is avg. 50 points per bin
if(nargin < 2)
    numBins = ceil(length(yData)/50);
end

range = linspace(yMin,yMax,numBins);
disp (num2str((range(2)-range(1))))
range(numBins+1) = range(numBins) + 1; %Pad the end
out = zeros(1,numBins);
for i = 1:numBins
    out(i) = length(find( (yData >= range(i)) & (yData < range(i+1)) ) );
end
end