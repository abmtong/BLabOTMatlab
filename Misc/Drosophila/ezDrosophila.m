function out = ezDrosophila(imgfp, mskfp, inOpts)
%Just do it DUMB LIKE

%Debug plots
opts.debug = 0;

%Thresholding options
opts.thrmeth = 2; %See below/code for meaning
% Options for thrmeth == 1: Hard threshold
opts.thr = 5000; %Just use this one. It's 'sensible' since the maps are chance > 0-1e4
% Options for thrmeth == 2: relative to max
opts.thrmult = 0.5; %thr = max value * thrmult
% Options for thrmeth == 3: Percentile plus some flat amount
opts.prcthr = 97; %Percentile threshold
opts.prcthradd = 2; %Additional thr

%Peak detection method
opts.peakmeth = 3; %See code for meaning
opts.peakrad = 5; %Just take a circle with this raidus around the peaks 

%Region cutoffs, set empty to skip selection by this criteria
opts.area = [];% [5 250]; %Acceptable area range, else reject
opts.ecc =  [];%[0 .5]; %Acceptable eccentricity

% opts.prcrng = [1e3 5e3]; %Percentile range, culls if outside it

%Image processing options
opts.zrange = 2:10; %Take max over this Z-range

%Background quantification method
opts.bkgrad = 3; %Radius of circle for background detection, i.e. spot is ~this size
opts.mskbkgrad = 7; %Same but for mask, which is bigger circles (so needs bigger strel)
% opts.dilate = 1; %Dilation amount for hotspot detection
% opts.dilatebkg = 3; %Dilation amount for background detection

% if nargin >= 3
%     opts = handleOpts(opts, inOpts);
% end

if nargin < 1 || isempty(imgfp)
    [f, p] = uigetfile('*.tif');
    if ~p
        return
    end
    imgfp = fullfile(p,f);
end

if nargin < 2 || isempty(mskfp)
    [f, p] = uigetfile('*.tif');
    if ~p
        return
    end
    mskfp = fullfile(p,f);
end


%Load files. Matlab R2016a doesnt support loading tif stacks, so use bfmatlab
%bfOpen3DVolume will pop a file selector if the file doesn't exist, lets bypass this and error instead
assert(exist(imgfp, 'file') == 2, sprintf('File %s not found', imgfp))
assert(exist(mskfp, 'file') == 2, sprintf('File %s not found', mskfp))
img = bfOpen3DVolume(imgfp);
img = img{1}{1};

msk = bfOpen3DVolume(mskfp);
msk = msk{1}{1};

%Spots dont change along Z, so lets just max over a Z-range. Zs too high/low can look weird, so skip
img = max(img(:,:,opts.zrange), [], 3);
msk = max(msk(:,:,opts.zrange), [], 3);

%Save the raw image here
imgraw = img;

%Choose threshold for spot detection: higher = spot detected
switch opts.thrmeth
    case 1 %Just a hard threshold
        thr = opts.thr;
    case 2 %Dynamic thresholding, based on max value
        thr = max( msk(:) ) * opts.thrmult;
    case 3 %Dynamic thresholding, based on percentile
        thr = prctile( msk(:), opts.prcthr ) + opts.prcthradd;
end

switch opts.peakmeth
    case 0 %Thresholding
        %And apply this threshold
        mskthr = msk >= thr;
    case 3 %Thresholding with background subtraction
        bkg = imopen(msk, strel('disk', opts.mskbkgrad) );
        mskbkg = double(msk) - double(bkg) + median(bkg(:)); %Re-add background? or change thr?
        mskthr = mskbkg >= thr ;
        
    case 1 %Peakfinding with @FastPeakFind (file exchange)
        %Gaussian filter to make peak detection less noisy?
        mskbkg = imgaussfilt(msk, 2) ;
        
        pks = FastPeakFind(mskbkg);
        %pks = coords of peaks in x,y format, reshape to be more suitable
        pks = reshape(pks, 2, [])';
        %So let's just make these binary peaks and then widen with imdilate
        mskthr = zeros(size(msk));
        for i = 1:size(pks, 1)
            mskthr( pks(i,2), pks(i,1) ) = 1;
        end
        mskthr = imdilate(mskthr, strel('disk', opts.peakrad) );
    case 2 %Peakfinding with findpeaks (file exchange)
        %Background subtract, so we can set a lower threshold for Peak Height
        mskbkg = double(msk) - double( imopen(msk, strel('disk', opts.bkgrad) ) );
        %Gaussian filter for findpeaks
        mskbkg = imgaussfilt(mskbkg, 2);
        %Do findpeaks. Set a minpeakheight to reject the low clutter
        peakdata = findpeaks2d_loop(mskbkg, 'MinPeakHeight', prctile(mskbkg(:), 90 ));
        %peakdata has x,y as peakdata.peakX and peakY
        
        %So let's just make these binary peaks and then widen with imdilate
        mskthr = zeros(size(msk));
        for i = 1:length(peakdata.peakX)
            mskthr( peakdata.peakY(i), peakdata.peakX(i) ) = 1;
        end
        mskthr = imdilate(mskthr, strel('disk', opts.peakrad) );
