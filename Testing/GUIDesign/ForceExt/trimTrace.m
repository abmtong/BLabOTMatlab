function [outExt, outFor] = trimTrace(inExt, inFor, loF, hiF)
%Trims trace by finding first crossings of loF and hiF. Preferable to e.g. inFor(inFor > loF & inFor < hiF) because of bdys

%inFor should be increasing, reverse if not.
if inFor(1) > inFor(end)
    inExt = inExt(end:-1:1);
    inFor = inFor(end:-1:1);
end

%Find bdy crossings
ind1 = find(inFor < loF, 1, 'last');
if isempty(ind1)
    ind1 = 1;
end
ind2 = find(inFor > hiF, 1, 'first');
if isempty(ind2)
    ind2 = length(inFor);
end

outExt = inExt(ind1:ind2);
outFor = inFor(ind1:ind2);