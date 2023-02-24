function out = getStartPt(inst)

%Find last positive crossing of pt 0 and use this guy as the start

%Filter some to remove noise
fil = 50;
len = length(inst);
for i = 1:len
    tmp = cellfun(@(x) windowFilter(@mean, x, fil, 1), inst(i).con, 'Un', 0);
    sts = cellfun(@(x) find ( x < 0, 1, 'last'), tmp);
    inst(i).start = sts;
    
    figure('Name', sprintf('gSP check: %s', inst(i).name))
    hold on
    tmpF = cellfun(@(x)windowFilter(@mean, x, 100, 1), inst(i).con, 'Un', 0);
    cellfun(@(x,y) plot( x(y:end) ), tmpF, num2cell(sts) )
    
end
out = inst;