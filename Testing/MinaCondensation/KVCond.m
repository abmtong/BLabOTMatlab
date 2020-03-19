function out = KVCond(incon, inOpts)
%do KV stepfinding, then further analyze in p2
%Input: output from getFCsMina (struct with fields {ext, frc, tim})

%Filter opts
opts.filfun = @mean;
opts.filwid = [];
opts.dec = 40;

%KV 
opts.kvpf = single(1);

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if ~iscell(incon)
    incon = {incon};
end

[i, m, t] = BatchKV(windowFilter(opts.filfun, {incon.ext}, opts.filwid, opts.dec), opts.kvpf);

frc = cellfun(@mean, {incon.frc}, 'Un', 0);
dt = cellfun(@(x)median(diff(x)), {incon.tim}) * opts.dec;

out = struct('con', incon, 'ind', i, 'mea', m, 'tra', t, 'frc', frc, 'dt', dt, 'kvopts', opts);
