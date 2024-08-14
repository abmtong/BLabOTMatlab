function vol2gif(infp)
%Volume data to gif

if nargin < 1
    [f p] = uigetfile('*.tif');
    infp = fullfile(p,f);
end

%Open image
img = bfOpen3DVolume(infp);
img = img{1}{1};

% 
% %Get contrast
% maxint = 
% 
% %Convert to indexed color

pp = 'vol2gif';
if ~exist(pp, 'dir')
    mkdir(pp)
end


%Autocontrast
maxpx = max(max(max(img)));
imggif = uint8 (double(img) / double(maxpx) * 255);
% imggif = 

%Reshape to to LxWx1xN
sz = size(imggif);
imggif = reshape(imggif, sz(1), sz(2), 1, sz(3));

imwrite(imggif, fullfile(pp, 'vol2gif_%03d.gif'), 'gif', 'LoopCount', inf, 'DelayTime', 0.25)

% %Output png
% for i = 1:size(img, 3)
%     imwrite( img(:,:,i), fullfile(pp, sprintf('vol2gif_%03d.png', i)), 'png')
%     
% end

%Convert to gif with photoshop...


