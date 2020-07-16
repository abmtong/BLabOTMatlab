function out = cxripV2(inOpts)
%ClpX Rip Analysis
%V2: Seems like they want everything, so just KV it all and output it raw
%We'll just use file picker every time. You will need to use change the filename filter in the filepicker UI

%Fiddle with these (or pass them in an input struct inOpts) to affect stepfinding
opts.filwid = 10; %Increase the number to reduce noise (but lose time resolution)
opts.kvpf = 5; %Increase this to find fewer steps

opts.Fs = 2500;
opts.mindwi = 2;%Minimum dwell time

if nargin >= 1
    opts = handleOpts(opts, inOpts);
end

%Get the data
[data, ~, fdata, ~, names] = getFCs();

%Filter it (moving average)
data  = cellfun(@(x)windowFilter(@mean, x, [], opts.filwid), data, 'Un', 0);
fdata = cellfun(@(x)windowFilter(@mean, x, [], opts.filwid), fdata, 'Un', 0);

%Apply stepfinding (Kalafut-Visscher). A window will pop up, showing the stepfinding results, check for niceness.
[kvi, kvm] = BatchKV(data, single(opts.kvpf));
%The output is kvi and kvm, containing the indices of steps and mean values of the found steps

%If the steps are not quick enough, the transition will show up as multiple very small steps. Join these steps together.
kvki = cellfun(@(x)diff(x) > opts.mindwi, kvi, 'Un', 0);
kvi = cellfun(@(x,y) x([y true]), kvi, kvki, 'Un', 0);
kvm = cellfun(@(x,y) x(y), kvm, kvki, 'Un', 0);

%Get the step sizes
kvst = cellfun(@diff, kvm, 'Un', 0);
%Get the dwell lengths
kvdw = cellfun(@(x)diff(x)/opts.Fs*opts.filwid, kvi, 'Un', 0);
%Now get the forces of each found step
kvf = cellfun(@ind2mea, kvi, fdata, 'Un',0);

%The last dwell has no associated step, so trim the last dwell and force from each trace
kvf = cellfun(@(x) x(1:end-1), kvf, 'Un', 0);
kvdw = cellfun(@(x) x(1:end-1), kvdw, 'Un', 0);

%Copy name field to fit dimensions
names = cellfun(@(x,y) repmat({x}, 1, length(y)), names, kvst, 'Un', 0);

%Concatenate these cells-of-cells to a single array
kvst = [kvst{:}];
kvdw = [kvdw{:}];
kvf = [kvf{:}];
names = [names{:}];


%Assemble to output
out = [names' num2cell(kvst') num2cell(kvdw') num2cell(kvf')];
hdr = {'Trace Name' 'Step Size (nm)' 'Dwell Time (s)' 'Force (pN)'};
out = [hdr; out];