%C code is generally faster by ~2x

len = 10000;
iter = 100000;
a = randn(1,len);
b = zeros(1,len);
c = zeros(1,len);

tic
for i = 1:iter
    b(i) = sum( (a-mean(a)).^2);
end
toc

tic
for i = 1:iter
    c(i) = C_qe(a);
end
toc