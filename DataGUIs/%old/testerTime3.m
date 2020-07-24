%Better to do as much as matrix ops as possible (form matrix with @plus instead of a unique @fun

con = 40;
a = 1:1000;
beadPos = randn(1,1000);
h = 5;
tic
for i = 1:1000
    Q1 = (bsxfun(@plus, beadPos, a)/h - con).^2;
end
toc


tic
for i = 1:1000
    c = h;
    d = con;
    fun = @(x, y) ((x+a)/c - d).^2;
    Q2 = bsxfun(fun, beadPos, a);
end
toc

fprintf('Equality: %d\n',isequal(Q1, Q2));