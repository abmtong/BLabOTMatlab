function [tra, tranoi, kvtra] = simTraceClpX(sszdist, noi, kvpf, verbose)

if nargin < 1 || isempty(sszdist)
    sszdist = [0 1 0]; %chc for 1, 2, 3nm steps
% sszdist = [1 1 1]; %chc for 1, 2, 3nm steps
end

if nargin < 2 || isempty(noi)
    noi = 3.0; %nm of noise
end

if nargin < 3 || isempty(kvpf)
    kvpf = single(2.5); %R says used between 2 and 3
end

if nargin < 4 || isempty(verbose)
    verbose = 1;
end

fil = 10;
Fs = 2500;
nnm = 30; %nm to package

%Normalize
sszdist = sszdist / sum(sszdist);
sszchc = cumsum(sszdist);

%Generate steps
nmax = nnm;
sszrng = rand(1, nmax);
ssz = arrayfun(@(x) find(x < sszchc , 1, 'first'), sszrng);
%Crop past nnm
mea = cumsum(ssz);
mea = mea( 1: find(mea > nnm, 1, 'first') );
%Invert direction
mea = max(mea) - mea;
nst = length(mea);

%Generate dwells
shp = 2; %Gamma shape factor, i.e. N exp's. Fits are ~3ish, it's 2 ATP per cycle so maybe should be 2?
tau = .2; %Average dwell time, s
dws = random('gam', shp, tau/shp, 1, nst);
dws = ceil( dws * Fs );
ind = cumsum([1 dws]);

%Ground truth trace
tra = ind2tra(ind, mea);

%Add noise
tranoi = tra + randn(1, length(tra)) * noi;

%Filter and KV
tranoiF = windowFilter(@mean, tranoi, [], fil);
[~, ~, kvtra] = AFindStepsV4(tranoiF, kvpf, 500, 0);

%Plot
if verbose
    figure Name SimTraceClpX
    hold on
    %Raw trace, filtered, ground-truth, stepfound [offset by 1]
    t = (1:length(tranoi))/Fs;
    plot(t, tranoi, 'Color', [.7 .7 .7]);
    tF = windowFilter(@mean, t, [], fil);
    plot(tF, tranoiF, 'Color',  [.3 .3 .3]);
    plot(t, tra, 'g')
    plot(tF, kvtra+1, 'r')
    
    legend({'Trace + Noise' 'Filtered Trace' 'Ground Truth' 'Stepfinding [Offset in Y]'}, 'Location', 'southwest')
    axis tight
    
    
    %Title with options
    title(sprintf(''));
    ylabel('Extension (nm)')
    xlabel('Time (s)')
end







