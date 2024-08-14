function out = ezSum2gif(inst, frrng)
%Remake the ezSum gifs but with a frame range instead
%Input: output of ezSum

nfr = length( inst(1).imgs )/2;

frs = [1:nfr 1:nfr]; %Frames are 1-nfr for green, then red
chs = [ones(1,nfr) 2*ones(1,nfr)];

%Use the same vol2gif folder, why not
pp = 'vol2gif';
if ~exist(pp, 'dir')
    mkdir(pp)
end

hei = length(frrng);

%For every spot...
len = length(inst);
for i = 1:len
    tmp = inst(i).imgs;
    %Create output image
    sz = size(inst(i).imgs{1});
    outimg1 = zeros( sz(1), sz(2), 1, hei);
    outimg2 = zeros( sz(1), sz(2), 1, hei);
    
    %Add frames
    for j = 1:hei
        ind1 = find( frs == frrng(j) & chs == 1, 1, 'first');
        ind2 = find( frs == frrng(j) & chs == 2, 1, 'first');
        outimg1(:,:,1,j) = tmp{ind1} ;
        outimg2(:,:,1,j) = tmp{ind2} ;
    end
    
    %Autocontrast. Do each half separately
    maxpx1 = max( outimg1(:) );
    maxpx2 = max( outimg2(:) );
    img1 = uint8( double(outimg1) / double(maxpx1) * 255);
    img2 = uint8( double(outimg2) / double(maxpx2) * 255);
    
    %Compose together
    outimg = [img1 img2];
    
    %Write
    imwrite(outimg, fullfile(pp, sprintf('ezSum2gif_%03d.gif',i) ), 'gif', 'LoopCount', inf, 'DelayTime', 0.1)
    
end