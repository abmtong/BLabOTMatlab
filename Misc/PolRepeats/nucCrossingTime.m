function out = nucCrossingTime(tra, inOpts)


opts.fil = 10; %Pts to filter
opts.Fs = 3125; %Hz
opts.bdys = [558 704]-16 + [-5 0]; %Start and stop position, shift to a bit before?

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if ~iscell(tra)
    tra = {tra};
end

%Filter traces
traF = cellfun(@(x) windowFilter(@mean, x, opts.fil, 1), tra, 'Un', 0);

%Check for crossings of bdys
st = cellfun(@(x) find(x > opts.bdys(1), 1, 'first'), traF, 'Un', 0);
en = cellfun(@(x) find(x > opts.bdys(2), 1, 'first'), traF, 'Un', 0);

ki = ~cellfun(@isempty,st) & ~cellfun(@isempty,en);

%If they do, denote time
out = cellfun(@(x,y) (y-x)/opts.Fs, st(ki), en(ki));