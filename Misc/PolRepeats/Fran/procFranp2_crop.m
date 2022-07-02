function out = procFranp2_crop(inst)
%Crop data to tfpick field

len = length(inst);

% fns = {'drA' 'frc' 'tfc'};
for i = 1:len
    tf = inst(i).tfpick;
    %Remove non-picked vars
    inst(i).drA = inst(i).drA(tf);
    inst(i).frc = inst(i).frc(tf);
    inst(i).tfc = inst(i).tfc(tf);
    %Set tfpick to trues
    inst(i).tfpick = true(1, sum(tf));
        
    
end

fprintf('Remember to recalc RTH and crossing times (p2_realign / p3)\n')
out = inst;
%Remove raw field, as it is no longer 'useful'
if isfield(inst, 'raw')
    out = rmfield(inst, {'raw'});
end