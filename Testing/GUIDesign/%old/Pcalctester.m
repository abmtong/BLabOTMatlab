function Pcalctester()

st = 100;
testPx = -st:st;
testPy = 0.1 * ones(size(testPx)) + (0:2*st)/st*4;
pen = 1;
inNoise = 1;
neighpt = st+1;
neiwid = st/2;
inYRes = 1;
tic
%old way
%If we're given a distribution, calculate W by interpolating. Penalty is proportional to -log(p)
W = zeros(neighpt);
for j = 1:neighpt
    W(j,:) = -pen/4.5*inNoise*log( interp1(testPx,testPy, inYRes * (j-(1:neighpt)) ) ); %Packaging is a positive step size, by this def'n
    W(j,j) = 0;
end
%Interp1 doesn't like interping values outside the given range, so set them to something (large) - this is the value Aggarwal had
W(isnan(W)) = pen/4.5*50*inNoise;
%And log(0) = -Inf
W(isinf(W)) = pen/4.5*50*inNoise;
toc


%new way
tic
neigh = (2*neiwid:-1:-2*neiwid);

Wb = -pen/4.5*inNoise*log( interp1(testPx,testPy, inYRes * neigh));
Wb(2*neiwid+1) = 0;
W2 = (bsxfun(@plus, 1:neighpt, (neighpt-1:-1:0)'));
W3 = Wb(W2);
toc
isequal(W, W3)