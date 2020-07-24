x = 1:1000;
y = randn(1,length(x));

niter = 1e4;
% tic
% for i = 1:niter
%     a = polyfit(x,y,1);
% end
% toc
tic
for i = 1:niter
    v = [x' ones(length(x),1)];
    b = v\y';
end
toc

tic
for i = 1:niter
    c = linfit(x, y);
end
toc

[a(:), b(:), c(:)]