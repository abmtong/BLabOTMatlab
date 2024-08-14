function out = ezSum(inst, xyr, name, verbose)

%verbose : 1 = both, 2 = just gif
%Quick n dirty 'average over this thingy'

if nargin < 3
    name = datestr(now, 'YYMMDDHHmmSS');
end

if nargin < 4
    verbose = 1;
end

%Create the mask: a circle with center (x,y) and radius r
% e.g. get an image, get x,y with ginput, set r something largeish (the spots move)
msk = zeros( size(inst(1).img) );
msk(xyr(2), xyr(1)) = 1; %Swap xy
msk1 = logical(imdilate(msk, strel('disk', xyr(3))));


%Create masks for image saving
msk2 = logical( imdilate(msk, strel('square', xyr(3)*2+1)));

%Get the dimensions of this img if it goes off the edge
mskx = sum( sum(msk2, 1)>0 );
msky = sum( sum(msk2, 2)>0 );

%For every frame of inst...
len = length(inst);
ifr = zeros(1,len);
ich = zeros(1,len);
vals = zeros(1,len);
imgs = cell(1,len);
for i = 1:len
    %Get image
    img = inst(i).img;
    %Background removal
    bkg = imopen(img, strel('disk', 3));
    imgbkg = double(img) - double(bkg);
    
    %Sum over the region
    vals(i) = sum( sum( imgbkg( msk1 ) ) );
    
    %Add metadata
    ifr(i) = inst(i).frame;
    ich(i) = inst(i).ch;
    
    %Save imgbkg snip
    snp = imgbkg(msk2);
    snp = reshape(snp, mskx, msky);
    imgs{i} = snp;
end
%Maybe save snippets and output to gif to 'check the work' ?

%Separate by channel
if verbose == 1
    figure, hold on
end
maxval = zeros(1,2);
valssep = cell(1,2);
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
    dt = 0.05; %20fps
    imwrite( uint8( [tmp1{1}*255/maxval(1) tmp2{1}*255/maxval(2)])  , ['ezSum' name '.gif'], 'Loopcount', inf, 'DelayTime', dt)
    for j = 2:hei
        imwrite(  uint8( [tmp1{j}*255/maxval(1) tmp2{j}*255/maxval(2)])  , ['ezSum' name '.gif'], 'WriteMode', 'Append', 'DelayTime', dt)
    end
end

%Make output: first add some metadata
out.cen = xyr(1:2);
out.rad = xyr(3);


%Save output
out.vals1 = valssep{1};
out.vals2 = valssep{2};
out.imgs = imgs;