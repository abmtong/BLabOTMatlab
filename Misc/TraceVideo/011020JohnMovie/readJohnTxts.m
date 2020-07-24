function out = readJohnTxts(inpf)

if nargin < 1
    [f, p] = uigetfile('*APDTime.txt');
    if ~p
        return
    end
    inpf = [p f];
end

%Load them files

[p, f, e] = fileparts(inpf);

%Strip 'Time' from filename
fbase = f(1:end-7);

%Read APDTime, Codons, Photons, Time
fnames = {'APDTime' 'Codons' 'Photons' 'Time'};

out = [];

for i = 1:length(fnames)
    fid = fopen(fullfile(p, [fbase fnames{i} e]));
    textscan(fid, '%s',1);
    ts = textscan(fid, '%f');
    ts = ts{1}';
    out.(fnames{i}) = ts;
end