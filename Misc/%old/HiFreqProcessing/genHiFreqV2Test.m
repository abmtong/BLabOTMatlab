function out = genHiFreqV2Test()

chans = 3;
split = 4;
iters =5;

out = zeros(1,split*iters*chans);
for i = 0:iters-1
    for j = 0:chans-1
        in = i*chans+j;
        lo = in*split+1;
        hi = (in+1)*split;
        out(lo:hi) = j+1;
    end
end