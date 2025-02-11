function [outx, outy] = bar_pdf(inx, xrng, wgt)
%Creates a 'bar pdf' where points are bar centers, and the bar edges are between pts, and each bar = area 1

%Maybe handle edge cases?
%And weights?


if nargin < 2
    xrng = [];
end
if nargin < 3
    wgt = ones(size(inx));
end

%Apply xrng if supplied
if ~isempty(xrng)
    ki = inx >= xrng(1) & inx <= xrng(2);
    inx = inx( ki );
    wgt = wgt( ki );
end

%Input check: xrng = empty or numel 2; numel(wgt) = numel(inx)


%First bin identicals together and make these counts
[ux ui uc] = unique(inx);

%Get counts of this unique process
cts = arrayfun(@(x) sum( uc == x ), 1:length(ux));

%Apply weights
cts = cts .* wgt;

%Create bar edges: between cts:
% Center edges are in between points
xedges = (ux(1:end-1) + ux(2:end)) / 2;
% Outer edges are either the input xrng, or space it to the left/right point
if ~isempty(xrng)
    xedges = [ xrng(1)   xedges  xrng(2) ];
else
    xedges = [ ux(1) - (xedges(1)-ux(1)) xedges  ux(end) + (ux(end)-xedges(end)) ];
end

%Create bar heights: basically, the bar width * bar height = cts
bwid = diff(xedges);
bht = cts ./ bwid;

%Create staircase function output with these edges and heights
outy = [bht(:)' ;bht(:)'];
outy = [0 outy(:)' 0];

outx = [xedges(:)'; xedges(:)'];
outx = outx(:)';
















