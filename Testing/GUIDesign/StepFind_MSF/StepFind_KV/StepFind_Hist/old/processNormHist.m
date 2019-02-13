function outP = processNormHist(inHist, inYRes, inRange)
%Processes a normHist to be used for findStepHistV4

%Remove zeroed values of inHist to find minimum nonzero value
inHistNoZero = inHist;
inHistNoZero(inHist(:,2) == 0,:) = [];

%Remove outliers (what show up only once)
histMin = min(inHistNoZero(:,2));
inHist(:,2) = inHist(:,2) - histMin;

%Gaussian filter it, for smoothness
inHist(:,2) = windowFilter(@gaussMean, inHist(:,2), 3);

%Now assemble outP

%Make sure inRange is a multiple of inYRes
div = ceil(inRange / inYRes);
inRange = div * inYRes;
x = -inRange:inYRes:inRange;
y = zeros(1,length(x));

%Place our values in the right place, otherwise do exp(-50) [a very small nonzero number]
for i = 1:length(x)
    ind = find( abs(inHist(:,1) - x(i)) < 1E-10); %weird rounding errors show up for ... reasons
    if ~isempty(ind) && inHist(ind,2) > 0
        y(i) = inHist(ind,2);
    else
        y(i) = exp(-50);
    end
end
outP = [x' y'];