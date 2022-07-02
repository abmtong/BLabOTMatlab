function [out, xc, ycs] = sumNucHist(intr, inOpts)

%RTH options
opts.binsz = 0.5; %RTH binsize, best if this divides 1
opts.roi = [-inf inf]; %Region of interest
opts.normmeth = 2; %1= 1/median, 2= s/bp; seems no real difference? (median is used to average across traces either way)
opts.Fs = 3125;
opts.fil = 10; %Filter
opts.binmeth = 1; %=1, pt in bin = count ; =2, 'Antony method' : Draw a line between adjacent points, relative length in bin = count
opts.prc = 50; %Percentile(s) ; 50 default is median

%Display options
opts.verbose = 1;
opts.disp = [558 631 704]-16; %Location of lines
opts.shift = 558-16+1; %Shift x-vals by this much

%Pause info
opts.pauloc = 59;
opts.per = 64;
opts.nrep = 8;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if ~iscell(intr)
    intr = {intr};
end

%Handle ROI inf
if isinf(opts.roi(1))
    opts.roi(1) = min( cellfun(@min, intr) );
end
if isinf(opts.roi(2))
    opts.roi(2) = max( cellfun(@max, intr) );
end

len = length(intr);
ycs = cell(1,len);

%For each trace
for i = 1:len
    %Compute the residence time
    trF = windowFilter(@mean, intr{i}, opts.fil, 1);
    switch opts.binmeth
        case 1 %Normal binning: @nhistc
            [~, x, ~, y] = nhistc(trF, opts.binsz);
        case 2 %Antony method
            [y, x] = antonyBin(trF, opts.binsz);
    end
    %Pad front and end with NaNs, if necessary
    if x(1) > opts.roi(1)
        npad = ceil(x(1) - opts.roi(1) ) / opts.binsz;
        y = [nan(1,npad) y];
        x = [x(1) - fliplr(1:npad) * opts.binsz x];
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
    
    %Normalize
    switch opts.normmeth
        case 1 %Norm to median
            yc = yc / median(yc, 'omitnan');
        case 2 %Convert from counts to bp/s
            yc = yc / opts.Fs / opts.binsz;
    end
    
    
    
    %Save the yc
    ycs{i} = yc(:);
end

%Take the median, omitnan to ignore cropped regions
ycm = [ycs{:}]; %ycs is column arrays, so this makes a matrix
% sds = std(ycm, [], 2, 'omitnan');
% ycm = median(ycm, 2, 'omitnan');
ycm = prctile(ycm, opts.prc, 2); %Seems that @prctile automatically omits nans?

out = ycm';

%Eh this dont quite work
% %Check for offset by shifting a trace up or down by opts.per and dotting into each other
% offs = zeros(1,len);
% nshift = opts.per/opts.binsz ;%Make sure this is an integer
% if mod(nshift,1)
%     nshift = round(nshift);
%     warning('Binsize does not divide period, offset alignment will be weird')
% end
% for i = 1:len
%     %Search up to +- 2, say
%     srch = -2:2;
%     scrs = zeros(size(srch));
%     for j = 1:length(srch)
%         dind = srch(j) * opts.per;
%         if dind < 0 %Pad left
%             y = [nan(1,abs(dind)) ycs{i}(1:end-abs(dind))' ];
%         else %Pad right
%             y = [ycs{i}(1+abs(dind):end)'  nan(1,abs(dind))];
%         end
%         ki = ~(isnan(y) | isnan(out));
%         ysum = sum(y(ki));
%         ycsum = sum(out(ki));
% 
%         %Calculate score by inner product [normalize by n pts]
%         y = y .* out;
%         scrs(j) = sum(y, 'omitnan') / sum(ki) / ysum / ycsum;
%     end
%     [~, maxi] = max(scrs);
%     offs(i) = srch(maxi);
%     %Apply this guy
%     if offs(i)
%         fprintf('Trace %d shifted by %d periods\n', i, offs(i))
%         plotNucHist({xc xc xc+offs(i)*opts.per}, {out ycs{i} ycs{i}} , opts)
%     end
% end

%Document 

if opts.verbose
    plotNucHist(xc, out, opts)
end