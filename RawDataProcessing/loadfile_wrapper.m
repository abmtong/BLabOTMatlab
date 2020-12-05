function [out, opts] = loadfile_wrapper(filepath, inOpts)
%Loads an .dat file, handles a variety of sources, and renames the output so they can be processed similarly
%Outputs QPDs (V, {A B} x {X Y S}) and trap separation (nm, {TX TY})

if nargin < 1
    [f p] = uigetfile('*.dat');
    filepath = fullfile(p,f);
end
if nargin < 2
    inOpts = DataOptsPopup;
end

opts.offTrapX = 0;
opts.offTrapY = 0;
opts.convTrapX = 1;
opts.convTrapY = 1;

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
        rawdat = readh5all(filepath);
        %Lumicks outputs force directly, so divide by cal (in case we want to recalibrate) and make S = 1
        cal = rawdat.cal;
        %Trap might be in opposite orders, let's handle this by negation
        maxf = max(rawdat.ForceHF_Force2x - rawdat.ForceHF_Force1x);
        minf = min(rawdat.ForceHF_Force2x - rawdat.ForceHF_Force1x);
        %BX(2x) should be positive, so maxf should be > minf. If not, negate.
        sgn = sign(maxf - minf);
        dat.AX = sgn * rawdat.ForceHF_Force1x / cal.AX.ak; %Negate , for sign convention
        dat.BX = sgn * rawdat.ForceHF_Force2x / cal.BX.ak;
        dat.AY = sgn * rawdat.ForceHF_Force1y / cal.AY.ak;
        dat.BY = sgn * rawdat.ForceHF_Force2y / cal.BY.ak;
        dat.AS = ones(size(dat.AX));
        dat.BS = dat.AS;
        %PiezoDistance might not always be ok, so check if it's all 0s or not
        if all(~rawdat.Distance_PiezoDistance)
            %PiezoDistance get from interpolating the Distance channel
            d = abs(rawdat.Distance_Distance1.Value - rawdat.Distance_Distance2.Value)*1000; %um -> nm
            t = double(rawdat.Distance_Distance1.Timestamp - rawdat.Distance_Distance1.Timestamp(1)) / 1e9; %Unit is ns, u64
            dat.TX = interp1(t, d, (0:length(dat.AX))/78125, 'linear', median(d));
            [~, f, ~] = fileparts(filepath);
            warning('Lumicks file %s loaded using low-frequency distance. Distances may be off.', f)
        else
            dat.TX = rawdat.Distance_PiezoDistance*1000; %um -> nm
        end
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
        opts.lumsgn = sgn; %Save this sign if it needs to be propagated (e.g. through offset + data)
    otherwise
        error('Instrument %s not recognized', opts.Instrument)
end







