function out = quickpspec(yn, binsz, verbose)

if nargin < 3
    verbose = 1;
end

Fs = 1/binsz;
len = length(yn);

p = abs(fft(yn).^2)/Fs/(len-1);
f = (0:len-1)/(len-1)*Fs;
out = [f(:) p(:)];
if verbose
    figure Name QuickPSpec
    plot(f(1:end/2),p(1:end/2))
end

