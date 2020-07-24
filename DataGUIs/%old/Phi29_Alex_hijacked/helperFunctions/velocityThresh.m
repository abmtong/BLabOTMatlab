function outVT = velocityThresh(inY, dec)

outVT = zeros(1, floor(length(inY)/dec));
X = [(1:dec)' ones(dec,1)];
for i = 1:length(outVT)
    %x = (1+ (i-1)*dec : i*dec);
    pf = X\inY(1+ (i-1)*dec : i*dec)';
    %pf = polyfit(1:dec, inY(x),1);
    outVT(i) = pf(1);
end
