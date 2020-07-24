function out = dsrcmap(n)
if nargin < 1
    n = 4;
end

ccmap = [ ...
    0 114 189; ... %dna
	0 191 191; ... %Hy
    119 172 48; ... %iHy
	0 127 0]/255; ... %RR

ii = linspace(1,size(ccmap, 1),n);


r = interp1(1:size(ccmap,1), ccmap(:,1), ii);
g = interp1(1:size(ccmap,1), ccmap(:,2), ii);
b = interp1(1:size(ccmap,1), ccmap(:,3), ii);

out = [r' g' b'];