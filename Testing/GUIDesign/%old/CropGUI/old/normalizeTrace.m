function outTr = normalizeTrace(inTr)
%Normalizes a trace by fitting it into [0, 1] and reversing if needed to give negative slope

if inTr(1) < inTr(end)
    inTr = inTr(end:-1:1);
end
outTr = ( inTr - min(inTr) ) / (max(inTr) - min(inTr));