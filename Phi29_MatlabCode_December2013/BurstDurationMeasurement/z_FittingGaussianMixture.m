N=4;
P = ones(1,3*4); 
P([2 5 8 11]) = 2510:10:(2510+3*10);
%P(1) - amplitude
%P(2) - mean
%P(3) - sigma

GaussianMixture = @(P,x) (P(1)*normpdf(x,P(2),P(3)) + ...
                  P(4)*normpdf(x,P(5),P(6)) + ...
                  P(7)*normpdf(x,P(8),P(9)) + ...
                  P(10)*normpdf(x,P(11),P(12)));

x = double(x);
y = double(y);
% generate normal mixture density plus noise
Param = nlinfit(x,y,GaussianMixture,P);
figure;
plot(x,y,     '.b',...
     x,GaussianMixture(Param,x),'-r');