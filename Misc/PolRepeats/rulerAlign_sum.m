function [out, outrpt]= rulerAlign_sum(intr, inOpts)

%Sums together multiple different alignments and builds a RTH for the repeats and overall

opts.normmeth = 1; %Normalization method: Median (1) or mean (2) or ...

%Takes rulerAlign's output and creates summed residence time histograms (RTHs)

%Filtering
opts.binsz = 0.1; %RTH binsize
opts.roi = [-100 2e3]; %Region of interest. Must use non-inf

%Options from rulerAlign that are used (unused commented out)
%Filtering options
opts.filwid = 20; %Smoothing filter half-width
opts.binsm = 20; %Residence time histogram filter half-width
opts.persmsd = 0.5; %Smooth the period scores with a gaussian filter of this std (bp)
opts.offsmsd = 1; %Smooth the offset scores with a gaussian filter of this std (bp)

%Options: Repeat pause characteristics
opts.start = tra(1); %Start position, bp
opts.pauloc = [83 108 141 168 236]; %Known pause location
opts.paustr = [.15 .25 .15 .25 .25]; %Known pause strength (taken from doi:10.1038/s41467-018-05344-9)
opts.per = 239; %Repeat length, bp
opts.persch = [.9 1.1]; %Search range, proportion of period
opts.perschd = .05; %Granularity of search, bp; also doubles as the bin size [was .025nm in Antony code, which is .07bp]
opts.nrep = 8; %Number of repeats


if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if ~iscell(intr)
    intr = {intr};
end

len = length(intr);
ycs = cell(1,len);

%Make binsz an integer divisor of per
nptspper = round(opts.per/opts.binsz);
opts.binsz = opts.per/nptspper;

%For each trace
for i = 1:len
    %Compute the residence time
    [y, x] = nhistc(intr{i}, opts.binsz);
    %Pad front and end with NaNs
    if x(1) > opts.roi(1)
        npad = ceil(x(1) - opts.roi(1) ) / opts.binsz;
        y = [nan(1,npad) y]; %#ok<*AGROW>
        x = [x(1) - (1:npad) * opts.binsz x];
    end
    if x(end) < opts.roi(2)
        npad = ceil(opts.roi(2) - x(end)) / opts.binsz;
        y = [y nan(1,npad)];
        x = [x x(end) + (1:npad) * opts.binsz];
    end
    
    %Crop to the ROI
    ki = x >= opts.roi(1) & x <= opts.roi(2);
    
    %Apply crop
    xc = x(ki);
    yc = y(ki);
    %These should all be the same length, = diff(roi)/binsz + 1
    
    %Renormalize: Say median(yc) == 1
    yc = yc / median(yc, 'omitnan');
    
    %Save the yc
    ycs{i} = yc(:);
end

%Take the median, omitnan to ignore cropped regions
ycm = [ycs{:}]; %ycs is column arrays, so this makes a matrix
out = median(ycm, 2, 'omitnan')'; %Take median, make row

%Make RTH by cropping, reshaping ycm
%Make sure ROI contains the region
if all( [0 opts.per*opts.nrep] >= roi(1) & [0 opts.per*opts.nrep] <= roi(2) )
    in0 = find(x == 0, 1, 'first');
    ycmc = ycm(in0 + (1:nptspper*opts.nrep) -1, :);
    %Cut this and reshape using mat2cell
    ycmc = mat2cell(ycmc, nptsper * ones(1,opts.nrep), size(ycmc, 2));
    ycmc = [ycmc{:}];
    outrpt = median(ycmc, 2, 'omitnan');
else
    outrpt = [];
    if nargout > 1
        warning('ROI doesn''t contain start position (0), no repeat histogram generated')
    end
end

figure, plot(xc, out)