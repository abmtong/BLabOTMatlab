function out = ProcessOneDataV2(path, inNums, inOpts)
%% Processes one data-offset-cal combo, numbers specified in inNums, path to the root folder, with options

if nargin < 3
    inOpts = DataOptsPopup;
    if isempty(inOpts)
        return
    end
end

%% Compose filenames
if nargin < 2 || isempty(inNums)
    if nargin < 1
        path = [];
    end
    %Pick 3 files, 'data/off/cal' order
    [file{3}, path] = uigetfile([path '*.dat'], 'Pick your calibration file');
    if ~path
        return
    end
    [file{2}, path] = uigetfile([path filesep '*.dat'], 'Pick your offset file');
    [file{1}, path] = uigetfile([path filesep '*.dat'], 'Pick your data file');
else
    switch inOpts.Instrument
        case {'HiRes' 'HiRes PSD' 'HiRes-legacy' 'HiRes bPD'}
            spfn = '%sN%02d.dat';
        case 'Boltzmann'
            spfn = '%s_%03d.dat';
        case 'Meitner'
            spfn = '%s_%03d.dat';
        case 'Lumicks'
            spfn = '%s-%06d*.h5';
        otherwise
            error('Instrument %s not recognized', inOpts.Instrument)
    end
    file = arrayfun(@(x) sprintf(spfn, inOpts.mmddyy, x), inNums, 'Un', 0);
    %For Lumicks, there's some trailing name, use dir to find it
    if strcmp(inOpts.Instrument, 'Lumicks')
        file = cellfun(@(x) dir(fullfile(path, x)), file, 'Un', 0);
        file = cellfun(@(x) x.name, file, 'Un', 0);
        ie = any(cellfun(@isempty, file));
        if any(ie)
            error('File(s) %s not found\n', [file{ie}]);
        end
    end
end

startT = tic;

%No default opts, so just rename for now
opts = inOpts;

%% Calibrate
%Assemble Cal options
calopts = opts.cal;
calopts.raA = opts.raA;
calopts.raB = opts.raB;
calopts.Instrument = opts.Instrument;
calopts.normalize = opts.normalize;
%Get Fs
switch calopts.Instrument
    case {'HiRes' 'HiRes PSD'}
%         calopts.Fsamp = 62500; %Hard code this, at least for now
        cal = ACalibrateV2(fullfile(path, file{3}), calopts);
        drawnow %Can inspect calibration while program continues
    case 'HiRes bPD'
%         calopts.Fsamp = 70000; %Hard code this, at least for now
        cal = ACalibrateV2(fullfile(path, file{3}), calopts);
        drawnow %Can inspect calibration while program continues
    case {'Boltzmann' 'Meitner'}
        %Read the header to get Fs
        calhdr = timesharereadhdr(fullfile(path, file{3}));
        calopts.Fsamp = 1/calhdr.Fsamp;
        cal = ACalibrateV2(fullfile(path, file{3}), calopts);
        drawnow %Can inspect calibration while program continues
    case 'Lumicks'
        %Just load calibration from the cal file
        cal = h5calread(fullfile(path, file{3}));
end


