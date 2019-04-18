function [out, outfp] = tsprocess_ghettoffset(dtype)
if nargin < 1
    dtype = 'int16';
end
%reads files, passes data to @ProcessOneData -like methods, then outputs a .mat file

[f{1}, p] = uigetfile('./*.dat', 'Select cal file');
if ~p
    return
end
[f{2}, p] = uigetfile([p '*.dat'], 'Select data file');

if ~p
    return
end
f(3) = f(2);

if ~iscell(f) || length(f) ~= 3
    error('Pick three files.');
end

%assume order is cal/off/data

%process cal
calraw = timeshareread([p f{1}], dtype);
%take var of data - should be low if dtype is right. Otherwise, will be log distributed
vsa = var(calraw.AS);
if vsa > 1
    switch dtype
        case 'int16';
            dtype = 'single';
            dtypeold = 'int16';
        case 'single'
            dtype = 'int16';
            dtypeold = 'single';
        otherwise
            error('dtype %s is probably wrong, no known replacement', dtype)
    end
    warning('dtype is probably wrong, switching from %s to %s', dtypeold, dtype);
    calraw = timeshareread([p f{1}], dtype);
    vsa = var(calraw.AS);
    if vsa > 1e3
        error('dtype %s and %s is probably wrong, no known replacement', dtype, dtypeold)
    end
end

fnames = {'AX' 'AY' 'BX' 'BY' 'AS' 'BS'};
for i = 1:6
    calraw.(fnames{i}) = calraw.(fnames{i})(1e4:end);
end

%set up opts
calopts.hydro = 0;
calopts.Fs = 1/calraw.meta.hdr(3);
calopts.ra = 500; %bead radius, nm. Replace with query window later like @AProcessData
calopts.nBin = ceil(length(calraw.AX) / 200); %200 total pts in pspec
calopts.Fmin =  500;
calopts.Fmax = [];
calopts.d2o = 0.8;
fnames = {'AX' 'AY' 'BX' 'BY'};
sumnms = {'AS' 'AS' 'BS' 'BS'};

colors = {[.2039 .5961 .8588] [.1608 .5020 .7255];...
          [.1804 .8000 .4431] [.1529 .6824 .3765] };

%Taken from @ACalibrate / @Calibrate
%Timeshareds use a high quality, fast QPD so they don't encounter the "virual filter" that Hires' PSDs see(?),
%  so you don't need to calibrate using al and f3. Adapted Hires' code to remove them  in @tscalibrate* functions.
%  @ACalibrate works with sane optimization constraints (most of the time, al -> 1, = no filter) but eh seems "cleaner" like this
%    Also, their data is currently processed without this filter, so it is also consistent
calopts.verbose = 1;
%Define plot window
scrsz = get(groot,'ScreenSize');
sz = [scrsz(3:4)*.2 scrsz(3:4)*.6];
figure('Name',sprintf('%s Calibration',f{1}), 'Position',sz)
axi = [1 3 2 4];
for i = 1:length(fnames)
    calopts.color = colors{axi(i)};
    calopts.ax = subplot(2, 2, axi(i));
    calopts.name = fnames{i};
    calopts.Sum = mean( calraw.(sumnms{i}) );
%     cal.(fnames{i}) = tscalibrate( calraw.(fnames{i})(1e4:end), calopts);
%     cal.(fnames{i}) = tscalibrate( calraw.(fnames{i}) ./ calraw.(sumnms{i}), calopts);
    cal.(fnames{i}) = Calibrate( calraw.(fnames{i}) ./ calraw.(sumnms{i}), calopts);
end
out.cal = cal;


%process offset
offraw = timeshareread([p f{2}], dtype);
% offraw = timeshareread_badavgnum([p f{2}], dtype);
fnames = {'AX' 'AY' 'BX' 'BY'};
trapdel = offraw.T2F - offraw.T1F;
%plot MX over time, prompt user to select offset region
fg=figure; plot(trapdel),
xlim([1 1e5])
a=ginput(2);
a = round(a(1:2));
delete(fg);
tdcr = trapdel(a(1):a(2));
for i = 1:length(fnames)
    otmp = offraw.(fnames{i});
    [off.(fnames{i}), off.td] = tsoffset( tdcr, otmp(a(1):a(2))); 
    %Smooth the offset
    off.(fnames{i}) = smooth(off.(fnames{i}), 5);
end
out.off = off;

%Read data
datraw = timeshareread([p f{3}], dtype);
% datraw = timeshareread_badavgnum([p f{3}], dtype);
%Extract meta
opts.Fsamp = 1/datraw.meta.hdr(3);
opts.convTrapX = 160.2656; %nm/MHz, for Meitner
% opts.convTrapX = 144; %nm/MHz, for Boltz
% opts.convGrnX = 1014.982; %nm/V, for Meitner
opts.raA = 500;
opts.raB = 500;
opts.xwlcSM = 700;
opts.xwlckT = 4.14;
opts.xwlcPL = 40;
opts.xwlcBp = .34;

%Apply offset, normalize voltages, calculate trap forces
fnames = {'AX' 'AY' 'BX' 'BY'};
sumnms = {'AS' 'AS' 'BS' 'BS'};
dattd = datraw.T2F - datraw.T1F;
for i = 1:length(fnames)
    % normalized voltage = (AX - offAX[interp'd]) ./ AS;
    datraw.(fnames{i}) = ( datraw.(fnames{i}) - interp1( off.td, off.(fnames{i}), dattd, 'linear', mean(off.(fnames{i})) ) )  ./ datraw.(sumnms{i});
    %Trap force = nAX * alpha * kappa
    out.(['force' fnames{i}]) = datraw.(fnames{i}) * cal.(fnames{i}).a * cal.(fnames{i}).k;
end

%Calculate extension  = hypot( TrapDelta + BeadsX, BeadsY) - Bead Radii
out.extension = hypot( (datraw.T2F-datraw.T1F)*opts.convTrapX  + cal.AX.a*datraw.AX - cal.BX.a*datraw.BX, ...
                                                               + cal.AY.a*datraw.AY - cal.BY.a*datraw.BY )...
                       - opts.raA - opts.raB;
%Calculate total force = hypot( forX, forY ) using differential force (average of forces)
out.force = hypot((out.forceBX - out.forceAX)/2, ...
                  (out.forceBY - out.forceAY)/2);

out.contour = out.extension ./ XWLC(out.force, opts.xwlcPL, opts.xwlcSM, opts.xwlckT) / opts.xwlcBp;
              
%Define time vector, dt = 1/Fs
len = length(out.force);
out.time = single(1:len) / opts.Fsamp;

%Debug
figure, plot(dattd), hold on, rectangle('Position', [ 1 min(off.td) length(dattd) max(off.td)-min(off.td) ] )

%Save
tsdata = out; %#ok<NASGU>
outfp = sprintf('%sData%s.mat',p ,f{1}(1:end-4)); 
save( outfp, 'tsdata' )