end

%Get regions and props
[bdys, mskthr] = bwboundaries(mskthr, 8, 'noholes' );
rp = regionprops(mskthr, {'Eccentricity', 'Centroid', 'Area', 'BoundingBox'});

%Filter reigonprops based on area, etc.
eccs = [rp.Eccentricity];
if opts.ecc
    ki1 = eccs >= opts.ecc(1) & eccs <= opts.ecc(2);
else
    ki1 = true(size(rp));
end

areas = [rp.Area];
if opts.area
    ki2 = areas >= opts.area(1) & areas <= opts.area(2);
else
    ki2 = true(size(rp));
end

%Combine rejection critera
ki = ki1 & ki2;

%Process base image: Background correction
bkg = imopen(img, strel('disk', opts.bkgrad));
imgbkg = double(img) - double(bkg); %Allow for negative numbers now, so convert to double

%And sum over spots
len = length(rp);
vals = cell(1,len);
for i = 1:len
    imgcrp = imgbkg( mskthr == i );
    vals{i} = sum( imgcrp(:));
    
end

%Get some additional regionprops to save
cens = {rp.Centroid};
bboxs = {rp.BoundingBox};

%Apply rejection critera

%Final data structure is a struct with fields image/mask/segments, segments is a struct with the image props

%So make the region props struct first
if len == 0 %Special case if no structures found
    rprops = [];
else
    rprops = struct('sum', vals, 'bbox', bboxs, 'cen', cens, 'area', num2cell(areas), 'ecc', num2cell(eccs), 'bdy', bdys' );
end
%And the final output
out = struct( 'img', img, 'imgraw', imgraw, 'msk', msk, 'rprops', rprops, 'ki', ki);

if opts.debug
    %Draw image
    figure
    ax = subplot(2,1,1);
    hold on
    surface(ax, zeros(size(imgbkg)), imgbkg, 'EdgeColor', 'none')
    axis equal
    %Draw circles on accepted regions
    for i = 1:len
        if ki(i)
            plot(ax,  rprops(i).bdy(:,2), rprops(i).bdy(:,1), 'g')
        end
    end
    colormap gray
    colorbar
    axis tight
    
    %And do the same for the mask
    ax = subplot(2,1,2);
        hold on
    surface(ax, zeros(size(msk)), msk, 'EdgeColor', 'none')
    axis equal
    %Draw circles on accepted regions
    for i = 1:len
        if ki(i)
            plot(ax, rprops(i).bdy(:,2), rprops(i).bdy(:,1), 'g')
        end
    end
    colormap gray
    colorbar
    axis tight
end

%Handle matching up multiple spots in downstream functions...

%{
%Get background. Objects are tiny, so need a tiny strel object
bkg = imopen(img, strel('disk', 1));

%And subtract away
img = img - bkg;

%Autothreshold
thr = prctile(img(:), opts.prcthr) + opts.prcthradd;

%Apply threshold
imgthr = img > thr;

%Widen regions with strel
imgthr = imdilate(imgthr, strel('disk', opts.dilate));

%Get regions
[~,L] = bwboundaries(imgthr, 8, 'noholes'); %L is a 'label img': img with region i having value i
%And get properties
rp = regionprops(L, 'Centroid'); %Probably switch from 'all' to just what we need later...
cens = reshape( [rp.Centroid], 2, [])' ; %Get centroids as 1x2
%Output: Integral over regions

len = max(L(:));
integs = zeros(1,len); %Pixel integral
areas = zeros(1,len); %ROI size
bkgpxmn = zeros(1,len); %Background pixel value, mean
bkgpxmd = zeros(1,len); %Background pixel value, median
for i = 1:len
    ki = L==i;
    areas(i) = sum(ki(:));
    integs(i) = sum( img(ki) );
    
    % Let's try to get some background... somehow... and subtract background
    % Enlarge the ROI by some amount
    ki2 = imdilate(ki, strel('disk', opts.dilatebkg) );
    %Get the background from this region (minus the original ROI)
    ki2 = ki2 & ~ki;
    crp = img(ki2);
    %And take the me/di/an of this region as background
    bkgpxmn(i) = mean(crp(:));
    bkgpxmd(i) = median(crp(:));
    %(Apply the background subtraction later)
end



%And save as output. Save the raw image, the label image, and the stats
out = struct( 'img', img, 'imgL', L, 'cens', cens, 'areas', areas, 'sums', integs, 'bkg', [bkgpxmn(:) bkgpxmd(:)] );
%}
%Then 

% figure, surface(( imdilate(bmax > 15, strel('disk', 1) )), 'EdgeColor', 'none'), colormap gray, colorbar, axis tight




%The goal is to use the dogs as a mask to find the points, and integrate every image.



