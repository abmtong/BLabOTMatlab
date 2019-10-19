function out = trackAvi(inpf)
%Sanity: write own orientation processor
%Consistent with what RotationTracker outputs
%Seems noisier, takes much longer (~1e2fps vs 1e4fps)
% But nice to have independent confirmation
%Need to implement rotation # tracking (right now just outputs angle and centroid)
% i.e. convert to diff(theta), constrain to [-180 180], then cumsum([theta(1) dth])

if nargin < 1
    [f, p] = uigetfile('*.avi');
    inpf = [p f];
end

vr = VideoReader(inpf);
len = round(vr.Duration * vr.FrameRate);

xs = zeros(1,len);
ys = zeros(1,len);
rs = zeros(1,len);
tic
for i = 1:len
    fr = readFrame(vr);
    im = wiener2(fr, [4 4]); %Apply Adaptive Filtering to remove extra noise
    im = imadjust(im); %Adjust the Image, Enhance Contrast
    
    %this strel disk doesn't seem to change the result; remove
%     bkg = imopen(im,strel('disk',3)); %Remove Non-Uniform Background
%     im = im - bkg;
    im = im2bw(im, graythresh(im)); %create the bw image
%     [~, labelimg] = bwboundaries(im5,'noholes');
    %Get boundary properties
    rprops = regionprops(im,{'Area' 'Centroid' 'Orientation'});
    [~,ri] = max([rprops.Area]);
%     bdy = bdys(ri);
    cen = rprops(ri).Centroid;
    xs(i) = cen(1);
    ys(i) = cen(2);
    rs(i) = rprops(ri).Orientation;
    if ~mod(i,1e4)
        toc
        return
    end
end
toc
out.x = xs;
out.y = ys;
out.r = rs;