function lbl = bdy2img(bdys, sz)
%Turn boundaries back to label matrix
%bdys = cell of bdys, sz = size of image (since it isn't evident from just the boundaries)

%If size isn't supplied, find the smallest image that contains all boundaries
if nargin < 2
    %Get per-boundary maximums
    szs = cellfun(@(x) max(x,[],1), bdys, 'Un', 0);
    %And get max among all boundaries
    szs = reshape([szs{:}], 2, []);
    sz = max(szs, [], 2)';
end

%Create output
lbl = zeros(sz);

%lbl is a label image, where lbl == i is bdys{i} 
for i = 1:length(bdys)
    %Create this image, use logical so we can assign later
    tmp = false(sz);
    %Input boundary
    for j = 1:size(bdys{i}, 1)
        tmp( bdys{i}(j,1), bdys{i}(j,2) ) = true;
    end
    %Fill
    tmp = imfill(tmp, 'holes');
    %Set this region to i
    lbl(tmp) = i;
end
%Assumes the boundaries don't overlap, if they do, later #s will overwrite earlier #s