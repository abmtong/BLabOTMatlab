function out = importHbonds(infp)
%Imports H-bonds from ChimeraX output (Tools > Structure Tools > H-Bonds , output to file, save with .txt extension)
% To find bb H-bonds for JS Folding Simulations

%File is like this:
%{
{Some top text}

Main lines are like this:
/A LEU 2 N      /A ASN 51 O    /A LEU 2 HN     2.982  2.156
/A TYR 4 N      /A LYS 53 O    /A TYR 4 HN     3.047  2.063
      (1)             (2)(3)            (4)
The H-bond is sidechain if (3) and (4) are O to HN, and the residue pair is (1) and (2)
%}

if nargin < 1
    [f, p] = uigetfile('*.txt');
    infp = fullfile(p,f);
end

fid = fopen(infp);

%Scan forwards until we get to the line starting 'H-bonds'
while true
    ln = fgetl(fid);
    if strncmp(ln, 'H-bonds', 7)
        break
    end
end

%And scan h-bonds     1 2  3   4  5  6  7  8  9 10 11 12 13 14
lns = textscan(fid, '%s %s %d %s %s %s %d %s %s %s %d %s %f %f');
fclose(fid);

%Want columns 3 and 7 (residue IDs), and cols 8 and 12 (atom IDs)
res = [ lns{3} lns{7} ];
% atms = [ lns(8) lns(12) ];
%Is a backbone H-bond if atms{i,1} == O and atms{i,2} == 'HN'
iso = strcmp(lns{8}, 'O');
ishn = strcmp(lns{12}, 'HN');
ishb = iso & ishn;

reshb = res(ishb,:);

%And create mtx
maxres = max(res(:)); %Won't be the actual max, may need to enlarge
out = zeros(maxres);
for i = 1:size(reshb, 1);
    %And make matrix
    out(reshb(i,1), reshb(i,2)) = 1;
    out(reshb(i,2), reshb(i,1)) = 1;
end



    