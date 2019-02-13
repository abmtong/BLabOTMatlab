function gammatest()

n = 1e5;

x = exprnd(1,1,n);

y = exprnd(1,1,n);

zx = (0:0.1:10);
zy = zeros(size(zx));

for i = 1:length(zx)
    fd = fitdist((x + zx(i) * y)', 'gamma');
    zy(i) = fd.a;
end

figure, plot(zx, zy)