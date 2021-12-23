function splitcondfiles(infp, inOpts)
%Splits condensation data into closing + opening sections, so we can
%Splits at f threshold
% Makes separate files, labeled 'split_lo' and 'split_hi'

opts.fthr = 5; %pN
opts.trim = [2 2]; %Trim by these many pts on each side, negative = expand by that amount
opts.filwid = 50; %Median filter
opts.minsz = 2000; %Minimum size, pts
opts.cropstr = []; %Only consider cropstr data, use -1 for all

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


if nargin < 1
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~iscell(f)
        f = {f};
    end
    cellfun(@(x) splitcondfiles(fullfile(p, x), opts), f)
    return
end

%Convert filepath
[p, f, e] = fileparts(infp);
f = [f e];

%Make output dirs
folnamlo = 'Split_low';
folnamhi = 'Split_hi';
if ~exist(fullfile(p, folnamlo), 'dir')
    mkdir(p, folnamlo);
end
if ~exist(fullfile(p, folnamhi), 'dir')
    mkdir(p, folnamhi);
end
%Load file
sd = load(fullfile(p, f));
sd = sd.stepdata;
%These are just {time contour force}

cropT = loadCrop(opts.cropstr, p, f);
if isempty(cropT)
    fprintf('Crop not found for %s\n', f)
    return
end

%Extract, make row vector
tim = sd.time{1}(:)';
con = sd.contour{1}(:)';
frc = sd.force{1}(:)';

%Apply crop
ki = tim > cropT(1) & tim < cropT(2);
tim = tim(ki);
con = con(ki);
frc = frc(ki);

%Split by force
ki = windowFilter(@median,frc,opts.filwid,1) < opts.fthr;
[in, me] = tra2ind(double(ki));

kilo = me == 1; %Low force sections
stlo = in(kilo);
enin = in(2:end);
enlo = enin(kilo);

kihi = me == 0; %Hi force sections. Only appear after a lo force section
sthi = in(kihi);
enin = in(2:end);
enhi = enin(kihi);

%Save lo
[~, fn, ex] = fileparts(f);
for j = 1:length(stlo)
    ind = stlo(j) + opts.trim(1) : enlo(j) - opts.trim(2);
    if length(ind) < opts.minsz
        continue
    end
    stepdata.time = {tim(ind)};
    stepdata.contour = {con(ind)};
    stepdata.force = {frc(ind)};
    save(fullfile(p, folnamlo, sprintf('%s_L%02d%s', fn, j, ex)), 'stepdata');
end

%Save hi
for j = 1:length(sthi)
    ind = sthi(j) + opts.trim(1) : enhi(j) - opts.trim(2);
    if length(ind) < opts.minsz
        continue
    end
    stepdata.time = {tim(ind)};
    stepdata.contour = {con(ind)};
    stepdata.force = {frc(ind)};
    save(fullfile(p, folnamhi, sprintf('%s_H%02d%s', fn, j, ex)), 'stepdata');
end

end


