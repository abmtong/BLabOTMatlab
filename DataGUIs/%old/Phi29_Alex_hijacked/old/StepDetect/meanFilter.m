function outData = meanFilter( inData, window )
% Filters by a centered window (it uses the greatest odd number below window)
%The same as movingAverageFilter, just renamed
width = floor((window-1)/2);

outData = zeros(1,length(inData)-2*width);
for i = width+1:length(inData)-width
    outData(i-width) = mean(inData(i-width:i+width));
end

end

