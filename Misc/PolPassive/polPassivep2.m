function out = polPassivep2(inst, inOpts)
%Calculate max force and velocity profile
% Can I just use vdist_force?


opts.fil = 10;

vdopts = opts.vdopts;

len = length(inst);
%For each data type...
for i = 1:len
    hei = length(inst.con);
    raw = cell(1,hei);
    %For each trace...
    for j = 1:hei
        %Calculate stall force = max force
        frcf = windowFilter(@median, inst(i).frc{j}, opts.fil, 1);
        %Find highest force. Or 99.99th percentile?
        [~, maxi] = max(frcf);
        
        %Calculate vdist
        [] = vdist_force(inst(i).con{j}, inst(i).frc{j}, vdopts);
        
        %Finish this later....
    end
    
    
end







