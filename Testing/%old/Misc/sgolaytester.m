function sgolaytester()

%test performance of sgolay filter on a step function

snr = 3;

sig = [zeros(1,50) ones(1,50)];
noi = randn(1,length(sig)) * 1/snr;
step = sig + noi;
figure('Name', sprintf('sgolay filter tester for snr %0.1f', snr))
plot(sig, 'k', 'LineWidth', 1), hold on%, plot(step, 'Color', [.7 .7 .7], 'LineWidth', 1); %dont plot, = sgolayfilt( x, n-1, n)
wid = 5*2+1;
rnks = 0:wid-1;
len = length(rnks);
miderrs = zeros(1,len);
sniperr = zeros(1,len);
errs = zeros(1,len);
for i = 1:len
    stepf = sgolayfilt(step, rnks(i), wid);
    col = hsv2rgb( mod((i-1)/len*2/3, 1) , 1, .6 ); %color range from red to blue
    plot(stepf, 'Color', col)
    errs(i) = sum( (sig-stepf).^2 );
    miderrs(i) = sum( (sig(end/4:end*3/4)-stepf(end/4:end*3/4)).^2 );
    sniperr(i) =  sum( (sig(end*.4:end*.6)-stepf(end*.4:end*.6)).^2 );
end

figure('Name', 'Square error from signal vs filter degree for [all, middle 50%, middle 20%] of trace')
plot(rnks, errs), hold on, plot(rnks, miderrs), plot(rnks, sniperr)
xlabel filter\_rank
ylabel square\_error
    