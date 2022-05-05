function out = procFranp2(inp, inrAop)
%Get data from .mats
% Just gets whole trace, assumes start position is 0
%Folder structure /a NAME/*.mat


fmin = 4; %Minimum force, crop trace at first force < fmin (for broken tethers, e.g.)

%Take folder
if isempty(inp)
    inp = uigetdir;
end

%Get every subfolder
d = dir(inp);
fol = {d([d.isdir]).name};
fols = fol(3:end); %Remove '.' and '..'
%Folders are named "prefix Name", e.g. 'c Nuc F', Name = comment, prefix is just sorting

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
    [d, ~, f] = getFCs(-1, fullfile(inp, fn));
    %Remove tether break data (by checking if force drops to below fmin
    for j = 1:length(f)
        ki = find(f{j} < fmin, 1, 'first');
        if ki
            d{j} = d{j}(1:ki-1);
            f{j} = f{j}(1:ki-1);
        end
    end
    %Zero based on start position
    d0 = cellfun(@(x) x - mean(x(1:10)), d, 'Un', 0);
    %RulerAlign
    dR = rulerAlignV2(d0, inrAop);
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
