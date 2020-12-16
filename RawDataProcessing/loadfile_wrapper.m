function [out, opts] = loadfile_wrapper(filepath, inOpts)
%Loads an .dat file, handles a variety of sources, and renames the output so they can be processed similarly
%Outputs QPDs (V, {A B} x {X Y S}) and trap separation (nm, {TX TY})

if nargin < 1
    [f, p] = uigetfile('*.dat');
    filepath = fullfile(p,f);
end
if nargin < 2
    inOpts = DataOptsPopup;
end

%Trap offsets should be set in inOpts, and if these are unset, 
% opts.offTrapX = 0;
% opts.offTrapY = 0;
% opts.convTrapX = 1;
% opts.convTrapY = 1;
opts = [];

switch inOpts.Instrument
    case 'HiRes'
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







