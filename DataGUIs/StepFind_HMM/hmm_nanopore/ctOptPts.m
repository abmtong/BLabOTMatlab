function out = ctOptPts(res)
%Oh I can one-line this like this
out = cellfun(@(x)sum(cellfun(@length, x)),{res.raw});