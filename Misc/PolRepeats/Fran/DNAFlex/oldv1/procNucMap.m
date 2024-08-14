function out = procNucMap(infp)
%Loads nucleosome map data from NucMap (ngdc.cncb.ac.cn/nucmap/)

%Each file is a .bed file (tsv) with lines e.g.:
%{
chrV	255	396	chrV.1
chrV	365	506	chrV.2
chrV	475	616	chrV.3
chrV	575	716	chrV.4
...
The columns are chromosome ID, start, stop, name
%}

if nargin < 1
    [f p] = uigetfile('*.bed', 'Mu', 'on');
    if ~p
        return
    end
    
    %Batch process if multiple files are picked
    if iscell(f)
        out = cellfun(@(x) procNucMap( fullfile( p, x) ), f, 'Un', 0);
        return
    else
        infp = fullfile(p, f);
    end
end

fid = fopen(infp);
[p, f, e] = fileparts(infp);
if fid == -1
    warning('File %s not found, quitting', f); 
    return
end

tmp = textscan(fid, '%s %d %d %s\n', inf);

%Let's format out as a struct with fieldname = chromosome (first column), data start and end (cols 2 and 3)
[c, ia, ic] = unique(tmp{1});
nchr = length(c);
for i = nchr:-1:1
    ki = ic == i;
    out(i).chr = c{i};
    out(i).nucpos = [tmp{2}(ki) tmp{3}(ki)];
end

%Add a field for name
%The names of these files are e.g.:
% Saccharomyces_cerevisiae.scNuc0020101.nucleosome.iNPSPeak.bed
% i.e. <organism>.<name>.<data_type>.<analysis_program>.bed
scannfo = textscan(f, '%s', 'Delimiter', '.');
scannfo = scannfo{1};
[out.info] = deal( struct('Name', scannfo{2}, 'Organism', scannfo{1}, 'AnalysisProgram', scannfo{4})  );