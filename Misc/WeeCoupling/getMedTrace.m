function out = getMedTrace(inst)

fil = 200;
Fs = (4000/3);

len = length(inst);
out = cell(1,len);
for i = 1:len
    %Take data
    tmp = inst(i).con;
    
    if isfield(inst, 'start')
        tmp = cellfun(@(x,y) x(y:end), tmp, num2cell( inst(i).start ) , 'Un', 0);
    end
    
    %Filter data
    tmpF = cellfun(@(x) windowFilter(@mean, x, fil, 1), tmp, 'Un', 0);
    
    %Optional: Make Monotonic
    tmpF = cellfun(@(x) makeMono(x), tmpF, 'Un', 0);
    
    %Extend data to same length
    maxlen = max( cellfun(@length, tmp) );
    tmpFX = cellfun(@(x) [x x(end) * ones(1, maxlen - length(x) )], tmpF, 'Un', 0);
    
    %Take median
    out{i} = median( reshape([tmpFX{:}], maxlen, []), 2 )';
end

figure, hold on
cellfun(@(x) plot( (1:length(x))/Fs, x ), out)
legend({inst.name})