%% Offset
%Offset data is taken by holding the beads at a varying distance apart, to see laser-bead interactions (without tether)
switch opts.Protocol
    case 'One Trap'
        %If it's in one-trap mode, just take the mean as the offset.
        %1-trap offset is just a single value, the mean of the cal data [or whatever is passed in slot 2]
        rawoff = loadfile_wrapper(fullfile(path, file{2}), opts);
        fnames = {'AX' 'AY' 'AS' 'BX' 'BY' 'BS'};
        for i = 1:length(fnames)
            off.(fnames{i}) = [1 1] * mean(rawoff.(fnames{i}));
        end
        %Set TX,TY to span the entire range, so the later interp to always return a single value
        off.TX = [0 1e9];
        off.TY = [0 1e9];
        %Also, set the calibration for the non-trap
        if strcmp(opts.oneTrap, 'B')
            dx = 'AX';
            dy = 'AY';
        else
            dx = 'BX';
            dy = 'BY';
        end
        cal.(dx).a = 1e-5;
        cal.(dx).k = 1e-5;
        cal.(dy).a = 1e-5;
        cal.(dy).k = 1e-5;
    otherwise
        switch inOpts.Instrument
            case {'HiRes' 'HiRes PSD'}
                %HiRes offset is pre-processed:
                %rawoff V3 is a 8x[] matrix, with each row being a detector in order [AY BY AX BX MX MY SA SB]
                % rawoff = readDat(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)));
                %OffsetV2 is a 8x[]x2 matrix, with (:,:,2) being the local std at each point. We read it as 8x[], so the second half of dimension 2 is std data
                rawoff = readDat(fullfile(path, file{2}), 1, 8, 'double', 1);
                rawoff = rawoff(:,1:(end/2)); %drop the std data
                %Assign to fields
                off.AY = rawoff(1,:);
                off.BY = rawoff(2,:);
                off.AX = rawoff(3,:);
                off.BX = rawoff(4,:);
                off.TX = (rawoff(5,:) - opts.offTrapX) * opts.convTrapX;
                off.TY = (rawoff(6,:) - opts.offTrapY) * opts.convTrapY;
                off.AS = rawoff(7,:);
                off.BS = rawoff(8,:);
                
                %If the date is Dec 22 2021 or later, negate the four forces (PSD > QPD swap)
                dt = dateislater('122221', file{2}(1:6), 'MMDDYY'); %Assumes file starts MMDDYY
%                 dt = daysdif( '12/22/2021', datetime(, 'InputFormat', 'MMddyy') );  Remove daysdif (Financial toolbox)
                if dt >= 0
                    off.AY = off.AY * -1;
                    off.BY = off.BY * -1;
                    off.AX = off.AX * -1;
                    off.BX = off.BX * -1;
                end
                
                %Ghe's offset is this
                %  rawoff = offset_legacy(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)));
                %  fprintf('Using Ghe''s offset.\n');
            case 'HiRes bPD'
                %HiRes offset is pre-processed:
                %rawoff V3 is a 8x[] matrix, with each row being a detector in order [AY BY AX BX MX MY SA SB]
                % rawoff = readDat(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)));
                %OffsetV2 is a 8x[]x2 matrix, with (:,:,2) being the local std at each point. We read it as 8x[], so the second half of dimension 2 is std data
                rawoff = readDat(fullfile(path, file{2}), 1, 8, 'double', 1);
                rawoff = rawoff(:,1:(end/2)); %drop the std data
                %Assign to fields
                %bPD has no Y values, sum = 1+7/2+8
                off.AY = zeros(size(rawoff(1,:)));
                off.BY = zeros(size(rawoff(2,:)));
                off.AX = rawoff(3,:);
                off.BX = rawoff(4,:);
                off.TX = (rawoff(5,:) - opts.offTrapX) * opts.convTrapX;
                off.TY = (rawoff(6,:) - opts.offTrapY) * opts.convTrapY;
                off.AS = rawoff(1,:)+rawoff(7,:);
                off.BS = rawoff(2,:)+rawoff(8,:);
            otherwise
                %These should just be a single f-d curve. Average down and use
                [rawoff, ~] = loadfile_wrapper(fullfile(path, file{2}), opts);
                %Average down to 100pts
                if isfield(rawoff, 'meta') && isfield(rawoff.meta, 'scanNSteps')
                    npul = max(round(rawoff.meta.scanNSteps/rawoff.meta.scanCycPerStep),1); %Scans in Timeshared are two-way, take the first way.
                else
                    switch inOpts.Instrument
                        case {'Boltzmann' 'Meitner'}
                            npul = 2;
                        case 'Lumicks'
                            npul = 1;
                    end
                end
                
                npts = 100*npul;
                navg = floor(length(rawoff.AS) / npts);
                off = [];
                fnames = {'AX' 'AY' 'AS' 'BX' 'BY' 'BS' 'TX' 'TY'};
                for i = 1:length(fnames)
                    off.(fnames{i}) = windowFilter(@mean, rawoff.(fnames{i})(1:round(end/npul)), [], navg);
                end
                
                %For Lumicks, offset is weird, set farthest trap sep as zero
                if strcmp(inOpts.Instrument, 'Lumicks')
                    for i = {'AX' 'AY' 'BX' 'BY'};
                        off.(i{1}) = off.(i{1}) - off.(i{1})(end);
                    end
