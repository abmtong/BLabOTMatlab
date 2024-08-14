function out = RP_hoptopass(inst)

edgetrim = 500;

%Converts hop data to passive-like data

%So, crop from retind to end and concatenate. Or dont concatenate?

for i = 1:length(inst)
    tmp = inst(i);
    
    %Crop from retind to end
    ki = tmp.retind+edgetrim:length(tmp.frc);
    inst(i).frc = inst(i).frc(ki);
    inst(i).ext = inst(i).ext(ki);
    inst(i).conpro = inst(i).conpro(ki);
end

%And concatenate data together. NO dont do this
out = inst;
% out = struct('frc', [inst.frc], 'ext', [inst.ext], 'conpro', [inst.conpro], 'file', 'foo');