function [out, opts] = loadfile_wrapper(filepath, inOpts)
%Loads an .dat file, handles a variety of sources, and renames the output so they can be processed similarly
%Outputs QPDs (V, {A B} x {X Y S}) and trap separation (nm, {TX TY})

if nargin < 1 || isempty(filepath)
    [f, p] = uigetfile({'*.dat' 'Raw Data'; '*.h5' 'Lumicks Files'});
    filepath = fullfile(p,f);
end
if nargin < 2
    inOpts = DataOptsPopup;
end

%Trap offsets should be set in inOpts, but if these are unset, 
opts.offTrapX = 0;
opts.offTrapY = 0;
opts.convTrapX = 1;
opts.convTrapY = 1;
% opts = [];

switch inOpts.Instrument
    case {'HiRes' 'HiRes PSD' 'HiRes bPD'}
        %Defaults for readDat
        opts.numLanes = 8;
        opts.numSamples = 1;
        opts.numEndian = 1;
        opts.datType = 'single';
        opts = handleOpts(opts, inOpts);
        
        %Cal files are written differently, so check if this is a hifreq file or not
        [p, f, e] = fileparts(filepath);
        if exist(fullfile(p, ['a' f e]), 'file')
            %If the file with an 'a' prepended to it exists, then it is a cal file
            dat = processHiFreq(filepath);
            dat.AS = dat.SA;
            dat.BS = dat.SB;
            dat.TX = (dat.MX - opts.offTrapX) * opts.convTrapX;
            dat.TY = (dat.MY - opts.offTrapY) * opts.convTrapY;
            out = rmfield(dat, {'SA' 'SB' 'MX' 'MY'});
        elseif exist(fullfile(p, [f '_init' e]), 'file')
            %If the file with '_init' is appended, this is a two-trap save
            %Read _init file, which is the values at time zero
            %Oops, forgot to remove header(?), so first number is trash
            initdat = readDat(fullfile(p, [f '_init' e]), 1, 9, opts.datType, opts.numEndian);
            initdat = initdat(2:end);
            %Read data file, which [should be] 2xn. Hardcode it, for now.
            dat = readDat(filepath, 1, 2, opts.datType, opts.numEndian);
            len = size(dat,2);
            out.AY = initdat(1)*ones(1,len);
            out.BY = initdat(2)*ones(1,len);
            out.AX = dat(1,:);
            out.BX = dat(2,:);
            out.TX = (initdat(5)*ones(1,len) - opts.offTrapX) * opts.convTrapX;
            out.TY = (initdat(6)*ones(1,len) - opts.offTrapY) * opts.convTrapY;
            out.AS = initdat(7)*ones(1,len);
            out.BS = initdat(8)*ones(1,len);
            out.T = single((0:length(out.AX)-1) / opts.Fsamp);
        elseif exist(fullfile(p, [f '_init2' e]), 'file')
            %If the file with '_init' is appended, this is a two-trap save V2
            % The only real difference is that the init file is properly sized
            %Read _init file, which is the values at time zero
            initdat = readDat(fullfile(p, [f '_init2' e]), 1, 8, opts.datType, opts.numEndian);
            %Read data file, which [should be] 2xn. Hardcode it, for now.
            dat = readDat(filepath, 1, 2, opts.datType, opts.numEndian);
            len = size(dat,2);
            out.AY = initdat(1)*ones(1,len);
            out.BY = initdat(2)*ones(1,len);
            out.AX = dat(1,:);
            out.BX = dat(2,:);
            out.TX = (initdat(5)*ones(1,len) - opts.offTrapX) * opts.convTrapX;
            out.TY = (initdat(6)*ones(1,len) - opts.offTrapY) * opts.convTrapY;
            out.AS = initdat(7)*ones(1,len);
            out.BS = initdat(8)*ones(1,len);
            out.T = single((0:length(out.AX)-1) / opts.Fsamp);
        elseif exist(fullfile(p, [f '_init3' e]), 'file')
            %If _init3, this is 500kHz with 3 lanes AX BX MX
            %Read _init file, which is the values at time zero
            initdat = readDat(fullfile(p, [f '_init3' e]), 1, 9, opts.datType, opts.numEndian); %Wrong header
            initdat = initdat(2:end);
            %Read data file, which [should be] 2xn. Hardcode it, for now.
            dat = readDat(filepath, 1, 3, opts.datType, opts.numEndian);
            len = size(dat,2);
            out.AY = initdat(1)*ones(1,len);
            out.BY = initdat(2)*ones(1,len);
            out.AX = dat(1,:);
            out.BX = dat(2,:);
            out.TX = (dat(3,:) - opts.offTrapX) * opts.convTrapX;
            out.TY = (initdat(6)*ones(1,len) - opts.offTrapY) * opts.convTrapY;
            out.AS = initdat(7)*ones(1,len);
            out.BS = initdat(8)*ones(1,len);
            out.T = single((0:length(out.AX)-1) / opts.Fsamp);
        else
            dat = readDat(filepath, opts.numSamples, opts.numLanes, opts.datType, opts.numEndian);
            out.AY = dat(1,:);
            out.BY = dat(2,:);
            out.AX = dat(3,:);
            out.BX = dat(4,:);
            out.TX = (dat(5,:) - opts.offTrapX) * opts.convTrapX;
            out.TY = (dat(6,:) - opts.offTrapY) * opts.convTrapY;
            out.AS = dat(7,:);
            out.BS = dat(8,:);
            out.T = single((0:length(out.AX)-1) / opts.Fsamp);
        end
        
        %If the date is Dec 22 2021 or later, negate the four forces (PSD > QPD swap)