%                     opts = handleOpts(opts, rawoffopts);
                end
                    
        end
end

%% Load data file
[rawdat, ~] = loadfile_wrapper(fullfile(path, file{1}), opts);

%Create some name-index sets to do in loop
detNames = {'AX' 'BX' 'AY' 'BY'};
detSums =  {'AS' 'BS' 'AS' 'BS'};
%% Normalize, apply offset to each detector.
for i = 1:4
    %Extract cell for convenience
    detNam = detNames{i};
    detSum = detSums{i};
    %Normalize offset and subtract it from the normalized data
    if opts.normalize
        rawdat.(detNam) = rawdat.(detNam) ./ rawdat.(detSum) - interp1( off.TX, off.(detNam)./off.(detSum), rawdat.TX, 'linear', median( off.(detNam)./off.(detSum) ) ); % Was interp1(--, 'extrap'), but this handles out-of-range poorly
    else
        rawdat.(detNam) = rawdat.(detNam) - interp1( off.TX, off.(detNam), rawdat.TX, 'linear', median( off.(detNam)./off.(detSum) ) ); % Was interp1(--, 'extrap'), but this handles out-of-range poorly
    end
    %Calculate force = AX * a * k
    out.(['force' detNam]) = rawdat.(detNam) * cal.(detNam).a * cal.(detNam).k;
end

%% Calculate extension  = hypot( TrapX + BeadsX , TrapY + BeadsY) - Bead Radii
%                      (Mirror(V)  -offsetMir(V)) *convMir(nm/V)  + A(NV)*alphaA(nm/NV) - B(NV)*alphaB(nm/NV)
out.extension = hypot( rawdat.TX + cal.AX.a*rawdat.AX - cal.BX.a*rawdat.BX, ...
                       rawdat.TY + cal.AY.a*rawdat.AY - cal.BY.a*rawdat.BY )...
                       - opts.raA - opts.raB - opts.extOffset;

%Calculate extension using "optimal coordinate" (see notes on 10/31/18), corrects for differing trap stiffnesses
%Assumes that force of noise is the same in both traps, which means to subtract their distance noise, we need to correct for trap k
%Two equations (need the total signal to stay constant while removing noise), two unknowns (scaling factors for each trap)
%{
%Scaling factors per trap and direction; notice if kAX=kBX then these scaling factors are both 1 (matches Moffitt, 2006)
%Moffitt 2006 ignores bead loading - it seems that bead loading raises alpha, lowers kappa - meaning one bead may be very different
aAX = cal.AX.k / (cal.AX.k + cal.BX.k)*2;
aBX = cal.BX.k / (cal.AX.k + cal.BX.k)*2;
aAY = cal.AY.k / (cal.AY.k + cal.BY.k)*2;
aBY = cal.BY.k / (cal.AY.k + cal.BY.k)*2;
out.extension = hypot( (rawdat(5,:)-opts.offTrapX)*opts.convTrapX + cal.AX.a*dat.AX*aAX - cal.BX.a*dat.BX*aBX, ...
                       (rawdat(6,:)-opts.offTrapY)*opts.convTrapY + cal.AY.a*dat.AY*aAY - cal.BY.a*dat.BY*aBY )...
                       - opts.raA - opts.raB;
%}
%% Calculate total force = hypot( forX, forY ) using differential force (average of forces)
out.force = hypot((out.forceBX - out.forceAX)/2, ...
                  (out.forceBY - out.forceAY)/2);

%Get Fs from meta if needed
switch calopts.Instrument
    case {'Boltzmann' 'Meitner'}
        %Read the header to get Fs
        opts.Fsamp = 1/rawdat.meta.Fsamp;
end

%Define time vector, dt = 1/Fs
out.time = single(0:length(out.extension)-1) / opts.Fsamp;
            
