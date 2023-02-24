function out = analyzeMutantsp1(inst, inOpts)

%Input: a struct from getFCs_multi
%For plotting, can add a field 'color' to inst

opts.Fs = 2500;

opts.kdfopts.fil = {10 1};

len = length(inst);

%Let's see...
%Want to do kdfsfindV2
% And fit dwells to gamma + 1exp
gp = gcp('nocreate');
tras = cell(1,len);
if isempty(gp)
    for i = 1:len
        [~, ~, ~, ~, tras{i}] = kdfsfindV2(inst(i).con);
    end
else
    parfor i = 1:len
        [~, ~, ~, ~, tras{i}] = kdfsfindV2(inst(i).con);
    end
end
[inst.tra] = deal(tras{:});

out = inst;