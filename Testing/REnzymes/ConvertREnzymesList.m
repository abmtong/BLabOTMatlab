function out = ConvertREnzymesList()

%Data taken from http://rebase.neb.com/rebase/rebase.files.html, link 9 (Redasoft Plasmid)
%Remove the first explainer lines, last reference lines
%Turns it into a nx8 cell with each row being a REnzyme

%Flow: Convert > Trim > Process

[file, path] = uigetfile('.txt');
filepath = [path file];

fid = fopen(filepath);
ts = textscan(fid, '%s', 'Whitespace', '', 'Delimiter', '\r\n');
fclose(fid);
ts = ts{1};
len = length(ts);
out = cell(ceil(len/9), 8);
row = 1;

for i = 1:len
    ii = mod(i,9);
    if ii
        ln = ts{i};
        out{row,ii} = ln(4:end);
    else
        row = row + 1;
    end
end