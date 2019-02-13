function outimg = combotiff(colmults, contrpile)

%If you want to make a color stronger by some multiple (will oversaturate)
if nargin < 1 || length(colmults) ~= 3
    colmults = [1 1 1];
end

%Paramter for auto-contrast. Takes top contrpile and bottom 1-contrpile and sets them to max and 0, respectively
if nargin < 2
    contrpile = .95; %95th percentile of histogram becomes max darkness
end

[f, p] = uigetfile('E:/pics/*.tif','MultiSelect','on');

if ~p
    return
end

if ~iscell(f)
    f = {f};
end

len = length(f);

if len > 4
    error('Pick up to three files.')
end

img = cell(1,len);
for i = 1:len
    %Read image
    im = imread([p f{i}]);
    %auto contrast: rescale, saturating extrema as defined by contrpile
    %Find what int depth the tiff is using
    typ = whos('im');
    typ = typ.class;
    %Do calculations on double version of im
    im = double(im);
    imx = double(intmax(typ));
    %scale lower to 0
    lo = prctile(im(:), (1-contrpile)*100);
    im = im-lo;
    %scale upper to imx
    hi = prctile(im(:), contrpile*100);
    im = im * imx/hi;
    %Scale by colmults
    im = im * colmults(i);
    %Recast to int
    f2h = str2func(typ);
    img{i} = f2h(im);
end
%Hmm should scale better - so e.g. median intensities are the same

%color order: B R G
colord = [3 1 2];
out = uint16(zeros([size(img{1}), 3]));
for i = 1:len
    out(:,:,colord(i)) = img{i};
end
figure, imshow(out);

if nargout > 0
    outimg = out;
end