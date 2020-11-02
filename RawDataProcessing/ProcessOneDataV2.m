function out = ProcessOneDataV2(path, inNums, inOpts)
%Processes one data-offset-cal combo, numbers specified in inNums, path to the root folder, with options

if nargin < 3
    inOpts = DataOptsPopup;
end

%Compose filenames
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
        case 'HiRes'
            spfn = '%sN%02d.dat';
        case 'Boltzmann'
            spfn = '%s_%03d.dat';
        case 'Meitner'
            spfn = '%s_%03d.dat';
        otherwise
            error('Instrument %s not recognized', inOpts.Instrument)
    end
    file = arrayfun(@(x) sprintf(spfn, inOpts.mmddyy, x), inNums, 'Un', 0);
end

startT = tic;

%No default opts, so just rename for now
opts = inOpts;

%Calibrate
%Assemble Cal options
calopts = opts.cal;
calopts.raA = opts.raA;
calopts.raB = opts.raB;
calopts.Instrument = opts.Instrument;
%Get Fs
switch calopts.Instrument
    case 'HiRes'
        calopts.Fsamp = opts.Fsamp;
    case {'Boltzmann' 'Meitner'}
        %Read the header to get Fs
        calhdr = timesharereadhdr(fullfile(path, file{3}));
        calopts.Fsamp = 1/calhdr.Fsamp;
end
cal = ACalibrateV2(fullfile(path, file{3}), calopts);
drawnow %Can inspect calibration while program continues

%Offset data is taken by holding the beads at a varying distance apart, to see laser-bead interactions (without tether)
%rawoff V3 is a 8x[] matrix, with each row being a detector in order [AY BY AX BX MX MY SA SB]
% rawoff = readDat(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)));
%OffsetV2 is a 8x[]x2 matrix, with (:,:,2) being the local std at each point. We read it as 8x[], so the second half of dimension 2 is std data
switch calopts.Instrument
    case 'HiRes'
        %HiRes offset is pre-processed
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
        
        %Ghe's offset is this
        %  rawoff = offset_legacy(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)));
        %  fprintf('Using Ghe''s offset.\n');
    otherwise
        %These should just be a single f-d curve. Average down and use
        rawoff = loadfile_wrapper(fullfile(path, file{2}), opts);
        %Average down to 100pts
        npts = 100;
        navg = floor(length(rawoff.AS) / npts);
        off = [];
        fnames = {'AX' 'AY' 'AS' 'BX' 'BY' 'BS' 'TX' 'TY'};
        for i = 1:length(fnames)
            off.(fnames{i}) = windowFilter(@mean, rawoff.(fnames{i}), [], navg);
        end
end

%Load data file
rawdat = loadfile_wrapper(fullfile(path, file{1}), opts);

%Create some name-index sets to do in loop
detNames = {'AX' 'BX' 'AY' 'BY'};
detSums =  {'AS' 'BS' 'AS' 'BS'};
%Normalize, apply offset to each detector
for i = 1:4
    %Extract cell for convenience
    detNam = detNames{i};
    detSum = detSums{i};
    %Normalize offset and subtract it from the normalized data
    rawdat.(detNam) = rawdat.(detNam) ./ rawdat.(detSum) - interp1( off.TX, off.(detNam)./off.(detSum), rawdat.TX, 'linear', 'extrap');
    %Calculate force = AX * a * k
    out.(['force' detNam]) = rawdat.(detNam) * cal.(detNam).a * cal.(detNam).k;
end

%Calculate extension  = hypot( TrapX + BeadsX , TrapY + BeadsY) - Bead Radii
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
%Calculate total force = hypot( forX, forY ) using differential force (average of forces)
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
            
%Need to declare fcns out here, outside of if statement (but it will only be used if isPhage)
    function outXpL = XWLC(F, P, S, kT)
        %Simplification var.s
        C1 = F*P/kT;
        C2 = exp(nthroot(900./C1,4));
        outXpL = 4/3 ...
            + -4./(3.*sqrt(C1+1)) ...
            + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
            + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
            + F./S;
    end

%     function outVT = velocityThresh(inY, dec)
%         outVT = zeros(1, floor(length(inY)/dec));
%         X = [(1:dec)' ones(dec,1)];
%         for ii = 1:length(outVT)
%             pf = X\inY(1+ (ii-1)*dec : ii*dec)';
%             outVT(ii) = pf(1);
%         end
%     end

%Convert to contour if requested
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

%Add extras
out.off = off;
out.cal = cal;
out.opts = opts;
out.nums = inNums;
out.files = file;
out.comment = opts.comment;
[~, f, ~] = fileparts(file{1});
out.name = sprintf('%s%s%s.mat', path, pre, f);
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