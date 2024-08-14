function out = makeOccMap(hitfwd, hitrev)

%Makes a nucleosome occupancy map

%Assumes hit_fwd is at the left edge of the NPS and hit_rev at the right edge
% Places a gaussian centered at the dyad that 'matches' the NPS size of 147bp (i.e., 3\sigma = 147bp)


sig = 147/6; %Sigma for kdf. Lets have it be within 2 or 3 sigma?
nucwid = 147; %NPS width, bp. Probably at least 147
ntot = 711; %Total length

%Convert hit_fwd and hit_rev to dyad pos
dy1 = hitfwd + nucwid/2;
dy2 =(ntot - hitrev+1) - nucwid/2;

%Combine to 'dyad pos'
hits = [dy1(:)' dy2(:)'];
hits = double(hits);

%Convert to nuc pos
% x = 1:711;
out = kdf(hits,1,  sig, [1 ntot]);