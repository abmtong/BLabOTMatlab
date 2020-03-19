function out = getFCsMina(cropstr)

if nargin < 1
    cropstr = '';
end

%Select files
[f, p] = uigetfile('*.mat', 'Mu', 'on');
if ~p
    return
end

if ~iscell(f)
    f = {f};
end
len = length(f);

outCon = [];
outFrc = [];
outTim = [];

for i = 1:len
    %Load file
    sd = load(fullfile(p, f{i}));
    sd=sd.stepdata;
    cropt = loadCrop(cropstr, p, f{i});
    if isempty(cropt)
        fprintf('No crop%s found for %s\n', cropstr, f{i})
        continue
    end
    sdc = cropstepdata(sd, cropt, 0);
    [tc, tf, tt] = splitcond(sdc);
    outCon = [outCon tc]; %#ok<*AGROW>
    outFrc = [outFrc tf];
    outTim = [outTim tt];
end

tf = classifytraces(outFrc, outCon);

fnames = {'misc' 'cond' 'pull'};
ctinds = [0 1 2];
for i = 1:3
    out.(fnames{i}) = struct('ext', outCon(tf == ctinds(i)), 'frc', outFrc(tf == ctinds(i)), 'tim', outTim(tf == ctinds(i)));
end
