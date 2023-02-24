function out = makeKymo(inimg, col)

%Turns image stack of h x w x 3 x n to a n x w kymograph

%Col is an enum of (r, g, b); defaults green (order is RGB so col == 2)

if nargin < 2
    col =2 ;
end

if nargin < 1
    inimg = readLumTiff;
end

%Number of frames
nfr = size(inimg, 4);

%Preallocate kymograph
out = zeros( size(inimg, 2), nfr );
for i = 1:nfr
    %Get frame and color, sum across height
    out(:,i) = sum( inimg(:,:,col,i), 1);
end

