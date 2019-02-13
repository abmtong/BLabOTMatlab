function [out] = findDriftStep( inContour, inWidth )
%FINDDRIFTSTEP Summary of this function goes here
%   Detailed explanation goes here

len = length(inContour);
fits = zeros(len,3);
out = zeros(len,1);
for i = inWidth+1:len-inWidth+1
    x = i-inWidth:i+inWidth-1;
    y = double(inContour(x));
    fits(i,:) = lsqcurvefit(@twoline,[0 y(1) y(end)],x,y);
    out(i) = calcRSS(x,y,fits(i,:));
end

figure
plot(out)

end

%What they define in the paper, doesnt seem to work?
function outFit = fitLines(y,w,i) %inData, width, steploc
N = 2*w; %Number of points in nei
x = 1:N;

%nei = neighborhood
nei1 = i-w:i+w-1; %whole neighborhood
nei2 = i-w:i-1; %before i
nei3 = i:i+w-1; %after i

sum1 = x(nei1)*y(nei1)';
sum2 = sum(x(nei2))*sum(y(nei2));
sum3 = sum(x(nei3))*sum(y(nei3));
sum4 = sum(x(nei1).^2);
sum5 = sum(x(nei2))^2;
sum6 = sum(x(nei3))^2;

num = N/2*sum1 - sum2 - sum3;
den = N/2*sum4 - sum5 - sum6;

%slope
m = num/den;

sum7 = sum(y(nei2));
sum8 = sum(x(nei2));

%left intercept
bl = 2 * (sum7 - m * sum8) / N;

sum9 = sum(y(nei3));
sum10 = sum(x(nei3));
%right intercept
br = 2 * (sum9 - m * sum10) / N;


sum11 = sum(x(nei1));
sum12 = sum(y(nei1));

num2 = N * sum1 - sum11 * sum12;
den2 = N * sum4 - sum11^2;
%single slope
m2 = num2/den2;

b2 = ( sum12 - m2 * sum11 ) / N;

outFit = [m bl; m br; m2 b2];
end

function outRSS = calcRSS(x, y, inFit)
lin = x\y;

g = x * lin(1) + lin(2);

b = [ones(1,length(x)/2) * inFit(2) ones(1,length(x)/2) * inFit(3)];
f = x * inFit(1) + b;

h = inFit(2) - inFit(3);
outRSS = (sum((g-y).^2) - sum((f-y).^2))*h;
end