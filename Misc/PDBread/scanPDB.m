function out = scanPDB(infp)
%Returns the ATOM records of a PDB, with output:
%{Chain Num Elem X Y Z};
%{
Each ATOM line in a PDB is
ATOM    142  C   ASN A  20     206.475 192.582 248.319  1.00454.18           C
Name Num(Tot) AtomRes Chain Num X Y Z B Element
Which should be scannable with format string:
    %s%d%c%s%c%d%f%f%f%f%c
%}

if nargin < 1
    [f, p]=uigetfile('*.pdb');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

fid = fopen(infp);
lns = {};
while true
    ln = fgetl(fid);
    if ln == -1
        break
    end
    %Check if ln is an ATOM record
    if strncmp(ln, 'ATOM', 4);
        lns = [lns {ln}]; %#ok<AGROW>
    end
end

len = length(lns);
%Save the atom ID, the chain, N, and x y z
elem = cell(1,len);
chn = char(1,len);
num = zeros(1,len);
xpos = zeros(1,len);
ypos = zeros(1,len);
zpos = zeros(1,len);

for i = 1:len
    ts = textscan(lns{i}, '%s%d%s%s%c%d%f%f%f%f%f%c');
    %Check if ok [should be... maybe different if b-factor is different]
    if length(ts) ~= 12
        warning('Error on line %d: %s', i, lns{i})
    end
    %Then scan
    elem{i} = ts{3};
    chn(i) = ts{5};
    num(i) = ts{6};
    xpos(i) = ts{7};
    ypos(i) = ts{8};
    zpos(i) = ts{9};
end
out = {chn num elem xpos ypos zpos};