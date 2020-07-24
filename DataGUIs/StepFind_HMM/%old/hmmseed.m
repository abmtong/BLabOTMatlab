function outa = hmmseed(peaks, sds, trnsprob, weights)
%creates a starting 'seed' for the HMM with gaussians centered at peaks with sd sds.
%trnsprob is the probability of transition, you can estimate this by e.g. [range(trace) / (stepsize)] / length(trace)

if nargin < 3
    trnsprob = 0.01; %150bp/s -> 6% rate for 10bp step; 60bp/s -> 1% trns prob for 2.5 step
end
if nargin < 2
    sds = 1;
end
if nargin < 1
    peaks = 2.5;
end
if nargin < 4
    weights = ones(size(peaks));
end

%assumes a is the usual 1x251 matrix
x = 0:0.1:25;
outa = zeros(size(x));

for i = 1:length(peaks)
    outa = outa + normpdf(x, peaks(i), sds(i)) * weights(i);
end

%normalize
outa = outa / sum(outa(2:end))*trnsprob;
outa(1) = 1-trnsprob;
