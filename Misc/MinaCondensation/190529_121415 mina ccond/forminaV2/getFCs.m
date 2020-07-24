function [outCons, outExts, outFrcs, outTrNs] = getFCs(cropstr, newxwlc)
if nargin < 1
    cropstr = '';
end
%newxwlc changes con to have new XWLC params, defined by {PL, SM}
if nargin >1
    %might input [PL, SM] instead, if so fix for user
    if ~iscell(newxwlc)
        newxwlc = num2cell(newxwlc);
    end
end

[files, path] = uigetfile('C:\Data\phage*.mat','MultiSelect','on');
if ~path
    return
end
if ~iscell(files)
    files = {files};
end

    function outXpL = XWLC(F, P, S, kT)
        %Simplification var.s
        C1 = F*P/kT;
        C2 = exp(nthroot(900./C1,4));
        outXpL = 4/3 ...
            + -4./(3.*sqrt(C1+1)) ...
            + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
            + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
            + F./S;
    end

outCons = [];
outExts = [];
outFrcs = [];
outTrNs = []; %arg that groups fcs from the same file together
for i = 1:length(files)
    file = files{i};
    %Load crop
    cropfp = sprintf('%s\\CropFiles%s\\%s.crop',path,cropstr, file(6:end-4));
    fid = fopen(cropfp);
    if fid == -1
        fprintf('Crop%s not found for %s\n', cropstr, file)
        continue
    end
    ts = textscan(fid, '%f');
    fclose(fid);
    crop = ts{1};
    
    load([path file],'stepdata')
    indsta = cellfun(@(x)find(x>crop(1),1),        stepdata.time,'UniformOutput',0);
    indend = cellfun(@(x)find(x<crop(2),1,'last'), stepdata.time,'UniformOutput',0);
    con = cellfun(@(ce,st,en)ce(st:en),stepdata.contour, indsta, indend, 'UniformOutput',0);
    outCons = [outCons con]; %#ok<AGROW>
    outTrNs = [outTrNs ones(1,length(con)) * i]; %#ok<AGROW>
    if nargout > 1 || nargin > 1 %convert to extension, from contour
        %Con = Ext/XWLC/.34, so Ext = Con*XWLC*.34
        frc = cellfun(@(ce,st,en)ce(st:en),stepdata.force, indsta, indend, 'UniformOutput',0);
        ext = cellfun(@(c,f)c .* XWLC(f, 60, 550, 4.14) *.34, con, frc, 'Uni', 0);
        outExts = [outExts ext]; %#ok<AGROW>
        outFrcs = [outFrcs frc]; %#ok<AGROW>
    end
end
outTrNs = outTrNs(~cellfun(@isempty,outCons));
outCons = outCons(~cellfun(@isempty,outCons));

if nargout>1|| nargin > 1
    outExts = outExts(~cellfun(@isempty,outExts));
    outFrcs = outFrcs(~cellfun(@isempty,outFrcs));
end
if nargin > 1
    outCons = cellfun(@(x, f) x ./ XWLC(f, newxwlc{:}, 4.14) / .34, outExts, outFrcs, 'uni', 0);
end
end