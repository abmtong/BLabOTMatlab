function outCropDims = ChooseCrop(p, f)

if nargin < 2
    [~, mp, ~] = fileparts(mfilename);
    [f, p] = uigetfile([mp '\*.*'], 'Select some image(s) [multiple will be averaged together]', 'MultiSelect', 'on');
end
if ~iscell(f)
    f = {f};
end
len = length(f);
ims = cell(1,length(f));
for i = 1:len
    ims{i} = imread([p, f{i}]);
end
imsum = zeros(size(ims{1}));
for i = 1:len
    imsum = imsum + double(ims{i});
end

im = uint8(round(imsum / len));

f = figure;
imshow(im)
a = ginput(2);
x = sort(a(:,1));
y = sort(a(:,2));
outCropDims = [x(1) y(1) diff(x) diff(y)];
close(f);
end

