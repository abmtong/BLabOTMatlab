function [outy, outx] = rulerAlignV2_findPauses(tr, inOpts)
%When you have repeats but dont know the pause pattern
%in: Aligned traces (run rulerAlign with the right period (opts.per) and one pause ( opts.pauloc )
%out: Generate pause RTH

%It works-ish? The limiting the pause duration to 2 helps a lot (to remove skew by looong pauses)
% Maybe better eventually to e.g. 2-state HMM it or dwellfind it and use k's

% Does not work for arbitrary initial alignment. Maybe something closer to Antony's method would work better
%  Antony method: Get pairwise offsets a_ij, find x such that a_ij == bsxfun(@minus, x, x') mod [repeat_length]
%   How okay is Antony method to near-degenerate offsets? probably not too well?

opts.Fs = 1e3; %Fsamp, Hz
opts.fil = 10; %RTH filter half-width, pts
opts.binsz = 0.2; %RTH bin size, bp
opts.binsm = 1; %RTH gaussian smoothing SD, bp (!)
opts.per = 239; %Repeat period, bp
opts.pauloc = 236; %Where to place the strongest pause
opts.n = 8; %Number of repeats

opts.method = 1; %1: work on median RTH, 2: work on raw RTH

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Make cell if it isn't (though, woulnd't really work on just one trace)
if ~iscell(tr)
    tr = {tr};
end

%Set up options for generating RTH
rthopts = opts; %Use rthopts as a base
rthopts.verbose = 0; %Dont plot
rthopts.shift = 0; %Dont shift x-axis
rthopts.roi = [0 opts.n*opts.per]; %Will nan-pad any shorties
rthopts.normmeth = 1;

len = length(tr);
xs = [];
ys = cell(1,len);
yraw = cell(1,len);
for i = 1:len
    %Make RTH. Cant use RTH from rulerAlignV2 because that X-axis is distorted
    [y, x] = sumNucHist(tr{i}, rthopts);
    
%     %Smooth
%     y = windowFilter(@mean, y, ceil(opts.binsm/opts.binsz/2), 1);
    
    %Average across repeats. Assume per/binsz is integer
    yavg = y;
        %     yavg = median( reshape(y, [], opts.n), 2, 'omitnan');
    %Smooth
    yavg = gausmooth(yavg, opts.binsm, opts.binsm, 1);
    
    yraw{i} = y;
    ys{i} = yavg; 
    xs = x;
end

% outx = xs;
outx = xs(1:length(xs)/opts.n);

% %Do logspace for 'likelihood'
% ys = cellfun(@log, ys, 'Un', 0);

% For now, just do 'pause' and 'regular' by limiting to 2
yceil = cellfun(@(x)min(x,3), ys, 'Un', 0);

% outy = getCircConsensus(ys);
[outy, yalnraw, yshift] = getCircConsensusV2(yceil, struct('initmeth', 2));
% yalnraw = cellfun(@exp, yalnraw, 'Un', 0);

yalnraw = cellfun(@(x,y) circshift(x,[y 0]), ys, num2cell(yshift), 'Un', 0);
outy = median( reshape([yalnraw{:}], [], opts.n*len), 2, 'omitnan');

% outyraw = getCircConsensus(yraw);
% figure, plot(xs, outyraw);
figure, hold on, cellfun(@(x) plot(xs, x), yalnraw)

[~, maxi] = max(outy);
outy = circshift(outy, [round( opts.pauloc/opts.binsz) - maxi , 0]);

% outy = median( reshape(outy, [], opts.n), 2, 'omitnan');

figure('Name', 'Repeats Aligned'), plot(outx, outy);