function ProcCals(opts)
%Process calibrations so they can be opened by PhageGUI
% Essentially, put AX/AY/BX/BY on ext channel, SA/SB on Force channel
%Input opts is ACalibrate opts

if nargin < 1
    opts = [];
end

[f, p] = uigetfile('a*.dat', 'Mu', 'on'); %Look for a*.dat file, to select only for cal.s
if ~p
    return
end
if ~iscell(f)
    f = {f};
end

%Remove the leading a from the filenames, to get base file
f = cellfun(@(x)x(2:end), f, 'Un', 0);

len = length(f);
out = [];
for i = 1:len
    %Do calibration
    cal = ACalibrate(fullfile(p, f{i}), opts);
    fg = gcf;
    [~, fn, ~] = fileparts(f{i});
    savefig(fg, fullfile(p, ['cal' fn '.fig']));
    
    %Create mat file
    dat = processHiFreq(fullfile(p, f{i}));
    out.contour{1} = dat.AX'*1000;
    out.contour{2} = dat.AY'*1000;
    out.contour{3} = dat.BX'*1000;
    out.contour{4} = dat.BY'*1000;
    out.force{1} = dat.SA';
    out.force{2} = dat.SA';
    out.force{3} = dat.SB';
    out.force{4} = dat.SB';
    out.time = repmat({(0:length(dat.AX)-1)/62.5e3},1,4);
    out.cal = cal;
    stepdata = out; %#ok<NASGU>
    save(fullfile(p, ['cal' fn '.mat']), 'stepdata')
end

