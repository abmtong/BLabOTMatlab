function out = getFCs_multi(cropstr, path, newxwlc, tfkeep)

%Same as getFCs, but acts on subfolders of the given path
%eg if path = 'C:\Data', this will get all data of form C:\Data\*\*.mat and split by folder

%Output: a struct with the data that getFCs would have given you. 

if nargin < 1
    cropstr = '';
end

if nargin < 2 || isempty(path)
    path = uigetdir;
end

if nargin < 3
    newxwlc = [];
end

if nargin < 4
    tfkeep = {'con' 'ext' 'frc' 'trn' 'file'}; %which data to keep: con, ext, frc, trn, file, default all
end

%Get subfolders
d=dir(path);
d = d([d.isdir]);
fols = {d.name};

%Remove . and .. by removing all folders that start with .
fols = fols(~strncmp(fols, '.', 1));

%For each folder...
len = length(fols);
for i = len:-1:1
    %getFCs on this folder
    [oc, oe, of, ot, on] = getFCs(cropstr, fullfile(path, fols{i}), newxwlc);
    
    %Make sure things are actually loaded...
    if isempty(oc)
        continue
    end
    
    %Save what is kept
    if any(strcmp(tfkeep, 'con'))
        out(i).con = oc;
    end
    if any(strcmp(tfkeep, 'ext'))
        out(i).ext = oe;
    end
    if any(strcmp(tfkeep, 'frc'))
        out(i).frc = of;
    end
    if any(strcmp(tfkeep, 'trn'))
        out(i).trn = ot;
    end
    if any(strcmp(tfkeep, 'file'))
        out(i).file = on;
    end
    out(i).name = fols{i};
end

%Remove empty folders
ki = ~cellfun(@isempty,{out.name});
out = out(ki);

%Order fieldnames so 'name' is first
nf = length(fieldnames(out));
out = orderfields(out, [nf, 1:nf-1]);





