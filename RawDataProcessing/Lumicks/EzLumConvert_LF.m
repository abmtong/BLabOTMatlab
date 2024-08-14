function EzLumConvert_LF(inOpts)
%Simply convert a lumicks h5 into a Phage-style matlab thing
%LF = low frequency ver (use the camera tracking data

opts.Fs = 78125; %Lumicks fsamp, 5^7. Still needed for fluorescence
opts.dsamp = 25; %Downsample big fields by this amount, to e.g. 3125Hz
opts.fliptraps = 0; %Assume trap 2 is left trap, trap 1 is right trap. =1 to flip
opts.xwlcopts = [50 900 4.14]; %For contour conversion
opts.saveraw = 0; %Save raw file as .mat after downsampling

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
            %Just load
            raw = load( fullfile(p, f{i}) );
            fns = fieldnames(raw);
            raw = raw.(fns{1});
    end
    
    %Extract f, ext fields and downsample
    %     fax = windowFilter(@mean, raw.ForceHF_Force1x, [], opts.dsamp);
    %     fay = windowFilter(@mean, raw.ForceHF_Force1y, [], opts.dsamp);
    %     fbx = windowFilter(@mean, raw.ForceHF_Force2x, [], opts.dsamp);
    %     fby = windowFilter(@mean, raw.ForceHF_Force2y, [], opts.dsamp);
    fax = raw.ForceLF_Force1x.Value;
    fay = raw.ForceLF_Force1y.Value;
    fbx = raw.ForceLF_Force2x.Value;
    fby = raw.ForceLF_Force2y.Value;
    
    % This naming convention then matches HiRes, A is left trap
    
    %Flip traps if asked for
    if opts.fliptraps
        tmpax = fax;
        fax = fbx;
        fbx = tmpax;
        
        tmpay = fay;
        fay = fby;
        fby = tmpay;
    end
    
    %Calculate force
    frc = hypot(fbx - fax, fby - fay)/2;
    
    %Extension as just PiezoMirror for now
%     ext = windowFilter(@mean, raw.Distance_PiezoDistance, [], opts.dsamp);

    %Get extension, a few possible fields
%     if isfield(raw, 'Distance_PiezoDistance')
%         ext = raw.Distance_PiezoDistance;
%     elseif isfield(raw, 'Trapposition_N1X')
%         % The zero for Trapposition_N1X is not the 0 for bead sep, let's set the initial value to the initial Distance1 value
%         ext = raw.Trapposition_N1X - mean(raw.Trapposition_N1X(1:1e2)) + raw.Distance_Distance1.Value(1); %unit is um. Will be converted to bp later.
%     end
    ext = raw.Distance_Distance1.Value * 1000;
%     ext = ext * 1000; %um to nm
    
    
    %Contour, assume XWLC
    if isempty(frc)
        con = [];
    else
        con = ext ./ XWLC(frc, opts.xwlcopts(1), opts.xwlcopts(2), opts.xwlcopts(3) ) /.34 ;
    end
    
    %Time
%     outFs = opts.Fs / opts.dsamp;
    tim = double( raw.Distance_Distance1.Timestamp ) / 1e9 ;
    tim = tim - tim(1);
    
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
    
    %Assemble output stepdata
    stepdata.forceAX = {fax};
    stepdata.forceBX = {fbx};
    stepdata.forceAY = {fay};
    stepdata.forceBY = {fby};
    stepdata.extension = {ext};
    stepdata.force = {frc};
    stepdata.time = {tim};
    stepdata.contour = {con};
    
    %Save
    [~, fstrip, ~] = fileparts(f{i});
    save(fullfile(p, [fstrip '.mat']), 'stepdata')
end








function EzLumConvert(inOpts)

%Simply convert a lumicks h5 into a Phage-style matlab thing

opts.Fs = 78125; %Lumicks fsamp, 5^7
opts.dsamp = 25; %Downsample by this amount, to e.g. 3125Hz
opts.fliptraps = 0; %Assume trap 2 is left trap, trap 1 is right trap. =1 to flip
opts.xwlcopts = [50 900 4.14]; %For contour conversion
opts.saveraw = 1; %Save raw file as .mat after downsampling

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
            %Just load
            raw = load( fullfile(p, f{i}) );
            fns = fieldnames(raw);
            raw = raw.(fns{1});
    end
    
    %Extract f, ext fields and downsample
    %     fax = windowFilter(@mean, raw.ForceHF_Force1x, [], opts.dsamp);
    %     fay = windowFilter(@mean, raw.ForceHF_Force1y, [], opts.dsamp);
    %     fbx = windowFilter(@mean, raw.ForceHF_Force2x, [], opts.dsamp);
    %     fby = windowFilter(@mean, raw.ForceHF_Force2y, [], opts.dsamp);
    fax = raw.ForceHF_Force1x;
    fay = raw.ForceHF_Force1y;
    fbx = raw.ForceHF_Force2x;
    fby = raw.ForceHF_Force2y;
    
    % This naming convention then matches HiRes, A is left trap
    
    %Flip traps if asked for
    if opts.fliptraps
        tmpax = fax;
        fax = fbx;
        fbx = tmpax;
        
        tmpay = fay;
        fay = fby;
        fby = tmpay;
    end
    
    %Calculate force
    frc = hypot(fbx - fax, fby - fay)/2;
    
    %Extension as just PiezoMirror for now
%     ext = windowFilter(@mean, raw.Distance_PiezoDistance, [], opts.dsamp);

    %Get extension, a few possible fields
    if isfield(raw, 'Distance_PiezoDistance')
        ext = raw.Distance_PiezoDistance;
    elseif isfield(raw, 'Trapposition_N1X')
        % The zero for Trapposition_N1X is not the 0 for bead sep, let's set the initial value to the initial Distance1 value
        ext = raw.Trapposition_N1X - mean(raw.Trapposition_N1X(1:1e2)) + raw.Distance_Distance1.Value(1); %unit is um. Will be converted to bp later.
    end
    ext = ext * 1000; %um to nm
    
    
    %Contour, assume XWLC
    if isempty(frc)
        con = [];
    else
        con = ext ./ XWLC(frc, opts.xwlcopts(1), opts.xwlcopts(2), opts.xwlcopts(3) ) /.34 ;
    end
    
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
    
    %Assemble output stepdata
    stepdata.forceAX = {fax};
    stepdata.forceBX = {fbx};
    stepdata.forceAY = {fay};
    stepdata.forceBY = {fby};
    stepdata.extension = {ext};
    stepdata.force = {frc};
    stepdata.time = {tim};
    stepdata.contour = {con};
    
    %Save
    [~, fstrip, ~] = fileparts(f{i});
    save(fullfile(p, [fstrip '.mat']), 'stepdata')
end








