function [outInd, outMea, outTr] = findStepLSQ(inContour, numSteps)
%Might be nice to use, say, as a final step? move each step slightly


if ~isa(inContour, 'double')
    inContour = double(inContour);
end


if nargin < 2
    numSteps = 20;
end
len = length(inContour);

    function y = fitfcn(inds)
        inds = [1 floor(sort(inds)) len];
        %y = ind3tra(inds, inContour)-inContour;
        y = sum((ind3tra(inds, inContour)-inContour).^2);
        
    end
lb = ones(1,numSteps)*2;
ub = ones(1,numSteps)*(len-1);

G = floor(linspace(1,len,numSteps+2));
G = G(2:end-1);

% options = optimoptions(@ga);
% options.OptimalityTolerance = 1e-10;
% options.FunctionTolerance = 1e-10;
% options.MaxIterations = 1e5;
%outInd = lsqnonlin(@fitfcn, G, lb, ub, options);

outInd = ga(@fitfcn,numSteps,[],[],[],[],lb,ub,[],1:numSteps,[]);

outInd = [1 outInd len];
outMea = ind2mea(outInd, inContour);
outTr = ind2tra(outInd, outMea);

end