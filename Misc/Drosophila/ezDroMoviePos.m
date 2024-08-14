function out = ezDroMoviePos(movimg, emimg, inOpts)
%Finds where a movie was taken compared to the full embryo
% Relies on the bleaching of the surface patch where the movie was taken

%Input: movimg (last frame of movie) and emimg (embryo surface image)

opts.relzoom = .568/.212; %Relative zoom sizes, = ratio of pixel sizes of full embryo / movie
opts.fil = 2; %Gaussian filter, px, for xcorr
opts.bkgwid = 5; %strel disk size for background subtraction for normxcorr2
opts.verbose = 1; %Plot

if nargin > 2
    opts = handleOpts(opts, inOpts);
end

%Blow up embryo image to equalize pixel size
emimgz = imresize(emimg, opts.relzoom);

%Take 2D correlation to find overlap px
% Maybe enlarge both images more to get subpx accuracy?

%Take xcorr
xc = normxcorr2( imgaussfilt(movimg, opts.fil), imgaussfilt(emimgz, opts.fil) );

%Look for the largest spike in xcorr: subtract background
xcb = imdilate(xc, strel('disk', opts.bkgwid)) - xc;
% (If the movie has uneven background, it could correlate greater with the edge of the embryo)

%But the background subtraction makes the spike into a disk: find this disk and get centroid
xcbbw = im2bw( xcb, max( xcb(:) )/2);
xcbbw = imfill(xcbbw, 'holes');

%Take largest hole's centroid
rp = regionprops(xcbbw, 'Centroid', 'Area');
ar = [rp.Area];
[~, maxi] = max(ar);
pos = rp(maxi).Centroid;

%This position marks the upper-right corner of the overlap region
%Convert to bottom-left corner
pos = pos - fliplr(size(movimg)) + 1;

%And convert to original px dims
pos = (pos-1) / opts.relzoom +1;

%Save this as [origin, scale]
out = [pos 1/opts.relzoom];

if opts.verbose
    figure
%     surface( zeros(size(emimg)), emimg, 'EdgeColor', 'none')
    surface( zeros(size(emimg)),imgaussfilt( emimg, opts.fil/2), 'EdgeColor', 'none')
    hold on
    colormap jet
    
    %Corner is proobably not covered, so draw the movie image there
    surface( zeros(size(movimg)), imgaussfilt( movimg, opts.fil/2), 'EdgeColor', 'none')
    
    
    %And draw the detected rectangle
    rectangle('Position', [ out(1:2), fliplr(size(movimg)) / opts.relzoom], 'EdgeColor', [1 1 1], 'LineWidth', 1 )
    axis tight
end
