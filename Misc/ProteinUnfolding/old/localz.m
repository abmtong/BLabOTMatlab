function out = localz(inx, wid)
%Calculates a 'local Z value' = x / std(x) over a window width wid
% Doesn't calculate std over a smooth window for speed (?)

%Use MAD to ignore outliers
xsd = windowFilter(@(x) mad(x, 1), inx, wid, 1);
mn = windowFilter(@median, inx, wid, 1);

out = (inx - mn) ./ xsd;