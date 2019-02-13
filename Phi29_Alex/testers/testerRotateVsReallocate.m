%cirshift vs. new vector


a = 1:100;
len = length(a);
sh = floor(a/5);
tic
for i = 1:1000000
    b = circshift(a,[0,-sh]);
end
toc

tic
for i = 1:1000000
    c = [a(sh+1:end) a(1:sh)];
end
toc
isequal(b,c)