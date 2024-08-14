function ezDro2gif(inst, nam)

%Just take the data from ezDrosophila output and write to gif

%Just use the same 'vol2gif' folder as vol2gif uses
pp = 'vol2gif';
if ~exist(pp, 'dir')
    mkdir(pp)
end

if nargin < 2
    nam = inputname(1);
end

%Get image size
sz = size(inst(1).img);


%Load data to LxWx1xN
len = length(inst);
frs = [inst.frame];
chs = [inst.ch];

%Check if 1 or 2 chs are supplied, if 2, paste side-by-side
if length(chs) == 1
    imgs = zeros(sz(1), sz(2), 1, len);
    nch = 1;
else
    nch = 2;
    len = len/2;
    imgs = zeros(sz(1), sz(2), 1, len);
    imgs2 = zeros(sz(1), sz(2), 1, len);
end


for i = 1:len
    imgs(:,:,1,i) = inst(i).img;
    if nch == 2 %if nch == 2, also add second channel
        imgs2(:,:,1,i) = inst(i+len).img;
    end
end


%Autocontrast, save as uint8
maxpx = max((imgs(:)));
imggif = uint8 (double(imgs) / double(maxpx) * 255); %Is there a better way to do this?
if nch == 2
    maxpx2 = max((imgs2(:)));
    imggif2 = uint8 (double(imgs2) / double(maxpx2) * 255);
    %And assemble to two images
    imggif = [imggif imggif2];
end

%Add a grey frame at the start. Is there a better way to do this?
sz = size(imggif);
tmp = zeros ( sz + [0 0 0 1] , 'uint8');
tmp(:,:,1,1) = 128 * ones( sz(1:2) );
tmp(:,:,1,2:end) = imggif;
imggif = tmp;

%Save as gif
imwrite(imggif, fullfile(pp, sprintf('ezDro2gif_%s_%s.gif',nam, datestr(now, 'YYmmDDHHMMSS'))), 'gif', 'LoopCount', inf, 'DelayTime', 0.1)

% %Output png
% for i = 1:size(img, 3)
%     imwrite( img(:,:,i), fullfile(pp, sprintf('vol2gif_%03d.png', i)), 'png')
%     
% end

%Convert to gif with photoshop...


