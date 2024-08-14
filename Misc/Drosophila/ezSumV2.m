function out = ezSumV2(inst, xy, r, name, verbose)

%V2: Followable dot, xy = coords as column vectors [x, y]

%verbose : 1 = both, 2 = just gif
%Quick n dirty 'average over this thingy'

if nargin < 4
    name = datestr(now, 'YYmmDDHHMMSS');
end

if nargin < 5
    verbose = 1;
end

%Create the base mask: a circle with center (x,y) and radius r
sz = size(inst(1).img);
msk = zeros( sz );
%Set a dot at the center
msk( sz(1)/2, sz(2)/2 ) = 1;
%And convert to a disk for integration
msk1 = logical(imdilate(msk, strel('disk', r)));
%Or a square for image saving
msk2 = logical( imdilate(msk, strel('square', r*2+1)));
%Edge length of the image
mskwid = r*2+1;

%Let's handle moving the ROI via circshift, so convert xy coords to relative-to-center
% (because I think imdilate is slow / overkill for just one pixel)
% Near the edges, this will wrap around; eh prob minor
%Round xy to make integer shifts
xy = round(xy);
x = xy(:,2) - sz(1)/2;  %XY coords is left-right, up-down, ...
y = xy(:,1) - sz(2)/2;  %... which is dim 2, and dim 1 in matrix form

%For every frame of inst...
len = length(inst);
ifr = zeros(1,len);
ich = zeros(1,len);
vals = zeros(1,len);
imgs = cell(1,len);
zs = zeros(2,len);
for i = 1:len
    %Get image
    img = inst(i).img;
    %Background removal
    bkg = imopen(img, strel('disk', 3));
    imgbkg = double(img) - double(bkg);
%     imgbkg = img; Skip background removal
    
    %Circshift masks
    rm1 = circshift( circshift( msk1, x(i), 1 ), y(i), 2);
    rm2 = circshift( circshift( msk2, x(i), 1 ), y(i), 2);
    
    %Sum over the region
    vals(i) = sum( sum( imgbkg( rm1 ) ) );
    
    %Add metadata
    ifr(i) = inst(i).frame;
    ich(i) = inst(i).ch;
    
    %Save imgbkg snip
    snp = imgbkg(rm2);
    snp = reshape(snp, mskwid, mskwid);
    imgs{i} = snp;
    
    %Calculate maxz of each spot in img, mask plane
%     if isfield(inst, imgz)
    zs(:,i) = [ max( inst(i).imgz(rm1) )  max( inst(i).mskz(rm1) ) ];
%     end
end
%Maybe save snippets and output to gif to 'check the work' ?

%Separate by channel
if verbose == 1
    figure, hold on
end
maxval = zeros(1,2);
valssep = cell(1,2);
valssepz = cell(1,2);
for i = 1:2
    %Separate by frame no
    ki = ich == i;
    
    %Make sure it's sorted
    yy = vals(ki);
    xx = ifr(ki);
    [~, si] = sort(xx);
    xx = xx(si);
    yy = yy(si);
    valssep{i} = yy;
    
    %Grab Z values
    zz = zs(:,ki);
    zz = zz(:,si);
    valssepz{i} = zz;
    
    
    if verbose == 1
        %Plot
        plot(xx, yy)
    end
    
    %Do some preprocessing for gif
    %Preprocess: set max pixel value to 255 so we can cast to uint8
    maxval(i) = max(cellfun(@(x) max(max(x)), imgs(ich == i)));
end

if verbose
    %Make a gif
    tmp1 = imgs(ich == 1);
    tmp2 = imgs(ich == 2);
    hei = length(tmp1);
    %Write gif
    dt = 0.1; %10fps
    %Write a full grey frame as the loop frame
    imwrite( uint8( 128 * ones( size(tmp1{1}) .* [1 2]  ) )  , ['ezSum' name '.gif'], 'Loopcount', inf, 'DelayTime', dt)
    for j = 1:hei
        imwrite(  uint8( [tmp1{j}*255/maxval(1) tmp2{j}*255/maxval(2)])  , ['ezSum' name '.gif'], 'WriteMode', 'Append', 'DelayTime', dt)
    end
end

%Make output: first add some metadata
out.cen = [median(x), median(y)] + sz/2; %Should +sz/2 here
% warning('Cen is shifted by -sz/2, undo this when reanalyzing')
out.rad = r;


%Save output
out.vals1 = valssep{1};
out.vals2 = valssep{2};
out.vals1z = valssepz{1};
out.vals2z = valssepz{2};
out.imgs = imgs;