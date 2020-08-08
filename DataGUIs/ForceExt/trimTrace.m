function [outExt, outFor] = trimTrace(inExt, inFor, loF, hiF)
%Trims a ForExt pull for XWLC fitting by finding first crossings of loF and hiF
%Only works for single pulls [todo: handle multiple, e.g. by tracking mirror movement]
% Preferable to e.g. the naive inFor(inFor > loF & inFor < hiF) because of bdys

%Make inFor increasing (reverse if not -- this naive algorithm should be enough to work)
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