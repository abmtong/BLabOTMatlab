function out = tsAcalibrate(infp, inOpts)

dtype = 'single';

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('./*.dat', 'Select cal file');
    if ~p
        return
    end
    infp = [p f];
end

%read data
calraw = timeshareread(infp, dtype);

fnames = {'AX' 'AY' 'BX' 'BY' 'AS' 'BS'};
for i = 1:6
    calraw.(fnames{i}) = calraw.(fnames{i})(1e4:end);
end

%set up opts
calopts.hydro = 0;
calopts.Fs = 1/calraw.meta.hdr(3);
calopts.ra = 500; %bead radius, nm. Replace with query window later like @AProcessData
calopts.nBin = ceil(length(calraw.AX) / 200); %200 total pts in pspec
calopts.Fmin =  50;
calopts.Fmax = [];
fnames = {'AX' 'AY' 'BX' 'BY'};
sumnms = {'AS' 'AS' 'BS' 'BS'};

colors = {[.2039 .5961 .8588] [.1608 .5020 .7255];...
          [.1804 .8000 .4431] [.1529 .6824 .3765] };

%Taken from @ACalibrate / @Calibrate
%Timeshareds use a high quality, fast QPD so they don't encounter the "virual filter" that Hires' PSDs see,
%  so you don't need to calibrate using al and f3. Adapted Hires' code to remove them  in @tscalibrate* functions.
%  @ACalibrate works with sane optimization constraints (most of the time, al -> 1, = no filter) but eh seems "cleaner" like this
%    Also, their data is currently processed without this filter, so it is also consistent
calopts.verbose = 1;

if nargin > 1
    calopts = handleOpts(calopts, inOpts);
end

%Define plot window
scrsz = get(groot,'ScreenSize');
sz = [scrsz(3:4)*.2 scrsz(3:4)*.6];
[~, f] = fileparts(infp);
figure('Name',sprintf('%s Calibration',f), 'Position',sz)
axi = [1 3 2 4];
for i = 1:length(fnames)
    calopts.color = colors{axi(i)};
    calopts.ax = subplot(2, 2, axi(i));
    calopts.name = fnames{i};
    calopts.Sum = mean( calraw.(sumnms{i}) );
%     cal.(fnames{i}) = tscalibrate( calraw.(fnames{i})(1e4:end), calopts);
%     cal.(fnames{i}) = tscalibrate( calraw.(fnames{i}) ./ calraw.(sumnms{i}), calopts);
    cal.(fnames{i}) = Calibrate( calraw.(fnames{i}) ./ calraw.(sumnms{i}), calopts);
%     cal.(fnames{i}) = Calibrate( calraw.(fnames{i}), calopts);
    
end
out = cal;