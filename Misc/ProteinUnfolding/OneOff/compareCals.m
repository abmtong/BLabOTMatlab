function out = compareCals()
%Compares calibrations for 

%Calibration options, to calc Fc / etc.
calopts.Fs = 1e5; %Fsamp, files are processed with a different Fs for eh
calopts.verbose = 1;
calopts.lortype = 1;
calopts.nBin = 1e3;
calopts.Fmax = 2e4;
%Should be ~1e6 pts

%Get files, select with multiselect
[f, p] = uigetfile('Mu','on');
if ~p
    return
end
if ~iscell(f)
    f = {f};
end

%Create figure for cal checking
figure, ax = gca;
calopts.ax = ax;

%for each file
len = length(f);
out = cell(1,len);
for i = 1:len
    %Load file
    dat = load(fullfile(p, f{i}));
    %This is ContourData
    dat = dat.ContourData;
    
    %Get ext
    tmp = [];
    tmp.ext = dat.extension;
    %Get force
    tmp.frc = mean(dat.force);
    %Get k_avg
    tmp.k = ( dat.cal.AX.k + dat.cal.BX.k) /2;
    %Get noise
    tmp.noi = std(tmp.ext);
    
    %Calc pspec/cal
    cla(ax)
    tmp.cal = Calibrate(tmp.ext, calopts);
    drawnow
    pause(.5)
    out{i} = tmp;
end
out = [out{:}];

%Then plot in next fcn... ?



