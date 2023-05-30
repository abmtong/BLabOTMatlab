function num = cdn2num(cdnarr)

if ischar(cdnarr)
    cdnarr(cdnarr == 'A') = 1;
    cdnarr(cdnarr == 'T' | cdnarr == 'U') = 2;
    cdnarr(cdnarr == 'G') = 3;
    cdnarr(cdnarr == 'C') = 4;
end
%Convert to base-4
exps = 4.^(length(cdnarr)-1:-1:0);

num = sum( exps .* (cdnarr-1) ) +1;