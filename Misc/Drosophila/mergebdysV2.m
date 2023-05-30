function [out, lbl] = mergebdysV2(bdys, rr)
%If we just save the bdys but not the label matrix, can we get back the label matrix?
%bdys = cell-of-cell of bdys

%V2: dilate/erode applies per frame, instead of at the end

%rmerge = radius to merge two spots together, = strel disk size for imdilate

%Stupid answer might be:


%Get smallest image that contains all boundaries
%Get per-boundary dims
szs = cellfun(@(x) max(x,[],1), bdys, 'Un', 0);
%And get max among all boundaries
szs = reshape([szs{:}], 2, []);
sz = max(szs, [], 2)';

%Create image
img = zeros(sz);

%Input boundaries
for i = 1:length(bdys)
    for j = 1:size(bdys{i}, 1)
        img( bdys{i}(j,1), bdys{i}(j,2) ) = 1;
    end
end

%Fill holes
img = imfill(img, 'holes');

%Dilate the image to merge adjacent spots, or erode to reverse
if rr > 0 %if rr is positive, dilate
    img = imdilate( img, strel('disk', rr) );
else %Negative, erode by that much
    img = imerode( img, strel('disk', -rr) );
end

%Redo bwboundaries on this amalgam image
[out, lbl] = bwboundaries(img, 'noholes');

%Then run regionprops on out to get metadata, etc.

%Below code is if you want the combined thing
% %And output as single boundaries
% img2 = zeros(size(sz));
% for i = 1:length(outraw)
%     for j = 1:size(outraw{i}, 1)
%         img2( outraw{i}(j,1), outraw{i}(j,2) ) = 1;
%     end
% end
% % 
% % figure, imshow(img2)

