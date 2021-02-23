function makelinks(dataname, cropstr)
%Make a link file for use with Antony repeats code

%File hierarchy:
%{
./AnalysisFiles/
  This folder contains the in _config_common.py and config_DataName.py
./AnalysisFiles/DataName/
  This folder contains the {offsets, periods, rts, sections} analysis files pickled

./Exported/DataName/
  This folder contains the .mat files

./Link Files/DataName/
  This folder contains the .link files and a .env file
%}

if nargin < 1
    dataname = 'Data';
end
if nargin < 2
    cropstr = '';
end

%Select data files
[f, p] = uigetfile('*.mat', 'Mu', 'on');
if ~p
    return
end

if ~iscell(f)
    f = {f};
end

outdir = fullfile(p, 'links');
if ~isdir(outdir)
    mkdir(outdir);
end

%Make 'env' file, we're just going to call it Data
%Env should just be ../../Exported/DataName
fid = fopen(fullfile(outdir, '.env'), 'w');
fprintf(fid, 'DATAPATH=../../Exported/%s', dataname);
fclose(fid);

for i = 1:length(f)
    fi = f{i};
    crp = loadCrop(cropstr, p, fi);
    if isempty(crp)
        continue
    end
    
    [~, fn, ~] = fileparts(fi);
    
    %Open a file with the same name as the crop
    fid = fopen( fullfile(outdir, [fn '.link']), 'w');
    %Write three lines:
    fprintf(fid, 'path=$DATAPATH/%s\n', fi);
    fprintf(fid, 'range=%f:%f\n', crp);
    fprintf(fid, 'freq=3125');
    fclose(fid);
end


