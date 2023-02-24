function out = procFran_pdd(inst, pddopts)
%Run pol_dwelldist_p1 on traces

% Analyze RTH (with the pdd crossing times instead of RTH) with _pddp2

opts.roi = [0 780]; %Range of interest

if nargin < 2
    pddopts = [];
end


%run pol_dwelldist_p1 on each
len = length(inst);
for i = 1:len
    tmpdat = inst(i).drA;
    tmpdat = cellfun(@(x) x(   find(x>opts.roi(1), 1, 'first'): find(x<opts.roi(2),1,'last') ), tmpdat, 'Un', 0);
    [~, ~, trs] = pol_dwelldist_p1(tmpdat, pddopts);
    inst(i).pdd = trs;
end

out = inst;