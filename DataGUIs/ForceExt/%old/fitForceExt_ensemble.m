function outfit = fitForceExt_ensemble( inExt, inFor, inOpts, verbose )

if nargin < 4
    verbose = 1;
end
if nargin < 3
    inOpts.loF = 5;
    inOpts.hiF = 30;
end

if ~iscell(inFor)
    inFor = {inFor};
end

if ~iscell(inExt)
    inExt = {inExt};
end

sngfits = cellfun(@(x,y)fitForceExt(x, y, inOpts, 0), inExt, inFor, 'uni', 0);
%use contour to shift traces
sngfits = reshape([sngfits{:}], 4, []);
cons = sngfits(3,:);
conavg = mean(cons);
inExt = cellfun(@plus, inExt, num2cell((conavg-cons)*.34), 'Uni', 0);

sngfits = mean(sngfits, 2);
fprintf('Avg Fit: PerLen=%0.2fnm, StrMod=%0.2fpN, ConLen=%0.2fbp, Offset=%0.2fnm\n' ,sngfits);
inFor = [inFor{:}];
inExt = [inExt{:}];
[ff, fi] = sort(inFor);
xx = inExt(fi);

outfit = fitForceExt(xx, ff, inOpts, verbose);