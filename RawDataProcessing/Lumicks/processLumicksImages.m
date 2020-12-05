function processLumicksImages(contr)
%Processes a bunch of Lumicks hdf5 images and saves them to .tif
%Run this, and select the files on the filepicker
% Input: contr is the contrast factor, leave empty / unpassed to do autocontrast, 
%    else pass as a number to set maximum contrast: try 256

if nargin < 1
    contr = [];
end

[f, p] = uigetfile('*.h5', 'Mu', 'on');

if ~p
    return
end

if ~iscell(f)
    f = {f};
end

len = length(f);

%Load file
for i = 1:len
    file = f{i};
    try
        tmp = readh5all(fullfile(p, file));
    catch
        warning('File %s failed to read. Skipping.', file);
        continue
    end
    
    %Check that we have RGB+Infowave
    fns = fieldnames(tmp);
    nms = {'Infowave_Infowave', 'Photoncount_Green', 'Photoncount_Blue', 'Photoncount_Red'};
    if ~all(cellfun(@(x) any( strcmp( x, fns )), nms))
        warning('File %s doesn''t have Infowave or Photoncounts. Skipping.', file)
        continue
    end
    
    %Draw images
    imr = drawimageV2(tmp.Infowave_Infowave, tmp.Photoncount_Red);
    img = drawimageV2(tmp.Infowave_Infowave, tmp.Photoncount_Green);
    imb = drawimageV2(tmp.Infowave_Infowave, tmp.Photoncount_Blue);
    
    %Assemble to one image
    img(:,:,1) = imr;
    img(:,:,2) = img;
    img(:,:,3) = imb;
    
    %Contrast
    if isempty(contr)
        contr = max(img(:));
    end
    img = img/contr;
    
    %Save
    [~, fn, ~] = fileparts(file);
    imwrite(img, fullfile(p, [fn '.tif']))
    
    figure, imshow(img) %Comment out this file if you don't want it to plot the image every time
end