function out = ProcessOneData(filepath, inNums, inOpts)
%Processes one data-offset-cal combo, numbers specified in inNums, filepath leads to any data file in the folder
%Specifically, filepath must point to any file that starts MMDDYY

%Options struct defaults. You can run this code fragment (highlight then F9) to get the default struct opts in your workspace
opts.numLanes = 8;
opts.numSamples = 1;
opts.numEndian = 1;
opts.raA = 500;
opts.raB = 500;
opts.offTrapX = 1.4;
opts.offTrapY = 1.05;
opts.convTrapX = 762;
opts.convTrapY = 578;
opts.Fsamp = 50e3;
opts.gheNames = 1;
opts.comment = '';
%Calibration options
opts.cal.verbose=1;
opts.cal.Fs = 62.5e3;
opts.cal.d2o = 0;
%Phage options
opts.isPhage = 0;
opts.dnaPL = 50;
opts.dnaSM = 700;
opts.dnakT = 4.14;
opts.dnaBp = .34;

if exist('inOpts','var') && isstruct(inOpts)
    opts = handleOpts(opts, inOpts);
end
opts.cal.raA = opts.raA;
opts.cal.raB = opts.raB;

if ~exist('filepath','var') || isempty(filepath)
    [file, path] = uigetfile('C:\Data\*.dat','Select a data file in the folder');
    if ~path %No file selected
        return
    end
    filepath=[path file]; %#ok<NASGU>
else
    [p, f, e] = fileparts(filepath);
    path = [p filesep];
    file = [f e];
end

startT = tic;

mmddyy = file(1:6);

%Load cal, offset, data
%Calibration raw data is from holding the bead in the trap (no tether) for 10s
%cal is a struct with fields cal.(detector).(a/k), e.g. cal.AX.k for detector AX's spring constant
cal = ACalibrate(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(3)), opts.cal);
drawnow %Can inspect calibration while program continues

%Offset data is taken by holding the beads at a varying distance apart, to see laser-bead interactions (without tether)
%rawoff V3 is a 8x[] matrix, with each row being a detector in order [AY BY AX BX MX MY SA SB]
% rawoff = readDat(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)));
%OffsetV2 is a 8x[]x2 matrix, with (:,:,2) being the local std at each point. We read it as 8x[], so the second half of dimension 2 is std data
 rawoff = readDat(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)), 1, 8, 'double', 1);
 rawoff = rawoff(:,1:(end/2)); %drop the std data
%Ghe's offset is this
%  rawoff = offset_legacy(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)));
%  fprintf('Using Ghe''s offset.\n');
 
%rawdat is a 8x[] matrix, with each row being a detector. Samples, Lanes, and Endianness are options.
rawdat = readDat(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(1)) ,opts.numSamples,opts.numLanes, 'single', opts.numEndian);
len = size(rawdat, 2);

%Create some name-index sets to do in loop
detectorNames = {'AX' 'BX' 'AY' 'BY'};
dataInds      = { 3 4 1 2 };
sumInds       = { 7 8 7 8 };
%These don't change
mirNam   = 'MX';
mirInd   = 5;
off.(mirNam) = rawoff(mirInd,:);
%Normalize, apply offset to each detector
for i = 1:4
    %Extract cell for convenience
    datNam = detectorNames{i};
    datInd = dataInds{i};
    sumInd = sumInds{i};
    %Extract, normalize offset
    off.(datNam) = rawoff(datInd,:)./rawoff(sumInd,:);
    %Extract, normalize data
    dat.(datNam) = rawdat(datInd,:)./rawdat(sumInd,:);
    %Apply offset via interpolation
    dat.(datNam) = dat.(datNam) - interp1( off.(mirNam), off.(datNam), rawdat(mirInd,:), 'linear', 'extrap');
    %Calculate force = AX * a * k
    out.(['force' datNam]) = dat.(datNam) * cal.(datNam).a * cal.(datNam).k;
end

%Calculate extension  = hypot( TrapX + BeadsX , TrapY + BeadsY) - Bead Radii
%                      (Mirror(V)  -offsetMir(V)) *convMir(nm/V)  + A(NV)*alphaA(nm/NV) - B(NV)*alphaB(nm/NV)
out.extension = hypot( (rawdat(5,:)-opts.offTrapX)*opts.convTrapX + cal.AX.a*dat.AX - cal.BX.a*dat.BX, ...
                       (rawdat(6,:)-opts.offTrapY)*opts.convTrapY + cal.AY.a*dat.AY - cal.BY.a*dat.BY )...
                       - opts.raA - opts.raB;

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

%Define time vector, dt = 1/Fs
out.time = single(1:len) / opts.Fsamp;
            
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

if ~opts.isPhage
    if opts.gheNames
        pre = 'ForceExtension';
    else
        pre = 'ForExt';
    end
elseif opts.isPhage ==2
    pre = 'Phage';
    %Convert extension to contour, but that's it
    out.contour = out.extension ./ XWLC(out.force, opts.dnaPL, opts.dnaSM, opts.dnakT) / opts.dnaBp;
    %Make cell, for consistency
    fnames = fieldnames(out);
    for i = 1:length(fnames)
        out.(fnames{i}) = {out.(fnames{i})};
    end
else %Phage-only processing
    pre = 'Phage';
    %Convert extension to contour
    out.contour = out.extension ./ XWLC(out.force, opts.dnaPL, opts.dnaSM, opts.dnakT) / opts.dnaBp;
    %Analyze MX to find segments
    switch opts.Fsamp
        case 50e3
            fil = 100;
            dec = 25;
