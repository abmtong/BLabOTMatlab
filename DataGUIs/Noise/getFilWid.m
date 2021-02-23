function out = getFilWid(data, inOpts)

opts.Fs = 2500;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Plot powspec of data (diff of data?)
len = length(data);
P = abs(fft(data)).^2 / opts.Fs / (len-1);
F = (0:len-1)/(len-1)*opts.Fs;
%Chop constant term, and stop at Fnyq
F=F(2:floor(len/2));
P=P(2:floor(len/2));
len=length(F);

n=10;
w=exp( 5/n );
lf = @(x) logfilter(x, n, w);
figure, loglog(lf(F),lf(P))