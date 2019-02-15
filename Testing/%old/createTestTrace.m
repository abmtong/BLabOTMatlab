function out = createTestTrace
sig = [10 20 30 40]; %accepts matrix input, does so cyclically
noi = 5;
dw = 100;
n = 10;

out = zeros(1, n*dw);

pos = 0;

for i = 1:n
    pos = pos + sig( mod(i+length(sig)-1, length(sig))+1 );
    out((i-1)*dw+1:i*dw) = zeros(1,dw)+pos;
end

out = out + randn(1, length(out))*noi;