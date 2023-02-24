function out = RPp3_avg(inst)
%Instead of using the individual fits, use the median fit instead
% Changes individual traces a bit, but overall not much?
% Should get some 

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
    %Get median XWLC fits
    txwlc = median( reshape( [inst(iki).xwlcft], length(inst(1).xwlcft), []), 2)';
    %Subtract DNA ext
    tmp = cellfun(@(ex, fo) (ex - XWLC(fo, txwlc(1), txwlc(2)) * txwlc(3) ) ./ XWLC( fo, txwlc(end-1), inf ) , {inst(iki).ext}, {inst(iki).frc}, 'Un', 0);
    [inst(iki).conpro] = deal(tmp{:});
end

out = inst;
    