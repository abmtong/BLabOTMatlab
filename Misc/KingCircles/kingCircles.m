function out = kingCircles(infp, inOpts)

%Options:
opts.rrng = [10 40]; %Radius range, pixels
opts.debug = 1; %Plot image stuff
% opts.rwid = 5; %Circle diameter width
opts.rtol = 3; %Tolerance for concentric circles (center distance)
opts.verbose = 1; %Plot stats, just for cell version

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.nd2', 'Mu', 'on');
    if iscell(f)
        infp = cellfun(@(x) fullfile(p,x), f, 'Un', 0);
    else
        infp = fullfile(p,f);
    end
end

if iscell(infp)
    tmp = cellfun(@(x) kingCircles(x, opts), infp, 'Un', 0);
    %Add field to say which came from where
    for i = 1:length(tmp)
        [~, f, ~] = fileparts(infp{i});
        [tmp{i}(:).file] = deal(f);
    end
    %Output is struct array, just concatenate
    out = [tmp{:}];
    return
end

%Read the (up to) 4 channels of the .nd2
%Images are be [membrane, protein, ...]
[img1, img2, img3, img4] = nd2read(infp);

%First pixel seems to be wrong? First edge, even?
% img1(1) = median(img1(:));

% %Find circles
% [cen rad met] = imfindcircles(img1, opts.rrng);

%Choose centers that are close enough to each other


%Method one: Find inner + outer circle via ObjectPolarity
%Outer edge is 'bright' polarity
[bc br bm] = imfindcircles(img1, opts.rrng, 'ObjectPolarity', 'bright');
%Inner edge is 'dark' polarity
[dc dr dm] = imfindcircles(img1, opts.rrng, 'ObjectPolarity', 'dark');

%Select centers that are shared between the two
nc = length(br);
ibc = zeros(1, nc);
idc = zeros(1, nc);
j = 1;
%For each center in bc...
for i = 1:nc
    %Get this center
    c = bc(i,:);
    %Find centers in dc that are close
    cdist = sqrt( sum( bsxfun(@minus, c, dc).^2 , 2 ) );
    %If one is close enough, choose it
    tmp = find(cdist < opts.rtol, 1, 'first');
    if tmp
        ibc(j) = i;
        idc(j) = tmp;
        j = j + 1;
    end
end
ibc = ibc(1:j-1);
idc = idc(1:j-1);

%Extract the chosen circles
kbc = bc(ibc,:);
kbr = br(ibc);
kdc = dc(idc,:);
kdr = dr(idc);

%Maybe exclude circles that overlap each other: pairwise distances, make sure they are less than r1+r2

nk = length(kbr); %Number of accepted circles
%For each pair, extract the circle (as bdy)
bdys = cell(1,nk);
[xx, yy] = meshgrid(1:size(img1, 1), 1:size(img1, 2));
bdyu = false(size(img1)); %Sum of all boundaries
for i = 1:nk
    %Get points that are farther than inner circle, closer than outer circle
    %Outer circle
    dout = sqrt( (xx - kbc(i,1)).^2 + (yy - kbc(i,2)).^2 ) <= kbr(i);
    %Inner circle
    din = sqrt( (xx - kdc(i,1)).^2 + (yy - kdc(i,2)).^2 ) <= kdr(i);
    bdys{i} = dout & ~din;
    %Update sum of boundaries
    bdyu = bdyu | bdys{i};
end

% out.bdys = bdys;

%Background correction: Use median pixel value of non-included areas
back1 = median( img1(~bdyu) );
img1b = img1 - back1; %img1 is uint, so negatives will be 0 instead. ok?
back2 = median(img2(~bdyu) );
img2b = img2 - back2;

%Sum pixel intensities in boundaries
sums = zeros(nk, 2);
for i = 1:nk
    sums(i,1) = sum(img1b(bdys{i}));
    sums(i,2) = sum(img2b(bdys{i}));
end


out = struct('outer', mat2cell([kbc kbr], ones(nk,1)), 'inner', mat2cell([kdc kdr], ones(nk,1)), ...
    'bdys', bdys', 'radius', num2cell( (kbr+kdr) /2 ), 'sum', mat2cell(sums, ones(nk,1)) );

%Debug
if opts.debug
    %Plot img1
    figure, imshow(img1)
    ax = gca;
    ax.CLim = [prctile(img1(:), 1), prctile(img1(:), 99)]; %Contrast
    
    %Draw circles: Outers in red, inners in blue, 'chosen' in green
    viscircles(bc, br, 'Color', 'r')
    viscircles(dc, dr, 'Color', 'b')
    viscircles([kbc; kdc], [kbr;kdr], 'Color', 'g')
end