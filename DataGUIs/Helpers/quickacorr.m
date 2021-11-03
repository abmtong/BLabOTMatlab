function out = quickacorr(yn, Fs, verbose)

if nargin < 3
    verbose = 1;
end

% Fs = 1/binsz;
len = length(yn);

yn = yn - mean(yn);


oa = acorr2(yn);
ox = (1/Fs)*(0:length(oa)-1);

out = [ox(:) oa(:)];
if verbose
    figure Name QuickPSpec
    plot(ox(1:end/2),oa(1:end/2))
    ylim([0 1])
end

