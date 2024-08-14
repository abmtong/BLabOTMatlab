function out = RPp3_avg(inst, newxwlc)
%Instead of using the individual fits, use the median fit instead
% OR supply a fit in newxwlc to set to that instead
% Changes individual traces a bit, but overall not much?

%If these were from multiple files, separate
if isfield(inst, 'file')
    nams = {inst.file};
    [uu, ~, ic] = unique(nams);
else
    uu = {''};
    ic = ones(1, length(inst));
end

nfil = length(uu);
for i = nfil:-1:1;
    iki = ic == i;
    %Get new XWLC
    if nargin > 1
        %If supplied, just use it
        txwlc = newxwlc;
    else
        %Or if not, use median XWLC fit
        txwlc = median( reshape( [inst(iki).xwlcft], length(inst(1).xwlcft), []), 2)';
    end
    %Recalc protein contour
    tmp = cellfun(@(ex, fo) (ex - XWLC(fo, txwlc(1), txwlc(2)) * txwlc(3) ) ./ XWLC( fo, txwlc(end-1), inf ) , {inst(iki).ext}, {inst(iki).frc}, 'Un', 0);
    %Update XWLC value, keep a copy of the old one
    [inst(iki).conpro] = deal(tmp{:});
    [inst(iki).xwlcftold] = deal(inst.xwlcft);
    [inst(iki).xwlcft] = deal(txwlc);
end

out = inst;
    
