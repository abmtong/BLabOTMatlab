niter = 10000;
len = 150;

tic
for i = 1:niter
    a = [];
    for j = 1:len
        a = [a j];
    end
end
toc

tic
for i = 1:niter
    b = zeros(1,len);
    for j = 1:len
        b(j) = j;
    end
end
toc

tic
for i = 1:niter
    c = 1:len;
end
toc

tic
for i = 1:niter
    d = zeros(1,len);
    for j = 1:len
        d(1) = j;
        d = circshift(d, [0 -1]);
    end
end
toc

isequal(a,b,c,d)