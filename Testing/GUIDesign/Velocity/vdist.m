function [ccts, xbins, cvel, cfilt, ccrop] = vdist(c, sgp)

if nargin < 2
    sgp = {1 501}; %seems good for loF
end

vbinsz = 2; %bp/s bin size;

if ~iscell(c)
    c = cell(c);
end

[cvel, cfilt, ccrop] = cellfun(@(x)sgolaydiff(x, sgp), c, 'uni', 0);

cvel = cellfun(@(x) double(x)*2500, cvel, 'Uni', 0);

cf2 = [cvel{:}];

mincf = floor(min(cf2) / vbinsz) * vbinsz;
maxcf =  ceil(max(cf2) / vbinsz) * vbinsz;

xbins = mincf:vbinsz:maxcf;

ccts = hist(cf2, xbins);

% figure, bar(xbins, ccts);