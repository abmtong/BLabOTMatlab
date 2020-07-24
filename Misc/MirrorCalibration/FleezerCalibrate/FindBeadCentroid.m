function outPos = FindBeadCentroid(inImg)

iptsetpref Imshowborder tight; %Display preference for @imshow

%convert to gray if rgb
if size(inImg, 3) > 1
    inImg = rgb2gray(inImg);
end
imsz = fliplr(size(inImg));
cpbx = [imsz*.1 imsz*.8];

%Process the image, taken from Ghe
im1 = wiener2(inImg, [4 4]); %Apply Adaptive Filtering to remove extra noise
im2 = imadjust(im1); %Adjust the Image, Enhance Contrast
bkg = imopen(im2,strel('disk',3)); %Remove Non-Uniform Background
im3 = im2 - bkg;
im4 = imcrop(im3, cpbx); %crop the region of interest
im5 = im2bw(im4, graythresh(im4)); %create the bw image

% figure, imshow(im1);
% figure, imshow(im2);
% figure, imshow(im3);
% figure, imshow(im4);
% figure, imshow(im5);

%do hacking here
im5 = ~im2bw(imcrop(im2, cpbx), .45);

%Find bead boundaries. 'noholes' counts bullseye patterns as one region
[bdys, labelimg] = bwboundaries(im5,'noholes');
%Get boundary properties
rprops = regionprops(labelimg,'all');

%If no regions, return
if isempty([rprops.Area])
    outPos = [-1 -1];
    return
end

%If only one region is left, great; else need to pick the one most likely to be the bead
switch length([rprops.Area])
    case 0
        return
    case 1
        bdys = bdys{1};
    otherwise
        %Score based on area and eccentricity
        rarea = [rprops.Area];
        goodarea = 20;
        rarea = min( rarea / goodarea, 1 );
        recc = [rprops.Eccentricity];
        rsc = rarea/max(rarea) - recc;
        [~, keepind] = max(rsc);
        rprops = rprops(keepind);
        bdys = bdys{keepind};
end

%Show image with bead circled, cross on centroid
imshow(imcrop(inImg, cpbx));
line(bdys(:,2),bdys(:,1),'Color','b','LineWidth',2);
outPos = rprops.Centroid;
crosswid = 10; %px
line(outPos(1) * [1 1], outPos(2) * [1 1] + crosswid * [-1 1], 'Color', 'g');
line(outPos(1) * [1 1] + crosswid * [-1 1], outPos(2) * [1 1], 'Color', 'g');
end