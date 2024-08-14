function out = readtxt(infp)
%Read a (hopefully small) text file and just store it as a 1xn char

if nargin < 1
    [f, p] = uigetfile();
    infp = fullfile(p,f);
end

fid = fopen(infp);

out = cell(1,1e4);
ind = 1;
while ~feof(fid)
    out{ind} = fgetl(fid);
    ind = ind + 1;
end
out = out(1:ind-1);
fclose(fid);

%Pad with spaces
maxwid = max( cellfun(@length, out) );

for i = 1:ind-1
    out{i} = [out{i} repmat(' ', 1, maxwid - length(out{i})) ];
end

out = reshape( [out{:}], maxwid, [])';


