%this bsxfun implementation is better
a = 0.2:0.2:50;
p = [a', randi(20,length(a),1)/40];

pen = 9;
inNoise = 10;
hei = length(a);
tic
W = -pen/4.5*inNoise*log(bsxfun( @(x, y)(interp1(p(:,1),p(:,2),x-y)) , a', a));

W(isnan(W)) = pen/4.5*50*inNoise;
%And log(0) = -Inf
W(isinf(W)) = pen/4.5*50*inNoise;
W = W - diag(diag(W));
toc

tic
X = zeros(hei);
for j = 1:hei
    X(j,:) = -pen/4.5*inNoise*log( interp1(p(:,1),p(:,2),a(j)-a) );
    X(j,j) = 0;
end
X(isnan(X)) = pen/4.5*50*inNoise;
%And log(0) = -Inf
X(isinf(X)) = pen/4.5*50*inNoise;
toc

isequal(W,X)