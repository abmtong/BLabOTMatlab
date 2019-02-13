%Time/memory can be saved if necessary by doing in-place ops on large data
tic
a = randn(1000);
toc
tic
    b = C_square(a);
toc
tic
c = randn(1000);
toc
tic
d = c.^2;
toc