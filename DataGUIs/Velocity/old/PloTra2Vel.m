function [outvel, outn] = PloTra2Vel(cellin)
%takes the output of PlotTraces and outputs velocities by @polyfit

fsamp = 2500;

%remove empty FCs and stuff
outvel = cell(1,size(cellin,2));
outn = cell(1, size(cellin, 2));
for i = 1:length(cellin)
    %take only y values, not time values
    trc = cellin{end, i};
    if isempty(trc)
        continue
    end
    %remove empty fcs
    trc = trc(~cellfun(@isempty,trc));
    ot = cellfun(@(x) polyfit(1:length(x), x, 1), trc, 'uni', 0);
    outvel{i} = cellfun(@(x) x(1)*fsamp, ot);
    outn{i} = cellfun(@length, trc, 'uni', 0);
end
