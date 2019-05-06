function getFCsHMM(aseed, cropstr, maxlen)

if nargin < 1
    aseed = [];
end
if nargin < 2
    cropstr = '';
end
if nargin < 3
    maxlen = inf;
end

%
%Based off of @Iterate_GatherFCs
%Get files
[files, path] = uigetfile('C:\Data\phage*.mat','MultiSelect','on');
%Check to make sure files were selected
if ~path
    return
end
if ~iscell(files)
    files = {files};
end

%Select output path
outpath = uigetdir(path);

for i = 1:length(files)
    file = files{i};
    %Load crop
    cropfp = sprintf('%s\\CropFiles%s\\%s.crop',path, cropstr, file(6:end-4));
    fid = fopen(cropfp);
    if fid == -1
        fprintf('Crop%s not found for %s\n',cropstr, file)
        continue
    end
    ts = textscan(fid, '%f');
    fclose(fid);
    crop = ts{1};
    %load file
    load([path file],'stepdata')
    %find start/end crop indicies
    indsta = cellfun(@(x)find(x>crop(1),1),        stepdata.time,'UniformOutput',0);
    indend = cellfun(@(x)find(x<crop(2),1,'last'), stepdata.time,'UniformOutput',0);
    %exract con/tim/frc values
    con = cellfun(@(ce,st,en)ce(st:en),stepdata.contour, indsta, indend, 'UniformOutput',0);
    frc = cellfun(@(ce,st,en)ce(st:en),stepdata.force, indsta, indend, 'UniformOutput',0);
    tim = cellfun(@(ce,st,en)ce(st:en),stepdata.time, indsta, indend, 'UniformOutput',0);
    %grab extras, if they exist
    opts = [];
    if isfield(stepdata, 'cal')
        opts.cal = stepdata.cal;
    end
    %stepdata.opts will have WLC params, comment, etc.
    if isfield(stepdata, 'opts')
        opts.opts = stepdata.opts;
    end
    %save in output file
    for j = 1:length(indsta)
        if ~isempty(con{j})
            c = con{j};
            f = frc{j};
            t = tim{j};
            n = length(c);
            np = n/maxlen+1;
            inds = round( linspace(1, n, np+1) );
            for k = 1:np
                %name file ['pHMM' MMDDYYN## {extra stuff might be here} S##P##.mat]
                outname = sprintf('pHMM%sS%02dP%02d.mat', file(6:end-4), j, k);
                fcdata = [];
                fcdata.con = c(inds(k):inds(k+1));
                fcdata.frc = f(inds(k):inds(k+1));
                fcdata.tim = t(inds(k):inds(k+1));
                fcdata.opts = opts;
                fcdata.aseed = aseed;
                save([outpath filesep outname], 'fcdata')
            end
        end
    end
end

end