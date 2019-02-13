function outconv = GratingCalc()

[~, mp, ~] = fileparts(mfilename);
[f, p] = uigetfile([mp '\*.*'], 'Select the image of the grating along X');

%Crop
crp = ChooseCrop(p, f);

im = imread([p f]);
im1 = imcrop(im, crp);
%convert if not grayscale
if size(im1, 3) > 1
    im1 = rgb2gray(im1);
end

imx = -sum( double(im1), 1);
imx = imx - min(imx);
imx = imx / max(imx);

[~, lc] = findpeaks(imx, 'MinPeakProminence', .2);

figure, imshow(im1)
hold on
plot(imx * size(im1, 1))

dlc =  diff(lc);
xpos = ( lc(1:end-1) + lc(2:end) ) /2;

for i = 1:length(lc)-1
    text(xpos(i), 0.5*size(im1, 1), sprintf('%0.2f', dlc(i)))
end

outconv = mean(dlc);
