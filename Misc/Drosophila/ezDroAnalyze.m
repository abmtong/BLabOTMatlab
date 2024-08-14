function [out, outraw] = ezDroAnalyze(inst)

%ezSum > fitRise > getSpotPos

len = length(inst);
outraw = cell(1,len);

for i = 1:len
    %ezSum
    tmp = ezSum_batchV2(inst(i));
    %fitRise
    tmp2 = cellfun(@fitRise,tmp, 'Un', 0);
    
    %And if the data exists in inst, getSpotPos
    if isfield(inst(i), 'apdv') && ~isempty(inst(i).apdv)
        tmp2 = cellfun(@(x) getSpotPos(x, inst(i).apdv, inst(i).movpos), tmp2, 'Un', 0);
    end
    outraw{i} = tmp2;
end

%Then do [inst.fitRise] = deal(out{:})
[inst.fitRise] = deal(outraw{:});

out = inst;