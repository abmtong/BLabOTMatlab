function out = procFran_pdd(inst, pddopts)

if nargin < 2
    pddopts = [];
end

%run pol_dwelldist_p1 on each
len = length(inst);
for i = 1:len
    [~, ~, trs] = pol_dwelldist_p1(inst(i).drA, pddopts);
    inst(i).pdd = trs;
end

out = inst;