% %Need to declare fcns out here, outside of if statement (but it will only be used if isPhage)
%     function outXpL = XWLC(F, P, S, kT)
%         %Simplification var.s
%         C1 = F*P/kT;
%         C2 = exp(nthroot(900./C1,4));
%         outXpL = 4/3 ...
%             + -4./(3.*sqrt(C1+1)) ...
%             + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
%             + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
%             + F./S;
%     end

%% Convert to contour if requested
if opts.convToContour
    pre = 'Phage';
    out.contour = out.extension ./ XWLC(out.force, opts.dnaPL, opts.dnaSM, opts.dnakT) / opts.dnaBp;
    %Make cell, for consistency
    fnames = fieldnames(out);
    for i = 1:length(fnames)
        out.(fnames{i}) = {out.(fnames{i})};
    end
    %And apply feedback cycle if semipassive
    if opts.splitFCs
        %Get start/end indicies
        [indSta, indEnd] = splitFBCyc(rawdat.TX, opts);
        %Apply segmenting to every vector, save cut segments
        fnames = fieldnames(out);
        for i = 1:length(fnames)
            tempfc = cell(1,length(indEnd));
            tempcut = cell(1, length(indEnd)-1);
            temp1 = out.(fnames{i}){1};
            for j = 1:length(indEnd)
                tempfc{j} = temp1(indSta(j):indEnd(j));
            end
            for j = 1:length(indEnd)-1
                tempcut{j} = temp1(indEnd(j)+1:indSta(j+1)-1);
            end
            out.(fnames{i}) = tempfc;
            out.cut.(fnames{i}) = tempcut;
        end
        
        %Save trap positions of each segment, may be used later for internal mirror calibration
        mirfnames = {'txpos', 'typos'};
        mirinds = {'TX' 'TY'};
        for i = 1:length(mirfnames)
            temppos = zeros(1, length(indEnd));
            tempposcut = zeros(1, length(indEnd)-1);
            for j = 1:length(indEnd)
                temppos(j) = mean(rawdat.(mirinds{i})(indSta(j):indEnd(j)));
            end
            for j = 1:length(indEnd)-1
                tempposcut(j) = mean(rawdat.(mirinds{i})(indEnd(j)+1:indSta(j+1)-1));
            end
            out.(mirfnames{i}) = temppos;
            out.cut.(mirfnames{i}) = tempposcut;
        end
    end
else
    pre = 'ForceExtension';
end

%Add extra data, if exists
if isfield(rawdat, 'meta')
    %Metadata from Timeshared instruments
    out.meta = rawdat.meta;
end
if isfield(rawdat, 'APD1')
    %Fluorescence data from Fleezers
    out.apd1 = rawdat.APD1;
    out.apd2 = rawdat.APD2;
    out.apdT = rawdat.APDT;
end

%Add Green Laser info if it has it
if strcmp(opts.Instrument, 'Meitner')
    if isfield(rawdat, 'GrnOn')
        grn = struct('GrnOn', rawdat.GrnOn, 'GrnCurrPct', rawdat.GrnCurrPct, 'GrnIntMode', rawdat.GrnIntMode, 'GrnPDSum', rawdat.GrnPDSum, 'GrnTime', rawdat.GrnTime);
        out.Grn = grn;
    end
end


%Add extras
out.off = off;
out.cal = cal;
out.opts = opts;
out.nums = inNums;
out.files = file;
out.comment = opts.comment;
[~, f, ~] = fileparts(file{1});
out.name = fullfile(path, sprintf('%s%s.mat',pre, f));
out.timestamp = datestr(now, 'yy/mm/dd HH:MM:SS');

%Get raw filesize (before .mat compression)
wh = whos('out');
by = wh.bytes;
%Print status message
fprintf('Processed %s%s using (offN%02d, calN%02d) in %05.2fs, filesize ~%04.1fMB. Now saving...\n', pre, f, inNums(2), inNums(3), toc(startT), by/2^20);
%Rename out, save data
if opts.convToContour
    stepdata = out; %#ok<NASGU>
    varname = 'stepdata';
else
    ContourData = out; %#ok<NASGU>
    varname = 'ContourData';
end

save(out.name, varname, '-v7.3')
fprintf('\b Done.\n')
end