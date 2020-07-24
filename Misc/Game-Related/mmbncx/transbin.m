function out = transbin(instr)

if iscell(instr)
    instr = instr(:);
else
    instr = {instr};
end

chrs = cellfun(@bin2dec, instr, 'Uni', 0);

out = char([chrs{:}]);