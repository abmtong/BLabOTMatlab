function out = simpleCoupStats(inst)


%Get simple stats: tfbreak, time of break/end, and position of end

Fs = 4000/3;

len = length(inst);
out = cell(1,len);
for i = 1:len
    %Get data
    dat = inst(i).con;
    
    %Time
    tend = cellfun(@length, dat) / Fs;
    
    %End point
    yend = cellfun(@(x) mean(x(end-1e3:end)), dat);
    
    if isfield(inst, 'yoffmanual')
        yend = yend + inst(i).yoffmanual;
    end
    
    %tfbreak
    tfb = inst(i).tfbreak;
    
    %Frc
    frc = inst(i).frcavg;
    
    %Assemble to mtx
    
    out{i} = [ tend(:) yend(:) tfb(:) frc(:) ];
end