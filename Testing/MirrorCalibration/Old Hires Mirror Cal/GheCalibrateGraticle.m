function [k X Y p]=GheCalibrateGraticle()
% This function loads in a TIF image of a graticle with vertical or 
% horizontal stripes and calculates how many nanometers correspond to a 
% pixel.
% 
% [k X Y p]=GheCalibrateGraticle()
%
% Gheorghe Chistol, May 5th, 2009
% Corrected a bad mistake at the end, May 3rd 2010
% Should get ~170nm/pixel with the High Res Tweezer setup
%

%Pick the tif image file
[FileName,PathName] = uigetfile('*.tif','Select the TIF-image of a Vertical Graticle ');
img = imread([PathName,FileName]); %Load the initial image
iptsetpref Imshowborder tight; %Display preference
imshow(img); %Show the original image

h=helpdlg('Please Crop the Graticle Image','Graticle Image Cropping');
uiwait(h); %pop a dialog box and tell the user to do cropping

imgcrop=imcrop(img); %Crop the Image
imshow(imgcrop); %show the cropped image

imgadj = imadjust(imgcrop); %adjust the image
imshow(imgadj);

level = graythresh(imgadj); %apply automatic threshold to the image
bw = im2bw(imgadj,level); %create the bw image

bw = ~bw; %invert the bw image, for matlab edge detection
bw = bwareaopen(bw, 50); %remove the noise with area under 50 pixels

bw=~bw; %Invert again, in attempt to reduce more noise
bw = bwareaopen(bw, 50); %remove more noise
bw=~bw; %invert back and keep it here

[B, L]=bwboundaries(bw,'noholes'); %find the boundaries of the stripes
numRegions = max(L(:));
imshow(label2rgb(L)); %show the regions that are found using different colors

stats = regionprops(L,'all'); %calculate the properties of the current selections
shapes = [stats.Eccentricity]; %look at the eccentricity
keepers = find(shapes>0.6); %lines have eccentricities close to 1

imshow(bw); %Display the lines with a blue outline
for index=1:length(keepers)
    outline=B{keepers(index)};
    line(outline(:,2),outline(:,1),'Color','b','LineWidth',2);
end

[Height Width]=size(bw);

if Width>Height 
    %horizontal pixel calibration
    %look at the centroids
    for i=1:length(keepers)
        Y(i) = stats(keepers(i)).Centroid(1);
        X(i) = i;
    end
    PixelType = 'horizontal';
else
    %vertical pixel calibration
    for i=1:length(keepers)
        Y(i) = stats(keepers(i)).Centroid(2);
        X(i) = i;
    end
    PixelType = 'vertical';
end
    

p = polyfit(X,Y,1);%fit a line through those points
Yfit = polyval(p,X); %calculate the fit
%k=10/((Y(end)-Y(1))/X(end)-X(1)-1)*1000; %this number is in nanometers/pixel
k=10000/p(1); %this number is in nanometers/pixel

figure; 
plot(X, Y,    '.b', ... 
     X, Yfit, '-b'); %Plot the points and the best fit
 
msgbox(['The ',PixelType,' pixel conversion coefficient is k=',num2str(k),'nm/pixel']);