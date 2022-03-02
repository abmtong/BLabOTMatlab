function out = calcXingTime(trs, inOpts)

opts.rng = [558 704]-16; %Start to end position
opts.Fs = 1e3;
opts.fil = 50;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

st = cellfun(@(x) find( windowFilter(@mean, x, opts.fil, 1) > opts.rng(1), 1, 'first'), trs, 'Un', 0);
en = cellfun(@(x) find( windowFilter(@mean, x, opts.fil, 1) > opts.rng(2), 1, 'first'), trs, 'Un', 0);

ki = ~cellfun(@isempty, st) & ~cellfun(@isempty, en);

out = ( [en{ki}] - [st{ki}] ) / opts.Fs;