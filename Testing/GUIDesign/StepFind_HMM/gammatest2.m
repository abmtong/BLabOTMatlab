function gammatest2()
%Given k equally high barriers and one of differing height, what is the calculated gamma shape factor / nmin ?
%Plots calculated shape (blue) / nmin (orange) on Y, relative height of other barrier on X
%As expected, plot passes through (0,k) and (1,k+1), and then decreases from there.
%shapefactor > nmin always, with error increasing as x increases
%to lose one nmin, the different step needs to be 2-3x the time of others

n = 1e5; %number of points, anything over 1e4 is probably enough to average out random error
k = 4; %number of equally slow steps, in addition to the other step of varying time

x = exprnd(1,k,n);
x = sum(x,1);

y = exprnd(1,1,n);

zx = (0:0.1:10);
zy = zeros(size(zx));
zy2 = zeros(size(zx));

for i = 1:length(zx)
    t=(x + zx(i) * y)';
    fd = fitdist(t, 'gamma');
    zy(i) = fd.a;
    zy2(i) = mean(t)^2/var(t);
end

figure, plot(zx, zy), hold on, plot(zx,zy2)