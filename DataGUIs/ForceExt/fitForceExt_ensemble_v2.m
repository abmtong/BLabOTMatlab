function outfit = fitForceExt_ensemble_v2( inExt, inFor, inOpts, verbose )


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
[sngfits, fitfnc] = cellfun(@(x,y)fitForceExt(x, y, inOpts, 0), inExt, inFor, 'uni', 0);
sngfits = reshape([sngfits{:}], 5, []);
sngfits = mean(sngfits, 2);
fitfnc = fitfnc{1};

len = length(inExt);
extshfts = zeros(1,len);
for i = 1:len
    %shift ext for best agreement with ensemble fit
    calcex = fitfnc(sngfits, inFor{i});
    extshfts(i) = mean(calcex - inExt{i});
end
inExt = cellfun(@plus, inExt, num2cell(extshfts), 'Uni', 0);

% sngfits = mean(sngfits, 2);
fprintf('Avg Fit: PerLen=%0.2fnm, StrMod=%0.2fpN, ConLen=%0.2fbp, OffX=%0.2fnm, OffF=%0.2f\n' ,sngfits);
inFor = [inFor{:}];
inExt = [inExt{:}];
[ff, fi] = sort(inFor);
xx = inExt(fi);

outfit = fitForceExt(xx, ff, inOpts, verbose);