function outDoG = genDiffOfGauss( inWidth, inSD )
% Creates a normalized Difference of Gaussians sharpening filter defined by its width and the SD of the gaussian
% Generates a filter with floor(inWidth-1)/2 points on each side.
% For well-behaved values, make sure the filter contains the dropoff, e.g. inWidth > 15*inSD (the default value is =).

% This is a sharpening that approximates the one done by the human eye
% Paakkonen, Morgan, 2001. https://doi.org/10.1016/S0042-6989(01)00170-5
% DoG = normpdf(x,0,f) - 0.44*normpdf(x,3.52f,1.55f)

if nargin < 2
    inSD = inWidth/15;
end

width = floor((inWidth-1)/2) + 1; %Longer since diff removes one value
x = -width:1:width;
y = diff(diff(normpdf(x,0,inSD)));

outDoG = y/sum(y);
end

