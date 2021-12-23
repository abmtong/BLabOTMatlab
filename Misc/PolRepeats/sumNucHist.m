function [out, xc, ycs] = sumNucHist(intr, inOpts)
%ZJ's version is a bit more developed [+filtering]

%RTH options
opts.binsz = 0.5; %RTH binsize, best if this divides 1
opts.roi = [-200 800]; %Region of interest
opts.normmeth = 2; %1= 1/median, 2= s/bp; seems no real difference? (median is used to average across traces either way)
opts.Fs = 3125;

%Display options
opts.disp = [558 631 704]-16; %Location of lines


%Pause info
opts.pauloc = 59;
opts.per = 64;
opts.nrep = 8;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(intr);
ycs = cell(1,len);

%For each trace
for i = 1:len
    %Compute the residence time
    [~, x, ~, y] = nhistc(intr{i}, opts.binsz);
    %Pad front and end with NaNs
    if x(1) > opts.roi(1)
        npad = ceil(x(1) - opts.roi(1) ) / opts.binsz;
        y = [nan(1,npad) y];
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
    
    %Normalize
    switch opts.normmeth
        case 1 %Norm to median
            yc = yc / median(yc, 'omitnan');
        case 2 %Convert to bp/s
            yc = yc / opts.Fs / opts.binsz;
    end
    
    %Save the yc
    ycs{i} = yc(:);
end

%Take the median, omitnan to ignore cropped regions
ycm = [ycs{:}]; %ycs is column arrays, so this makes a matrix
ycm = median(ycm, 2, 'omitnan');
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


plotNucHist(xc, out, opts)