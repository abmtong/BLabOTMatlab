function EzLumConvert(inOpts)

%Simply convert a lumicks h5 into a Phage-style matlab thing

opts.Fs = 78125; %Lumicks fsamp, 5^7
opts.dsamp = 25; %Downsample by this amount, to e.g. 3125Hz
opts.fliptraps = 0; %Assume trap 2 is left trap, trap 1 is right trap. =1 to flip
opts.xwlcopts = [50 900 4.14];
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
    ext = raw.Distance_PiezoDistance;
    
    %Contour, assume XWLC
    if isempty(frc)
        con = [];
    else
        con = ext ./ XWLC(frc, opts.xwlcopts(1), opts.xwlcopts(2), opts.xwlcopts(3) ) /.34 *1000;
    end
    
    %Time
    outFs = opts.Fs / opts.dsamp;
    tim = (0:length(frc)-1) / outFs;
    
    %Maybe save some metadata...
    
    %Assemble output stepdata
    stepdata = [];
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








