function out = quickpspec(yn, Fs, verbose)

if nargin < 3
    verbose = 1;
end

if nargin < 2
    Fs = 1e3;
    fprintf('Assuming Fs=1kHz\n')
end

% Fs = 1/binsz;
len = length(yn);

yn = yn - mean(yn);

p = abs(fft(yn).^2)/Fs/(len-1);
f = (0:len-1)/(len-1)*Fs;
out = [f(:) p(:)];
if verbose
    figure Name QuickPSpec
    plot(f(1:end/2),p(1:end/2))
    ylim([0 p(10)*5])
end

