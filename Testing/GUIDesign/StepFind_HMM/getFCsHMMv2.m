function getFCsHMMv2(cropstr, inOpts)
%Prepares traces for findStepHMMv2
if nargin < 1
    cropstr = '';
end

%Default options
opts.maxlen = inf;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Select files
[files, path] = uigetfile('C:\Data\*.mat','Mu','on');
if ~path
    return
end
if ~iscell(files)
    files = {files};
end

%Select output path
outpath = fullfile(path, 'HMM');
if ~exist(outpath, 'dir')
    mkdir([outpath filesep 'pHMM'])
end

for i = 1:length(files)
    file = files{i};
    %Load crop
    crop = loadCrop(cropstr, path, file);
    if isempty(crop)
        continue
    end
    %Load file
    load([path file],'stepdata')
    %Find start/end crop indicies
    indsta = cellfun(@(x)find(x>crop(1),1),        stepdata.time,'UniformOutput',0);
    indend = cellfun(@(x)find(x<crop(2),1,'last'), stepdata.time,'UniformOutput',0);
    %Exract con/tim/frc values
    con = cellfun(@(ce,st,en)ce(st:en),stepdata.contour, indsta, indend, 'UniformOutput',0);
    frc = cellfun(@(ce,st,en)ce(st:en),stepdata.force, indsta, indend, 'UniformOutput',0);
    tim = cellfun(@(ce,st,en)ce(st:en),stepdata.time, indsta, indend, 'UniformOutput',0);
    %Grab extras, if they exist
    extras = [];
    if isfield(stepdata, 'cal')
        extras.cal = stepdata.cal;
    end
    %stepdata.opts will have WLC params, comment, etc.
    if isfield(stepdata, 'opts')
        extras.opts = stepdata.opts;
    end
    %Construct output struct
    for j = 1:length(indsta)
        if ~isempty(con{j})
            c = con{j};
            f = frc{j};
            t = tim{j};
            n = length(c);
            np = n/opts.maxlen+1;
            inds = round( linspace(1, n, np+1) );
            for k = 1:np
                %name file ['pHMM' MMDDYYN##S##P##.mat]: Number, Segment, Part
                outname = sprintf('pHMM%ss%02dp%02d', file(1:end-4), j, k);
                fcdata = [];
                fcdata.tr = c(inds(k):inds(k+1)-1);
                fcdata.force = f(inds(k):inds(k+1)-1);
                fcdata.tlim = t([inds(k) inds(k+1)-1]);
                fcdata.opts = extras;
                fcdata.hmm = [];
                save(fullfile(outpath, [outname '.mat']), 'fcdata')
            end
        end
    end
end