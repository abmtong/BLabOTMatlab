function [outCons, outExts, outFrcs, outTrNs, outNames] = getFCs(cropstr, path, newxwlc)
if nargin < 1
    cropstr = ''; %Crop string, set in PhageGUI. Pass -1 to get full traces instead
end

%newxwlc changes con to have new XWLC params, defined by {PL, SM}
if nargin >=3
    %might input [PL, SM] instead, if so fix for user
    if ~iscell(newxwlc)
        newxwlc = num2cell(newxwlc);
    end
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

%Use global XWLC fcn
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
outExts = {};
outFrcs = {};
outTrNs = []; %arg that groups fcs from the same file together
outNames = {}; %Trace name
for i = 1:length(files)
    file = files{i};
    %Load crop
    if cropstr == -1 %Cropstr -1 means take all
        crop = [-inf inf];
    else
        crop = loadCrop(cropstr, path, file);
    end
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
    outCons = [outCons con]; %#ok<AGROW>
    outTrNs = [outTrNs ones(1,length(con)) * i]; %#ok<AGROW>
    outNames = [outNames repmat({file}, 1,length(con))]; %#ok<AGROW>
    %Gather frc and ext, too
    if isfield(stepdata, 'force')
        frc = cellfun(@(ce,st,en)ce(st:en),stepdata.force, indsta, indend, 'UniformOutput',0);
        outFrcs = [outFrcs frc]; %#ok<AGROW>
    end
    if isfield(stepdata, 'extension')
        ext = cellfun(@(ce,st,en)ce(st:en),stepdata.extension, indsta, indend, 'UniformOutput',0);
        outExts = [outExts ext]; %#ok<AGROW>
    end
end
ki = ~cellfun(@isempty,outCons);
outTrNs = outTrNs(ki);
outNames = outNames(ki);
outCons = outCons(ki);

if nargout>1|| nargin > 1
    outExts = outExts(~cellfun(@isempty,outExts));
    outFrcs = outFrcs(~cellfun(@isempty,outFrcs));
end
if nargin >= 3 && ~isempty(newxwlc)
    outCons = cellfun(@(x, f) x ./ XWLC(f, newxwlc{:}, 4.14) / .34, outExts, outFrcs, 'uni', 0);
end
end