function EzLumConvert(inOpts)

%Simply convert a lumicks h5 into a Phage-style matlab thing

opts.Fs = 78125; %Lumicks fsamp, 5^7
opts.dsamp = 25; %Downsample by this amount, to e.g. 3125Hz
opts.fliptraps = 0; %Assume trap 2 is left trap (B), trap 1 is right trap (A). =1 to flip
opts.xwlcopts = [50 900 4.14]; %For contour conversion
opts.saveraw = 0; %Save raw file as .mat after downsampling
opts.mirconv = [2.029, -9.4581]; %Multiplier for trap position. Seems to be valid 2022/10 - 2023/06 at least.
opts.output = 0; %1 = Phage file, 0 = ForceExtension file

if nargin > 0
    opts = handleOpts(opts, inOpts);
end

%Get files
[f, p] = uigetfile('*.*', 'Pick a h5 or mat file', 'Mu', 'on');

if ~p
    return
end

if ~iscell(f)
    f = {f};
end

%For each file...
len = length(f);
for i = 1:len
    %Check extension
    [~, fil, ext] = fileparts(f{i});
    
    %Handle loading the raw h5 vs. the saved, downsampled mat file
    switch ext
        case '.h5'
            %Read file with readh5all
            raw = readh5all(fullfile(p, f{i}));
            
            %Downsample fields that are 1xn doubles
            fns = fieldnames(raw);
            for j = 1:length(fns)
                tmp = raw.(fns{j});
                if isa(tmp, 'double')
                    raw.(fns{j}) = windowFilter(@mean, tmp, [], opts.dsamp);
                end
            end
            %Save this file in a subdir if asked
            if opts.saveraw
                dirnam = 'LumRaw';
                if ~exist(fullfile(p, dirnam), 'dir')
                    mkdir(fullfile(p, dirnam))
                end
                %Rename raw as 'lumraw'
                lumraw = raw; %#ok<NASGU>
                %Save
                save(fullfile(p, dirnam, [fil '_RAW.mat']), 'lumraw')
            end
        case 'mat'
            %Just load data into raw
            raw = load( fullfile(p, f{i}) );
            fns = fieldnames(raw);
            raw = raw.(fns{1});
    end
    
    %Extract force fields
    fax = raw.ForceHF_Force1x;
    fay = raw.ForceHF_Force1y;
    fbx = raw.ForceHF_Force2x;
    fby = raw.ForceHF_Force2y;
    
    % This naming convention then matches HiRes, A is right trap
    
    %Cal is probably in raw but lets just grab it again
    [~, cal] = h5calread(fullfile(p, f{i}));
    cfn = fieldnames(cal);
    cal = cal.(cfn{end});
    
    %And calculate bead ext
    beadext = - fax/cal.x1.k + fbx/cal.x2.k; %This should be two positive terms
         
    %Flip traps if asked for
    if opts.fliptraps
        tmpax = fax;
        fax = fbx;
        fbx = tmpax;
        
        tmpay = fay;
        fay = fby;
        fby = tmpay;
        
        %And flip bead ext
        beadext = -beadext;
    end
    
    %Calculate force
    frc = hypot(fbx - fax, fby - fay)/2;
    
    %Get trap pos. Use a calibration between Distance1 and TrappositionN1X obtained from EzLumConvert_Mirror
    tpos = raw.Trapposition_N1X * opts.mirconv(1) + opts.mirconv(2);
    tpos = tpos * 1000; %um to nm
    
    %Remove bead displacements
    % First let's check that we've got the right signs for the traps: AX should be negative, BX positive
    sgna = sign(median(fax));
    sgnb = sign(median(fbx));
    %Four cases based on sign. Sign of [A, B] should be [-, +]
    if sgna == -1 && sgnb == 1
        %Signs are correct
    elseif sgna == 1 && sgnb == -1
        warning('Trap signs might be flipped, check and fix with opts.fliptraps = %d', double(~opts.fliptraps))
    else
        warning('Trap signs are weird, check')
    end

    %Extension = trap pos - beadext;
    ext = tpos - beadext;
    
    %Contour, assume XWLC
    con = ext ./ XWLC(frc, opts.xwlcopts(1), opts.xwlcopts(2), opts.xwlcopts(3) ) /.34 ;
    
    %Time
    outFs = opts.Fs / opts.dsamp;
    tim = (0:length(frc)-1) / outFs;
    
    %Fluorescence
    hasdata = 0;
    if isfield(raw, 'Infowave_Infowave') && ~all(~raw.Infowave_Infowave) %Only continue if we have the infowave
        if isfield(raw, 'Photoncount_Green')
            %Save and convert average count to kHz
            [fl.gg, fl.at] = drawimageV2(raw.Infowave_Infowave, raw.Photoncount_Green);
            fl.gg = fl.gg * opts.Fs/1e3; %Convert to kHz
            %             stepdata.apdT = at;
            fl.sz = size(fl.gg);
            hasdata = 1;
        end
        if isfield(raw, 'Photoncount_Red')
            %Save and convert average count to kHz
            [fl.rr, fl.at] = drawimageV2(raw.Infowave_Infowave, raw.Photoncount_Red);
            fl.rr = fl.rr * opts.Fs/1e3; %Convert to kHz
            %             stepdata.apd1 = rr;
            %             stepdata.apdT = at;
            fl.sz = size(fl.rr);
            hasdata = 1;
        end
        if isfield(raw, 'Photoncount_Blue')
            %Save and convert average count to kHz
            [fl.bb, fl.at] = drawimageV2(raw.Infowave_Infowave, raw.Photoncount_Blue);
            fl.bb = fl.bb * opts.Fs/1e3; %Convert to kHz
            %             stepdata.apd1 = bb;
            %             stepdata.apdT = at;
            fl.sz = size(fl.bb);
            hasdata = 1;
        end
        
        %Combine to an image
        if hasdata %Only if any Photoncount_* exists
            stepdata.apdT = fl.at;
            img = zeros( [ fl.sz 3] ); %Assign xyz
            if isfield(fl, 'gg' );
                img(:,:,2) = fl.gg;
            end
            if isfield(fl, 'rr' );
                img(:,:,1) = fl.rr;
            end
            if isfield(fl, 'bb' );
                img(:,:,3) = fl.bb;
            end
            stepdata.apdimg = img;
        end
    else
        %Else, just save data if it exists
        if isfield(raw, 'Photoncount_Green')
            %Downsample and save
            stepdata.apd1 = windowFilter(@mean, double(raw.Photoncount_Green ), [], opts.dsamp);
            hasdata = 1;
        end
        if isfield(raw, 'Photoncount_Red')
            %Downsample and save
            stepdata.apd2 = windowFilter(@mean, double(raw.Photoncount_Red ), [], opts.dsamp);
            hasdata = 1;
        end
        if isfield(raw, 'Photoncount_Blue')
            %Downsample and save
            stepdata.apd3 = windowFilter(@mean, double(raw.Photoncount_Blue ), [], opts.dsamp);
            hasdata = 1;
        end
        %Add time field if we saved any data
        if hasdata
            stepdata.apdT = tim; %Will just be synced to trap time
        end
        
    end
    
    
    %Maybe save some metadata...
    %Let's save the Distance1 curve as the offset
    dx = raw.Distance_Distance1.Value';
    dt = double(raw.Distance_Distance1.Timestamp - raw.Distance_Distance1.Timestamp(1) )' / 1e9;
    %Write this in a way that will be plottable by PlotOff
    off.AX = dx * 1e3;
    off.AY = zeros(size(dx)); %Distance1
    dsamp = floor( length(ext) / length(dt) ); % floor( outFs * dt(2) );
    off.BX = windowFilter(@mean, ext, [], dsamp); %Extension
    off.BX = off.BX( 1:length(dt) );
    off.BY = zeros(size(dx));
    off.TX = dt;
    
    switch opts.output
        case 1 %Phage data
            %Assemble output stepdata
            stepdata.forceAX = {fax};
            stepdata.forceBX = {fbx};
            stepdata.forceAY = {fay};
            stepdata.forceBY = {fby};
            stepdata.extension = {ext};
            stepdata.force = {frc};
            stepdata.time = {tim};
            stepdata.contour = {con};
            stepdata.cal = raw.cal;
            stepdata.off = off;
            %Save
            [~, fstrip, ~] = fileparts(f{i});
            save(fullfile(p, [fstrip '.mat']), 'stepdata')
        otherwise
            %Assemble output ContourData
            ContourData.forceAX = fax;
            ContourData.forceBX = fbx;
            ContourData.forceAY = fay;
            ContourData.forceBY = fby;
            ContourData.extension = ext;
            ContourData.force = frc;
            ContourData.time = tim;
%             ContourData.contour = {con};
            ContourData.cal = raw.cal;
            ContourData.off = off;
            %Save
            [~, fstrip, ~] = fileparts(f{i});
            save(fullfile(p, [fstrip '.mat']), 'ContourData')
    end
    
    
end








