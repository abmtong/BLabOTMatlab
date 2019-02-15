function out = plotNoiseFSamp(inData)

inFs = 62.5e3; %= 5^6 * 2^2
fmin = 0;
ffinal = 50;
%Hence can compare 50 * ( 5^(0:3) * 2^(0:1) )
decs = [1 5 25 125 625 10 50 250 1250];
decs = sort(decs(decs >= fmin/ffinal));
decsi = inFs/ffinal./decs;
testFs = decsi*ffinal;
len = length(decs);

outNoi = zeros(1, len);
for i = 1:len
    dat = inData(decs(i):decs(i):end);
    datF = windowFilter(@mean, dat, [], decsi(i));
    outNoi(i) = std(datF);
end
figure, plot(sqrt(testFs), outNoi)
xlabel('1/sqrt(Fs)')
ylabel('Noise (std)')
out = [testFs' outNoi'];
