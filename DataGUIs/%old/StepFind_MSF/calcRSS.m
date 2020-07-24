function outRSS = calcRSS(x, y, pwFit, linFit)
%linFit = [m b]
%pwFit = [m bLeft bRight]
%length(x) assumed to be even

g = x * linFit(1) + linFit(2);

b = [ones(1,length(x)/2) * pwFit(2), ones(1,length(x)/2) * pwFit(3)];
f = x*pwFit(1) + b;

h = pwFit(2) - pwFit(3);
outRSS = (sum((g-y).^2) - sum((f-y).^2))*h;
end