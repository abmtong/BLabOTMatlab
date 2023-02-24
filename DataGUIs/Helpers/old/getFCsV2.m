function out = getFCsV2(cropstr, path)
%V2: struct output, with fields [tr, frc, ind0, name, opts]
% Not actually used...

if nargin < 1
    cropstr = '';
end

if nargin < 2
    path = [];
end

if isempty(path)
    [files, path] = uigetfile('D:\Data\*.mat','MultiSelect','on');
    if ~path
        return
    end
    if ~iscell(files)
        files = {files};
    end
else
    %If path is passed, then grab all traces in that folder
    d = dir([path filesep '*.mat']);
    files = {d.name};
end

%     function outXpL = XWLC(F, P, S, kT)
%         %Simplification var.s
%         C1 = F*P/kT;
%         C2 = exp(nthroot(900./C1,4));
%         outXpL = 4/3 ...
%             + -4./(3.*sqrt(C1+1)) ...
%             + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
%             + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
%             + F./S;
%     end

outCons = {};
outFrcs = {};
% outTrNs = []; %arg that groups fcs from the same file together
outNames = {}; %Trace name
outTs = [];
outOpts = [];
for i = 1:length(files)
    file = files{i};
    %Load crop
    crop = loadCrop(cropstr, path, file);
    if isempty(crop)
        fprintf('Crop%s not found for %s\n', cropstr, file)
        continue
    end
    stepdata = load(fullfile(path, file));
    fname = fieldnames(stepdata);
    fname = fname{1};
    stepdata = stepdata.(fname);
    stepdata = renametophage(stepdata, fname);
    indsta = cellfun(@(x)find(x>crop(1),1),        stepdata.time,'UniformOutput',0);
    indend = cellfun(@(x)find(x<crop(2),1,'last'), stepdata.time,'UniformOutput',0);
    con = cellfun(@(ce,st,en)ce(st:en),stepdata.contour, indsta, indend, 'UniformOutput',0);
    frc = cellfun(@(ce,st,en)ce(st:en),stepdata.force, indsta, indend, 'UniformOutput',0);
    outCons = [outCons con]; %#ok<*AGROW>
%     outTrNs = [outTrNs ones(1,length(con)) * i];
    outNames = [outNames repmat({file}, 1,length(con))];
    outFrcs = [outFrcs frc];
    outTs = [outTs indsta];
    if isfield(stepdata, 'opts')
        opts = stepdata.opts;
    else
        opts = [];
    end
    outOpts = [outOpts repmat({opts}, 1, length(con))];
end
%Remove empty
ki = ~cellfun(@isempty,outCons);
%Assemble to struct
out = struct('tr', outCons(ki), 'frc', outFrcs(ki), 'ind0', outTs(ki), 'name', outNames(ki), 'opts', outOpts(ki));

end