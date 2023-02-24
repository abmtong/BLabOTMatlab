function out = removefirstcyc(inst)

%Removes first hi cycles ('_H01') files from data
fns = fieldnames(inst);

for i = 1:length(fns)
    tmpst = inst.(fns{i});
    %Remove data that is from _H01 data
    ki = cellfun( @isempty, strfind(tmpst.hiN, '_H01') );
    tmpst.hiN = tmpst.hiN(ki);
    tmpst.hi = tmpst.hi(ki);
    inst.(fns{i}) = tmpst;
end

out = inst;