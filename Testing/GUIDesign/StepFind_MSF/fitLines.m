function [pwFit, linFit] = fitLines(y) %Sliced data, width, steploc
N = length(y);
if rem(N,2)
    error('MSF Error: pass an even number of points.');
end
w = N/2;
x = 1:N;

%nei = neighborhood
nei0 = 1:2*w; %whole neighborhood
nei1 = 1:w; %before i
nei2 = w+1:2*w; %after i

%Intermediates
sum1 = x(nei0)*y(nei0)';
sum2 = sum(x(nei1))*sum(y(nei1));
sum3 = sum(x(nei2))*sum(y(nei2));
sum4 = sum(x(nei0).^2);
sum5 = sum(x(nei1))^2;
sum6 = sum(x(nei2))^2;

num = N/2*sum1 - sum2 - sum3;
den = N/2*sum4 - sum5 - sum6;

%slope
m = num/den;

sum7 = sum(y(nei1));
sum8 = sum(x(nei1));

%left intercept
bl = 2 * (sum7 - m * sum8) / N;

sum9 = sum(y(nei2));
sum10 = sum(x(nei2));
%right intercept
br = 2 * (sum9 - m * sum10) / N;


sum11 = sum(x(nei0));
sum12 = sum(y(nei0));

num2 = N * sum1 - sum11 * sum12;
den2 = N * sum4 - sum11^2;
%single slope
m2 = num2/den2;

b2 = ( sum12 - m2 * sum11 ) / N;

pwFit = [m bl br];
linFit = [m2 b2]; %same result as polyfit(x,y,1), but solving analytically to mimic the source paper
end
