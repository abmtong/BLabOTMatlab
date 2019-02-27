function gammatestv2()
%two pathways: one nmin 5, one nmin 6

n = 1e5;

x = exprnd(1,5,n);
y = exprnd(1.5,5,n);

x = sum(x, 1);
y = sum(y, 1);

p = 0.5; %chance to take slower path

dst = [y(1:p*n) x(p*n:end)];

fd = fitdist(dst(:), 'gamma');
fd2 = fitdist(x(:), 'gamma');
fd3 = fitdist(y(:), 'gamma');

fprintf('%0.2f\n', fd.a, fd2.a, fd3.a)