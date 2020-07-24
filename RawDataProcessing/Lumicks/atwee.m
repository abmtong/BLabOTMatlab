%@ Wee, how to use this

%Here's a script that does it.

%This reads all the raw data from the h5 file. Pick it using the file picker.
dat = readh5all();
%Now we need to get the R/G/B images.

% imr = drawimage(dat.Infowave_Infowave, dat.Photoncount_Red, 1);
% img = drawimage(dat.Infowave_Infowave, dat.Photoncount_Green, 1);
% imb = drawimage(dat.Infowave_Infowave, dat.Photoncount_Blue, 1);

imr = drawimageV2(dat.Infowave_Infowave, dat.Photoncount_Red);
img = drawimageV2(dat.Infowave_Infowave, dat.Photoncount_Green);
imb = drawimageV2(dat.Infowave_Infowave, dat.Photoncount_Blue);

%These are image reels of the R/G/B photoncounts.

%We need to assemble them into one image
imrgb(:,:,1) = imr;
imrgb(:,:,2) = img;
imrgb(:,:,3) = imb;

%Matlab expects an image using type double to have values in [0 1], so rescale for proper contrast
imrgb = imrgb - min(imrgb(:));
imrgb = imrgb / max(imrgb(:));

%And plot
figure, imshow(imrgb);

%And save to file
imwrite(imrgb, 'lumfile.tif')