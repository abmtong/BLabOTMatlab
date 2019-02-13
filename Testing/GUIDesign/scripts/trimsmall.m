anamd = whos('d*');
anamd = {anamd.name};

anamr = whos('r*');
anamr = {anamr.name};

for anam = [anamd anamr]
    eval(sprintf('%s = %s(cellfun(@length,%s)>100);', anam{1}, anam{1}, anam{1}))
end

clear anam*