function splitcondfiles(inOpts)
%Splits condensation data into closing + opening sections, so we can 

opts.fthr = 5; %pN
opts.trim = [0 0]; %Trim by these many pts on each side
opts.filwid = 10;
opts.minsz = 2000; %Minimum size, pts

if nargin
    opts = handleOpts(opts, inOpts);
end

%Splits at f threshold, also splits at time inconsistency
% Makes separate files, labeled 'split_lo' and 'split_hi'

[f, p] = uigetfile('*.mat', 'Mu', 'on');
if ~iscell(f)
    f = {f};
end

folnamlo = 'Split_low';
folnamhi = 'Split_hi';

%Make output dirs
mkdir(p, folnamlo);
mkdir(p, folnamhi);

for i = 1:length(f)
    %Load file
    sd = load(fullfile(p, f{i}));
    sd = sd.stepdata;
    %These are just {time contour force}
    
    %Extract, make row vector
    tim = sd.time{1}(:)';
    con = sd.contour{1}(:)';
    frc = sd.force{1}(:)';
    
    %Split by force
    ki = windowFilter(@mean,frc,opts.filwid,1) < opts.fthr;
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
    [~, fn, ex] = fileparts(f{i});
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


