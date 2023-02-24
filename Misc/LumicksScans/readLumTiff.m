function out = readLumTiff( infp )
% Reads a multipage tiff file
if nargin < 1
    [f, p] = uigetfile('*.tif');
    infp = fullfile(p, f);
end

%Make sure file is okay
if ~exist(infp, 'file')
    warning('File %s not found', fileparts(infp))
    out = [];
    return
end

%Get total number of frames
nfo = imfinfo(infp);
%N frames is length of nfo
nfr = length(nfo);

%Also prep gif
[p, f, e] = fileparts(infp);
giffp = fullfile(p, [f '.gif']);
dt = 1/30; %gif framerate

%Load frames
for i = 1:nfr
    %Each imread loads a frame as a w x h x 3 array, we want to put this as a w x h x 3 x nfr array
    tmp = imread(infp, i);
    if i == 1
        %I guess I could get the size from nfo, but just preallocate output like this
        out = zeros([ size(tmp) nfr ]);
    end
    out(:,:,:,i) = tmp;
end

%Also write gif
%Convert to indexed color: we need the same index for the entire file

%Conver to one looong image, let's concatenate dims 1 and 2 and make dim 3 the next image
sz = size(out);
ncol = 128; %Number of colors for gif
pregif = reshape(out, [sz(1) * sz(2) sz(3) sz(4)]);
pregif = permute(pregif, [1 3 2]);
pregif = pregif / max(pregif(:)); %Contrast; should probably use a better contrast algo that divide by max
[x, mp] = rgb2ind( pregif, ncol);
%Convert x back to frames, but indexed color (all with index mp)
x = reshape(x, [sz(1) sz(2) sz(4)]);
%Create gif
imwrite(x(:,:,1), mp, giffp, 'gif', 'Loopcount', inf, 'DelayTime', dt)
for i = 2:nfr
    imwrite(x(:,:,i), mp, giffp, 'gif', 'WriteMode', 'Append', 'DelayTime', dt)
end



%Takes a while, but I don't think there's a better way to do this (in Matlab)