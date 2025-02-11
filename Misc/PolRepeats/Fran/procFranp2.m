function out = procFranp2(inp, inrAop)
%Get data from .mats
% Just gets whole trace, assumes start position is 0
%Folder structure /a NAME/*.mat

newcon = 0; %Recalculate contour from ext and F
xwlcparams = {50 900}; %XWLC params for newcon
fmin = 3; %Minimum force, crop trace at first force < fmin (for broken tethers, e.g.)

%Take folder
if isempty(inp)
    inp = uigetdir;
end

%Get every subfolder
d = dir(inp);
fol = {d([d.isdir]).name};
fols = fol(3:end); %Remove '.' and '..'
%Folders are named "prefix Name", e.g. 'c Nuc F', Name = comment, prefix is just sorting

%Do two rounds of rulerAlign, second round is more 'precise'
inrAop2 = inrAop;
%New start will be at zero
inrAop2.start = 0;
%Change filtering and search params
inrAop2.perschd = inrAop2.perschd/2;
inrAop2.filwid = inrAop2.filwid*2;
inrAop2.binsm = inrAop2.binsm/2;
inrAop2.verbose = 0;
inrAop2.verbosecell = 0;

%Storage
len = length(fols);
nams = cell(1,len);
dats = cell(1,len);
datsrA = cell(1,len);
rths = cell(1,len);
frcs = cell(1,len);
for i = 1:length(fols)
    %Get data
    fn = fols{i};
    [d, e, f] = getFCs(-1, fullfile(inp, fn));
    
    %Recalc contour if asked. Useful for non-my data
    if newcon
        warning('Recalculating Contour')
        d = cellfun(@(x,y) x ./ XWLC(y, xwlcparams{:}) / .34, e, f, 'Un', 0);
    end
    
    %Remove tether break data (by checking if force drops to below fmin
    for j = 1:length(f)
        ki = find(f{j} < fmin, 1, 'first');
        if ki
            d{j} = d{j}(1:ki-10);
            f{j} = f{j}(1:ki-10);
        end
    end
    %Remove empty
    ki = cellfun(@length, d) > 10;
    
    %Skip empty
    if all(~ki)
        continue
    end
    
    %Zero based on start position
    d0 = cellfun(@(x) x - mean(x(1:10)), d(ki), 'Un', 0);
    %RulerAlign
    dR = rulerAlignV2(d0, inrAop);
    %RulerAlign again, twice
    dR = rulerAlignV2(dR, inrAop2);
    dR = rulerAlignV2(dR, inrAop2); 
    %SumNucHist
    [hy, hx] = sumNucHist(dR, inrAop);
    %Process filename
    ind = find(fn == ' ', 1, 'first');
    
    %Output
    nams{i} = fn(ind+1:end);
    dats{i} = d;
    datsrA{i} = dR;
    rths{i} = [hx(:) hy(:)];
    frcs{i} = cellfun(@median,f);
end

%Output struct
out = struct('nam', nams, 'raw', dats, 'drA', datsrA, 'rth', rths, 'frc', frcs);
