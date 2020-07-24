function out = find50gc(seq, len)

%Finds a region of exactly 50% GC of length len

if nargin < 1
    try
        l = load('lambda.mat');
    catch
        return
    end
    seq = l.lam;
end

if nargin < 2
    len = 1500;
end

if mod(len,2)
    len = round(len)+1;
    warning('Making length even by adding one (%d).', len)
end

%Use Filter to sum the g's and c's, find where it's 50%, then return the first bp (filter will be on the last bp)
filt = filter(ones(1,len),1,seq == 'G' | seq == 'C');
out = find(filt(len:end) == len/2);

%Plot, so we can see the GC content over time (want it to be evenly GC50 ish
fil2 = filter(ones(1,200),1,seq == 'G' | seq == 'C');
fil2 = fil2(200:end);
figure, plot(fil2/200)
