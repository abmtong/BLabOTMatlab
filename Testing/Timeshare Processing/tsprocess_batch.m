function [out, outfp] = tsprocess_batch(dtype, fpcal, fpoff, fpdat)
if nargin < 1
    dtype = 'int16';
end


%assume order is cal/off/data

%process cal
calraw = timeshareread(fpcal, dtype);

fnames = {'AX' 'AY' 'BX' 'BY' 'AS' 'BS'};
for i = 1:6
    calraw.(fnames{i}) = calraw.(fnames{i})(1e4:end);
end

%set up opts
calopts.hydro = 0;
calopts.Fs = 1/calraw.meta.hdr(3);
calopts.ra = 500; %bead radius, nm. Replace with query window later like @AProcessData
calopts.nBin = ceil(length(calraw.AX) / 1000); %200 total pts in pspec
calopts.Fmin =  50;
% calopts.Fmax = 5e3;
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
%Define plot window
scrsz = get(groot,'ScreenSize');
sz = [scrsz(3:4)*.2 scrsz(3:4)*.6];
[~,fcal] = fileparts(fpcal);
figure('Name',sprintf('%s Calibration',fcal), 'Position',sz)
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
drawnow

%process offset
offraw = timeshareread(fpoff, dtype);
fnames = {'AX' 'AY' 'BX' 'BY'};
trapdel = offraw.T2F - offraw.T1F;
for i = 1:length(fnames)
    [off.(fnames{i}), off.td] = tsoffset( trapdel, offraw.(fnames{i})); 
    %Smooth the offset
    off.(fnames{i}) = smooth(off.(fnames{i}), 5);
end
out.off = off;

%Read data
datraw = timeshareread(fpdat, dtype);
%Extract meta
opts.Fsamp = 1/datraw.meta.hdr(3);
% opts.convTrapX = 160.2656; disp('Using Meitner conversion of 160nm/MHz') %nm/MHz, for Meitner
opts.convTrapX = 142; disp('Using Meitner conversion of 142nm/MHz') %nm/MHz, for Boltzmann
% opts.convGrnX = 1014.982; %nm/V, for Meitner
opts.raA = 500;
opts.raB = 500;

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
out.extension = hypot( (datraw.T2F-datraw.T1F)*opts.convTrapX  - cal.AX.a*datraw.AX + cal.BX.a*datraw.BX, ...
                                                               - cal.AY.a*datraw.AY + cal.BY.a*datraw.BY )...
                       - opts.raA - opts.raB;
%Calculate total force = hypot( forX, forY ) using differential force (average of forces)
out.force = hypot((out.forceBX - out.forceAX)/2, ...
                  (out.forceBY - out.forceAY)/2);

%Define time vector, dt = 1/Fs
len = length(out.force);
out.time = single(1:len) / opts.Fsamp;

%Debug
figure, plot(dattd), hold on, rectangle('Position', [ 1 min(off.td) length(dattd) max(off.td)-min(off.td) ] )

%Save
[p, f, ~] = fileparts(fpdat);
tsdata = out; %#ok<NASGU>
outfp = sprintf('%s\\%s.mat', p ,f); 
save( outfp, 'tsdata' )
