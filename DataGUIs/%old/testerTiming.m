a = zeros(10000);
aa = 1:length(a);
b = zeros(10000);
bb = 1:length(b);

tic
for i = 1:length(a)
    a(i,:) = a(i,:) + aa;
end
toc

tic
b = bsxfun(@plus, bb, b);
toc