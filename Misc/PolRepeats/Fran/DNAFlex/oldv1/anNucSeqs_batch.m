function out = anNucSeqs_batch(gendata, nucdata, inOpts)

%Load genome data, or pass it
if nargin < 1 || isempty(gendata)
    gendata = procGenome();
end

if nargin < 2 || isempty(nucdata) 
    nucdata = procNucMap();
    %Make cell
    if ~iscell(nucdata)
        nucdata = {nucdata};
    end
end

opts = [];

if nargin > 2
    opts = handleOpts(opts, inOpts);
end


%For each in nucdata...
len = length(nucdata);

for i = 1:len
    %Get sequences
    seqs = getNucSeqs(gendata, nucdata{i});
    anNucSeqs(seqs, opts)
end