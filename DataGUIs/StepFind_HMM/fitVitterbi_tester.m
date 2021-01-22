function [out, dws] = fitVitterbi_tester(dist, noi, w)

%Distribution is a string: exponential, flat, etc.

%Noi is 1/SNR ratio (i.e. the sd of the noise if signal = 1 unit)

%Fits 1k steps with a given dist, avg dwell 10pts

%Number of points to simulate. Say 5k, why not.
n = 5e3;

%Mean dwell length (pts), 50 default (20Hz at 1kHz Fs)
if nargin < 3
    w = 50;
end

%3 SNR by default, the rough SNR of Tx traces
if nargin < 2
    noi = 3; %eg 1 noise cf .34 signal;
end

%Exponential by default
if nargin < 1
    dist = 'exp';
end

switch dist
    case 'exp'
        dws = ceil(exprnd(w, 1, n));
    case 'phage'
        dws = ceil( sum( exprnd(w/5, 5, n), 1) );
    case 'delta'
        dws = w*ones(1,n);
    case '2exp'
        dwmult = 3;
        p = 0.25;
        dws = ceil([exprnd(w, 1, round(n*(1-p))) exprnd(w*dwmult, 1, round(n*p)) ]);
        dws = dws(randperm(length(dws)));
end

scl = 1;
off = 0;

len = length(dws);
y = cell(1,len);
for i = 1:len
    y{i} = ones(1,dws(i)) * i * scl + off;
end
y = [y{:}];
yn = y + randn(size(y))*noi;

ft = fitVitterbiV3(yn, struct('ssz', 1, 'dir', 1, 'off', 0));

figure('Name', sprintf('FitVitTester Dist %s, SNR %0.2f, Mean %0.2f', dist, noi, w ),'Color', [1 1 1])
subplot(3,1,1), hold on, xlabel('Time (pts)'), ylabel('Position (bp)'), title('Fitting')
plot(yn, 'Color', [.7 .7 .7]), plot(y, 'g'), plot(ft, 'b')
[fdw, me] = tra2ind(ft);
fdw = diff(fdw);
axis('tight'), xlim([600 1600]), yl = ylim;

if scl == 1
    subplot(3,1,2), hold on, xlabel('Position (bp)'), ylabel('Difference (pts)'), title('Fit residual')
    fdwa = zeros(size(dws));
    fdwa(me) = fdw;
    plot( (fdwa - dws), 'b' )
    fprintf('Rsd STD = %0.2f\n', std(fdwa-dws));
    line( [0 length(dws)], [0 0], 'Color', 'k')
    axis('tight'), xlim(yl);
end

subplot(3,1,3), hold on, xlabel('Dwell Length (pts)'), ylabel('CCDF (arb.)'), title('Complementary CDF')
plot( sort(dws, 'descend') , (1:len)/len, 'g'), plot(sort( fdw, 'descend' ), (1:length(fdw))/length(fdw) , 'b');
set(gca, 'YScale', 'log')
axis('tight'), xlim([0 w*4])

out = fdw;
