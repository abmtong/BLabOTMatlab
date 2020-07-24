function outDDG = genDDGauss( inWidth, inSD )
% Creates a normalized Second Derivative of a Gaussian filter defined by its width and the SD of the gaussian
% Generates a filter with floor(inWidth-1)/2 points on each side.


% From Marr, Hildreth, 1980. "Theory of edge detection"

if nargin < 2
    inSD = inWidth/5;
end

width = floor((inWidth-1)/2);
x = -width:1:width;
y = normpdf(x,0,inSD) - 0.44*normpdf(x,3.52*inSD,1.55*inSD);

outDDG = y/sum(y);
end
