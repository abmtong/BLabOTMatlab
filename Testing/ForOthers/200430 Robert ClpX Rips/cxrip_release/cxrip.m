function out = cxrip(data, inOpts)
%ClpX Rip Analysis
%Wrapper for ppKVv3 to use options for ClpX rips
%Assumes only one event per crop
%Usage:
%  Crop events using PhageGUI
%  Extract traces using getFCs
%  Run cxKVv3

%PPKV verbose flag
opts.verbose.traces = 1; %plot every N traces, to show tl/bt sections
%Filter opts: {filter factor, decimation factor}; args 3 and 4 of @windowFilter
opts.filwid = {[] 10};
%K-V penalty factor
opts.kvpf = single(8);
%Sampling frequency, to convert pts to time
opts.Fs = 2500;
%Whether or not to plot BatchKV
opts.kvverbose = 0;

%Minimum dContour for an event to be a bt
opts.minlen = 5;
%Need N transloc. steps to become a non-bt again. Assumes bt events aren't clustered
opts.mintr = 0;
%Need N bt steps to be considered a bt
opts.minbt = 0;
    
if nargin >= 2
    opts = handleOpts(opts, inOpts);
end

if ~iscell(data)
    data = {data};
end

%Assemble output containers
len = length(data);
rawbt = cell(1,len);
ripsz = cell(1,len);
subdw = cell(1,len);

for i = 1:len
    %Need to do trace-by-trace now
    raw = ppKVv3(data(i), {10*ones(1,length(data{i}))}, opts);
    
    bt = raw.bt;
    ripsz{i} = cellfun(@diff, {bt.mea}, 'Un',0);
    di = cellfun(@(x) diff(x), {bt.ind}, 'Un', 0);
    subdw{i} = cellfun(@(x) x(2:end-1), di, 'Un', 0);
    
    %Gather output
    rawbt{i} = raw;
end

out = struct('ripsz', ripsz, ...
             'subdw', subdw,  ...
             'rawbt', rawbt);