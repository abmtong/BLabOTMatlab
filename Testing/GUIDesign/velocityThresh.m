function outVT = velocityThresh(inY, dec)
outVT = zeros(1, floor(length(inY)/dec));
X = [(1:dec)' ones(dec,1)];
for ii = 1:length(outVT)
    pf = X\inY(1+ (ii-1)*dec : ii*dec)';
    outVT(ii) = pf(1);
end
end