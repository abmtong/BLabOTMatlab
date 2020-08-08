guess = [1 2 3 4];
x = 1:100;
y = rand(1,100);

fh = @(guess, x)(Lorentzian(guess, x));

t0 = tic;
for i = 1:20
    lsqcurvefit(fh,guess,x,y)
end
t1 = toc(t0);

t0 = tic;
for i = 1:20
    lsqcurvefit(@Lorentzian,guess,x,y)
end
t2 = toc(t0);

t1
t2