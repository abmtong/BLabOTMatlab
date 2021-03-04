function [out, xc] = plotNucHist(intr, inOpts)
%ZJ's version is a bit more developed [+filtering]

opts.binsz = 0.1; %RTH binsize
opts.roi = [600 800]; %Region of interest

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(intr);
ycs = cell(1,len);

%For each trace
for i = 1:len
    %Compute the residence time
    [y, x] = nhistc(intr{i}, opts.binsz);
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
    
    %Renormalize: Say median(yc) == 1
    yc = yc / median(yc, 'omitnan');
    
    %Save the yc
    ycs{i} = yc(:);
end

%Take the median, omitnan to ignore cropped regions
ycm = [ycs{:}]; %ycs is column arrays, so this makes a matrix
ycm = median(ycm, 2, 'omitnan');

out = ycm;

figure, plot(xc, out)
