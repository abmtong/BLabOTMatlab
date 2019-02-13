anamfil = 5;

anamd = whos('d*');
anamd = {anamd.name};

anamr = whos('r*');
anamr = {anamr.name};

for anam = [anamd anamr]
    anamm = anam{1};
    anamtf = find(anamm == 'F');
    if isempty(anamtf)
        eval(sprintf('%sF%d = cellfun(@(x)windowFilter(@mean,x,[],%d),%s,''uni'',0);', anamm, anamfil, anamfil, anamm))
    end
end

clear anam*