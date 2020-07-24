function out = drawimage(pos, grn, iskymo)
%Renders a Lumicks image from the InfoWave (pos, uint8 array) and photoncount (grn, uint32 array).
%If the image is a kymograph or movie, set iskymo = 1 to skip the last line, as it is probably incomplete (could take it, but code won't do it yet)

if nargin < 3
    iskymo = 0;
end

%Line starts when pos goes from 0 to 1
lnstarts = find(pos(1:end-1) == 0 & pos(2:end) == 1);

%ExtractLength is a sample line scan extract
exln = pos(lnstarts(1):lnstarts(2));
%Length of line, in pixels: A new pixel starts when pos goes from 1 to 2
len = sum( exln(1:end-1) == 1 & exln(2:end) == 2);
%Height is number of lines
hei = length(lnstarts) - iskymo; %remove last line if iskymo - last scan probably isn't finished, so truncate [could keep, but eh]

out = zeros(len, hei);

%find scan line starts: pos goes from 0 -> 1
lnstarts = [lnstarts; length(grn)];
for i = 1:hei
    lnseg = pos(lnstarts(i):lnstarts(i+1));
    lnends = [1; find(lnseg == 2)];
    for j = 1:len
        stin = lnends(j)+1 + lnstarts(i);
        enin = lnends(j+1) + lnstarts(i);
        out(j, i) = sum(grn( stin:enin  ));
    end
end

% figure, imshow(out)