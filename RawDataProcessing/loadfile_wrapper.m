function [out, opts] = loadfile_wrapper(filepath, inOpts)
%Loads an .dat file, handles a variety of sources, and renames the output so they can be processed similarly
%Outputs QPDs (V, {A B} x {X Y S}) and trap separation (nm, {TX TY})

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
        out=dat;
    case 'Boltzmann'
        opts.datType = 'single';
        opts = handleOpts(opts, inOpts);
        dat = timeshareread(filepath, opts.datType);
        if isfield(dat, 'T1F')
            dat.TX = (dat.T2F - dat.T1F) * opts.convTrapX;
            dat.TY = zeros(size(dat.TX));
        end
        out=dat;
    case 'Mini'
        error('Minis not yet handled!')
    case 'Lumicks'
        error('Lumicks not yet handled!')
    otherwise
        error('Instrument %s not recognized', opts.Instrument)
end







