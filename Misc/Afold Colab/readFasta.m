function out = readFasta(infp)

if nargin < 1
    [f, p] = uigetfile('*.fasta');
    infp = fullfile(p,f);
end

fid = fopen(infp);
tmp = fgetl(fid);

out = fgetl(fid);
while true
    tmp = fgetl(fid);
    if tmp == -1
        break
    end
    out = [out tmp];
end