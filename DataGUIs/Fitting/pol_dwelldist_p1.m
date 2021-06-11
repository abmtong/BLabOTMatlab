function [out, isbt, trs] = pol_dwelldist_p1(data, inOpts)
%Takes in transcription data, fits a staircase and converts to dwelltimes

%Because of artifacts(?), short fitting is a bit wonk, leading to fitting of additional very fast decays.
% Maybe try limiting decay spds / further cropping short times? Or just handle after-the-fact

%Data options
opts.Fs = 4000/3; %For converting pts to time
opts.roi = [-inf inf]; %Steps of interest: will only take steps with means within the ROI
opts.dir = 1; %Translocation direction: positive or negative
%fitVitterbi options don't really matter, but they're here
opts.fvopts.dir = 0;
opts.fvopts.trnsprb = [1e-3 1e-100]; %Put a high penalty for backtracks, but let them occur -- will remove with removeTrBts
%Comparing a forced monotonic vs. backtrack-okay trace for one that is mostly monotonic doesn't make much of a difference - good
opts.fvopts.ssz = 1;
%fitVitterbi_batch takes a Fs input, but we won't use it [just for local plotting]

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%If data is struct, this is a struct of cells (eg for separate conditions) - batch
if isstruct(data)
    if nargout < 2
        warning('If you want to capture backtracks, make sure to capture the second output')
    end
    [out, isbt, trs] = structfun(@(x) pol_dwelldist_p1(x, opts), data, 'Un', 0);
    return
end

%If data is not a cell, make it one
if ~iscell(data)
    data = {data};
end

%Do fitVitterbi, take staircases. Dwell dist will be wrong if dir = -1
[~, trs] = fitVitterbi_batch(data, opts.fvopts);
%Remove empty (failed traces)
trs = trs(~cellfun(@isempty, trs));
%Join backtracks
[trs, isbt] = cellfun(@(x)removeTrBts(x, opts.dir), trs, 'Un', 0);
%Convert staircases to ind, mea
[dws, mes] = cellfun(@(x) tra2ind(x), trs, 'Un', 0);
%Sanity check means. Use eps-thresholded equals
if ~all(cellfun(@(x) all( abs(diff(x) * opts.dir - opts.fvopts.ssz) < 10*eps( max( max(abs(x)), opts.fvopts.ssz) )), mes))
    warning('Unknown Error: steps not uniform');
end

%Convert to dwells, and from points to time
dws = cellfun(@(x) diff(x) / opts.Fs, dws, 'Un', 0);
%Apply roi
out = cellfun(@(x,y) x(y>=opts.roi(1) & y <= opts.roi(2)), dws, mes, 'Un', 0);
