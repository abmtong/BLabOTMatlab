function out = RPzerohop_join(inst)
%Joins RPzerohop data together
% Just takes first nam and tlohi


%Fields that can be joined by [a.(field)]
fn1 = {'ext' 'conpro' 'frc' 'frcraw' 'ttp'};

%Fields that need to be joined by [ a; b; c]... maybe store them transposed instead, then could do [{:}]?
fn2 = {'ttpint' 'ttpintraw'};

out = inst(1);
for i = 1:length(fn1)
    out.(fn1{i}) = [inst.(fn1{i})]; 
end

for i = 1:length(fn2)
    tmp = cellfun(@(x) x', {inst.(fn2{2})}, 'Un', 0);
    out.(fn2{i}) = [tmp{:}]'; 
end
