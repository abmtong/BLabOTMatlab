%Hypot is 10-20% faster (it's a built-in)

a = 3e100;
b = 4e100;
niter = 1e7;

tic
for i = 1:niter
    c = sqrt(a.^2 + b.^2);
end
toc

tic
for i = 1:niter
    d = hypot(a, b);
end
toc
assert(isequal(c,d))