%             thr = 1e-5;
            pad = fil*2; %Pts to pad on each side
        case 2.5e3
            fil = 12;
            dec = 1;
            thr = 1e-4;
            pad = fil*2;
        case 62.5e3 %same as 50kHz
            fil = 100;
            dec = 25;
            thr = 1e-5;
            pad = fil*2;
        otherwise
            warning('No velocity thresholding options for that Fsamp, guessing')
            %decimate to 2.5kHz, filter/decimate arbitrarily, thr = 20 * MAD
            dec = max(round(opts.Fsamp / 2500), 1);
            fil = round(12*sqrt(dec));
            mxfil = windowFilter(@mean, rawdat(5,:), fil, dec);
            thr = 5 * 1.4 * median(abs(mxfil-mean(mxfil)));
            pad = fil*2;
    end
    
    %Use velocity thresholding to find steps in mirror movement
    dmx = diff(windowFilter(@mean, rawdat(5,:), fil, dec));
    %Threshold = 5 * 1.4 * MAD (= 5*SD), assume mean ~ 0
%     thr = 5 * 1.4 * median(abs(dmx - mean(dmx))); %should be ~equal to the thr in the switch above
    %is this necessary to recalc or just use one value?
    ind = diff(abs(dmx) > thr);
%     ind = diff(abs(smooth(velocityThresh(rawdat(5,:), dec))) > thr)';
    indSta = dec*find(ind<0)+pad; %=-1, end of mirror movement (start of segment)
    indEnd = dec*find(ind>0)-pad; %=+1, start of mirror movement (end of segment)
    %Might need to shift or add, depending on whether ind starts/ends moving or stationary
    if isempty(indSta) && isempty(indEnd) %One segment (e.g. if really slow)
        indSta = dec*1;
        indEnd = dec*length(ind);
    elseif length(indSta) > length(indEnd)
        indEnd = [indEnd len];
    elseif length(indEnd) > length(indSta)
        indSta = [1 indSta];
    elseif indSta(1) > indEnd(1) %lengths are equal
        indSta = [1 indSta];
        indEnd = [indEnd len];
    end
    %Remove short segments, say minimum length of 0.1s
    seglens = indEnd-indSta;
    keepind = seglens>opts.Fsamp*0.1;
    indSta = indSta(keepind);
    indEnd = indEnd(keepind);

    %Apply segmenting to every vector, save cut segments
    fnames = fieldnames(out);
    for i = 1:length(fnames)
        tempfc = cell(1,length(indEnd));
        tempcut = cell(1, length(indEnd)-1);
        temp1 = out.(fnames{i});
        for j = 1:length(indEnd)
            tempfc{j} = temp1(indSta(j):indEnd(j));
        end
        for j = 1:length(indEnd)-1
            tempcut{j} = temp1(indEnd(j)+1:indSta(j+1)-1);
        end
        out.(fnames{i}) = tempfc;
        out.cut.(fnames{i}) = tempcut;
    end
    
    %Save MX,MY positions of each segment, for internal contour control calibration later
    mirfnames = {'mxpos', 'mypos'};
    mirinds = [5 6];
    mirfnamesoffset = {'offTrapX', 'offTrapY'};
    mirfnamesconv = {'convTrapX', 'convTrapY'};
    
    for i = 1:length(mirfnames)
        temppos = zeros(1, length(indEnd));
        tempposcut = zeros(1, length(indEnd)-1);
        for j = 1:length(indEnd)
            temppos(j) = mean(rawdat(mirinds(i),(indSta(j):indEnd(j))));
        end
        for j = 1:length(indEnd)-1
            tempposcut(j) = mean(rawdat(mirinds(i),(indEnd(j)+1:indSta(j+1)-1)));
        end
        %Apply mirror offset/calibration
        temppos = (temppos - opts.(mirfnamesoffset{i}))*opts.(mirfnamesconv{i});
        tempposcut = (tempposcut - opts.(mirfnamesoffset{i}))*opts.(mirfnamesconv{i});
        out.(mirfnames{i}) = temppos;
        out.cut.(mirfnames{i}) = tempposcut;
    end
end

%Add extras
out.off = off;
out.cal = cal;
out.opts = opts;
out.files = inNums;
out.comment = opts.comment;
out.name = sprintf('%s%s%sN%02d.mat', path, pre, mmddyy, inNums(1));
out.timestamp = datestr(now, 'yy/mm/dd HH:MM:SS');

%Get raw filesize (before .mat compression)
wh = whos('out');
by = wh.bytes;
%Print status message
fprintf('Processed %s%sN%02d using (offN%02d, calN%02d) in %05.2fs, filesize ~%04.1fMB. Now saving...\n', pre, mmddyy, inNums, toc(startT), by/2^20);
%Rename out, save data
if opts.gheNames
    if opts.isPhage
        stepdata = out; %#ok<NASGU>
        varname = 'stepdata';
    else
        ContourData = out; %#ok<NASGU>
        varname = 'ContourData';
    end
else
    if opts.isPhage
        dataPhage = out; %#ok<NASGU>
        varname = 'dataPhage';
    else
        dataForExt = out; %#ok<NASGU>
        varname = 'dataForExt';
    end
end
save(out.name, varname)
fprintf('\b Done.\n')
end