%         dt = daysdif( '12/22/2021', datetime(f(1:6), 'InputFormat', 'MMddyy') ); %Assumes file starts MMDDYY
        dt  = dateislater('122221', f(1:6), 'MMDDYY'); %Rewrite to remove financial toolbox dependency in @daysdif
        dt2 = dateislater('012821', f(1:6), 'MMDDYY');
        if dt2 >= 0 %BPD era, 'Y' becomes
            %Sum is split in two, stored in 1/2 and 7/8 channels (-Y and S)
            % But also sum is bad, so don't use it
            out.AS = -out.AY + out.AS;
            out.AY = zeros(size(out.AY));
            out.BS = -out.BY + out.BS;
            out.BY = zeros(size(out.BY));
        elseif dt >= 0 %QPD era, negate outputs
            out.AY = out.AY * -1;
            out.BY = out.BY * -1;
            out.AX = out.AX * -1;
            out.BX = out.BX * -1;
        end %PSD era, do nothing
    case 'Meitner'
        opts.datType = 'int16';
        opts = handleOpts(opts, inOpts);
        dat = timeshareread(filepath, opts.datType);
        if isfield(dat, 'T1F')
            dat.TX = (dat.T2F - dat.T1F) * opts.convTrapX;
            dat.TY = zeros(size(dat.TX));
        end
        %Swap A and B traps, to match HiRes' formatting (B on left, A on right)
        ax = dat.AX;
        ay = dat.AY;
        as = dat.AS;
        dat.AX = dat.BX;
        dat.AY = dat.BY;
        dat.AS = dat.BS;
        dat.BX = ax;
        dat.BY = ay;
        dat.BS = as;
        
        out=dat;
    case 'Boltzmann'
        opts.datType = 'single';
        opts = handleOpts(opts, inOpts);
        dat = timeshareread(filepath, opts.datType);
        if isfield(dat, 'T1F')
            dat.TX = (dat.T2F - dat.T1F) * opts.convTrapX;
            dat.TY = zeros(size(dat.TX));
        end
        %Swap A and B traps, to match HiRes' formatting (B on left, A on right)
        ax = dat.AX;
        ay = dat.AY;
        as = dat.AS;
        dat.AX = dat.BX;
        dat.AY = dat.BY;
        dat.AS = dat.BS;
        dat.BX = ax;
        dat.BY = ay;
        dat.BS = as;
        
        out=dat;
    case 'Mini'
        error('Minis not yet handled!')
    case 'Lumicks'
        opts = handleOpts(opts, inOpts);
        
        rawdat = readh5all(filepath);
        %Lumicks outputs force directly, so divide by cal (in case we want to recalibrate) and make S = 1
        cal = rawdat.cal;
        %Lumicks traps are 1 fixed / 2 movable, usually with 2 to the right, so 1 is B and 2 is A
        dat.AX = rawdat.ForceHF_Force2x / cal.AX.ak;
        dat.BX = rawdat.ForceHF_Force1x / cal.BX.ak;
        dat.AY = rawdat.ForceHF_Force2y / cal.AY.ak;
        dat.BY = rawdat.ForceHF_Force1y / cal.BY.ak;
        dat.AS = ones(size(dat.AX));
        dat.BS = dat.AS;
        
        %Do mirror calibration, if mirror options are not passed.
        if opts.convTrapX == 0 %If = 0, then it isn't set, so calibrate it. This should be on the offset
            %Calibrate the mirror by finding the linear relation between the video tracking and Trapposition_N1X
            dd = rawdat.Distance_Distance1.Value(:)'*1000;
            %Going to assume that the times are synched well enough, so we can use linspace to sample Trapposition_N1X
            tt = round(linspace(1, length(rawdat.Trapposition_N1X), length(dd)+1));
            mx = rawdat.Trapposition_N1X(tt(1:end-1));
            %Some dd's will be 0, when bead tracking fails, so remove these
            ddki = dd ~= 0;
            mx = mx(ddki);
            dd = dd(ddki);
            %Linfit these
            [pf, S] = polyfit(mx, dd, 1);
            %Make sure this fit is okay. Let's use the R^2 value. Good fitting -> R2 = 0.99+
            %...I know this isn't quite what R2 means, but eh.
            r2 = 1 - sum(S.normr.^2) / sum( ( mean(dd) - dd ) .^2 );
            if r2 < .99
                [~, f, ~] = fileparts(filepath);
                warning('Mirror fitting may be poor in file %s since R^2 is %0.3f, plotting ', f, r2)
                figure('Name', sprintf('Mirror fitting for file %s', f))
                plot(mx, dd), hold on, plot(mx, polyval(pf, mx))
            end
            %And set this polyfit to the TrapX conversions
            opts.offTrapX = pf(2) / pf(1); %We're going to do y = m (x + b/m)
            opts.convTrapX = pf(1);
            %Assume the Y component is contained in the fitting between Distance and X, so zero them
            opts.offTrapY = 0;
            opts.convTrapY = 0;
        end
        %Make TX from Trapposition_N1X
        dat.TX = (rawdat.Trapposition_N1X + opts.offTrapX) * opts.convTrapX;

        %Lumicks subtracts out the bead diameters, add them back.
        dat.TX = dat.TX + inOpts.raA + inOpts.raB;
        
        dat.TY = zeros(size(dat.AX));
        %Lumicks does not downsample, so do so here.
        if isfield(inOpts, 'Fsamp')
            dSamp = max(round(78125 / inOpts.Fsamp),1);
            fns = fieldnames(dat);
            for i = 1:length(fns)
                dat.(fns{i}) = windowFilter(@mean, dat.(fns{i}), [], dSamp);
            end
        end
        out = dat;
        opts.Fs = 78125 / dSamp;
%         opts.lumsgn = sgn; %Save this sign if it needs to be propagated (e.g. through offset + data)
    otherwise
        error('Instrument %s not recognized', opts.Instrument)
end







