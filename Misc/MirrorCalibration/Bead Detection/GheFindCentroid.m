function out = GheFindCentroid()

Img = imread('twobeads10v.tif');

%Img = mat2gray(ImageMatrix, [0 255]);  %convert the matrix to a grayscale image - what LabVIEW gives you
iptsetpref Imshowborder tight; %Display preference

CropBox = [250   210   100    100]; %Define Crop region
XCropBox = [CropBox(1)-10 CropBox(2)-10 CropBox(3)+20 CropBox(4)+20]; %extended box 

ImgXCrop = imcrop(Img, XCropBox); %extended crop
ImgFilt = wiener2(ImgXCrop, [4 4]); %Apply Adaptive Filtering to remove extra noise
ImgAdj = imadjust(ImgFilt); %Adjust the Image, Enhance Contrast
Bkgr = imopen(ImgAdj,strel('disk',3)); %Remove Non-Uniform Background
ImgBkgr = ImgAdj - Bkgr;
ImgCrop = imcrop(ImgBkgr, [10 10 CropBox(3) CropBox(4) ]); %crop the region of interest
ImgBW = im2bw(ImgCrop, graythresh(ImgCrop)); %create the bw image

[B, L] = bwboundaries(ImgBW,'noholes'); %find the boundaries of the beads

stats     = regionprops(L,'all');            %calculate the properties of the current selections
Area  = [stats.Area];                        %look at the area
Ecce  = [stats.Eccentricity];                %look at the eccentricity
AreaKeepers = find( (Area>20) );  %go by the area of the bead image
EcceKeepers = find(Ecce<1);                  %go by the eccentricity
keepers=[];
%find the common keepers
for i=1:length(AreaKeepers)
     for j=1:length(EcceKeepers)
      if AreaKeepers(i)==EcceKeepers(j)
       keepers=[keepers AreaKeepers(i)];
       end
     end
end

ImgDisp=imcrop(Img, CropBox);
imshow(ImgDisp); %Display the lines with a blue outline
set(gcf,'Units','normalized','Position',[0.004 0.56 0.3 0.38]);

for index = 1:length(keepers)
    outline = B{keepers(index)};
    line(outline(:,2),outline(:,1),'Color','b','LineWidth',2);
    Centroid{index}=stats(keepers(index)).Centroid;
end

D=5; %Once the centroid is found, plot a cross going through the centroid
% watch out, the coordinates are measured from the top left corner, 
% X measured from left to right
% Y measured from top to bottom 
for i=1:length(keepers)
    X=[Centroid{i}(1) Centroid{i}(1)];
    Y=[Centroid{i}(2)-D Centroid{i}(2)+D];
    line(X,Y,'Color','g')
    X=[Centroid{i}(1)-D Centroid{i}(1)+D];
    Y=[Centroid{i}(2) Centroid{i}(2)];
    line(X,Y,'Color','g')
end

if length(keepers)~=2
    X1=-100; %if we can't find exactly two beads, put in some negative token values
    Y1=-100;
    X2=-100;
    Y2=-100;
else
    %the first bead is the one on the left
    if Centroid{1}(1)<Centroid{1}(2)
        X1 = Centroid{1}(1);
        Y1 = CropBox(4)-Centroid{1}(2); %now Y is measured from bottom to the top, like Cartesian Coord
        X2 = Centroid{2}(1);
        Y2 = CropBox(4)-Centroid{2}(2); %now Y is measured from bottom to the top, like Cartesian Coord
    else
        X1 = Centroid{2}(1);
        Y1 = CropBox(4)-Centroid{2}(2); %now Y is measured from bottom to the top, like Cartesian Coord
        X2 = Centroid{1}(1);
        Y2 = CropBox(4)-Centroid{1}(2); %now Y is measured from bottom to the top, like Cartesian Coord
    end
end

out = [X1, X2, X2-X1; Y1, Y2, Y2-Y1];

end