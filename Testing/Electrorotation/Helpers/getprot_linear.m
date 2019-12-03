function out = getprot_linear(t, Fs)
if nargin < 2
    Fs = 1e4;
end

npts = (0:t*Fs-1);
out = [npts'/Fs, npts'/length(npts)*360];