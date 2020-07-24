function [dev] = findDrifts(inData, inTrace, inWidth)
%Checks each step against a non-stepping fit (join endpoints by a line instead of a step)

noise = estimateNoise(inData, inWidth);
[ind, mea] = tra2ind(inTrace);
dev = zeros(1,length(ind)-2);

inDf = windowFilter(@mean, inData, inWidth);

for i = 1:length(ind)-2
    x1 = ind(i):ind(i+1)-1;
    x2 = ind(i+1):ind(i+2)-1;
    da1 = inData(x1);
    da2 = inData(x2);
    x = [x1 x2];
    mb = polyfit(x, inData(x), 1);
    qd1 = sum( (da1 - mea(i)).^2 );
    qd2 = sum( (da2 - mea(i+1)).^2 );
    
    qdA = sum( (inData(x) - mb(1)*x - mb(2) ).^2 );
    dev(i) = (qdA - qd1 - qd2) / length(x);
end



dev = dev / 2 / noise;

end
