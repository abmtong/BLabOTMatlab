function out = ProcessOneData(filepath, inNums, inOpts)
%Processes one data-offset-cal combo, numbers specified in inNums, filepath leads to any data file in the folder
%Specifically, filepath must point to any file that starts MMDDYY

%Options struct defaults. You run this code fragment (highlight then F9) to get the default struct opts in your workspace
opts.numLanes = 8;
opts.numSamples = 20;
opts.numEndian = 1;
opts.raA = 500;
opts.raB = 500;
opts.offTrapX = 1.4;
opts.offTrapY = 0.9;
opts.convTrapX = 762;
opts.convTrapY = 578;
opts.Fsamp = 50e3;
opts.gheNames = 1;
opts.comment = '';
%Calibration options
opts.cal.verbose=1;
opts.cal.Fs = 62.5e3;
%Bead radii will be assigned here, too, later
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
%cal is a struct with fields cal.(detector).(a/k), e.g. cal.AX.k for detector AX's spring constant
cal = ACalibrate(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(3)), opts.cal);
drawnow %Can inspect calibration while program continues

%rawoff V3 is a 8x[] matrix, with each row being a detector in order [AY BY AX BX MX MY SA SB]
% rawoff = readDat(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)));
%For OffsetV2, it's this instead; or use @convertOffV2toOffV3
 rawoff = readDat(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)), 1, 8, 'double', 1);
 rawoff = rawoff(:,1:(end/2));

%rawdat is a 8x[] matrix, with each row being a detector. Samples, Lanes, and Endianness are options.
rawdat = readDat(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(1)) ,opts.numSamples,opts.numLanes, 'single', opts.numEndian);
len = size(rawdat, 2);

%Create some name-index sets to make loops easier
detectorNames = {'AX' 'BX' 'AY' 'BY'};
dataInds      = { 3 4 1 2 };
sumInds       = { 7 8 7 8 };
%These don't change
mirNam   = 'MX';
mirInd   = 5;
%Normalize, apply offset to each detector
for i = 1:4
    %Extract cell for convenience
    datNam = detectorNames{i};
    datInd = dataInds{i};
    sumInd = sumInds{i};
    %Extract, normalize offset values
    off.(datNam) = rawoff(datInd,:)./rawoff(sumInd,:);
    off.(mirNam) = rawoff(mirInd,:); %Redundant step, oh well
    %Normalize data
    dat.(datNam) = rawdat(datInd,:)./rawdat(sumInd,:);
    %Subtract offset from data (interpolate)
    dat.(datNam) = dat.(datNam) - interp1( off.(mirNam), off.(datNam), rawdat(mirInd,:), 'linear', 'extrap');
    %Calculate force = AX * a * k
    out.(['force' datNam]) = dat.(datNam) * cal.(datNam).a * cal.(datNam).k;
end

%Calculate extension  = hypot( TrapX + BeadsX , TrapY + BeadsY) - Bead Radii
%                      (Mirror(V)  -offsetMir(V)) *convMir(nm/V)  + A(NV)*alphaA(nm/NV) - B(NV)*alphaB(nm/NV)
out.extension = hypot( (rawdat(5,:)-opts.offTrapX)*opts.convTrapX + cal.AX.a*dat.AX - cal.BX.a*dat.BX, ...
                       (rawdat(6,:)-opts.offTrapY)*opts.convTrapY + cal.AY.a*dat.AY - cal.BY.a*dat.BY )...
                       - opts.raA - opts.raB;
%Calculate total force = hypot( forX, forY ) using differential force (average of forces)
out.force = hypot((out.forceBX - out.forceAX)/2, ...
                  (out.forceBY - out.forceAY)/2);

%Define time vector, dt = 1/Fs
out.time = single(1:len) / opts.Fsamp;
            
%Need to declare fcn out here, outside of if statement (but it will only be used if isPhage)
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

    function outVT = velocityThresh(inY, dec)
        outVT = zeros(1, floor(length(inY)/dec));
        X = [(1:dec)' ones(dec,1)];
        for ii = 1:length(outVT)
            pf = X\inY(1+ (ii-1)*dec : ii*dec)';
            outVT(ii) = pf(1);
        end
    end

if ~opts.isPhage
    if opts.gheNames
        pre = 'ForceExtension';
    else
        pre = 'ForExt';
    end
else %Phage-only processing
    pre = 'Phage';
    %Convert extension to contour
    out.contour = out.extension ./ XWLC(out.force, opts.dnaPL, opts.dnaSM, opts.dnakT) / opts.dnaBp;
    %Analyze MX to find segments: use 2.5kHz as a reference point for filtering (empirical, downsample else filtering takes a while)
    refFs = 2500;
    dec = 20*max(round(opts.Fsamp/refFs),1);
    
    %Old
    %dec = max(round(opts.Fsamp/refFs),1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% old thresh method
    thr = 2e-5;  
    %Filter the data, find where the absolute difference is over a certain threshold, then find the bdys of the changes
    ind = diff(abs(diff(smooth(rawdat(5,dec:dec:end), 250)')) > thr);
    
    
    indSta = dec*find(ind<0); %=-1, end of mirror movement (start of segment)
    indEnd = dec*find(ind>0); %=+1, start of mirror movement (end of segment)
    %Might need to shift or add, depending on whether ind starts/ends moving or stationary
    if length(indSta) > length(indEnd)
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
    
    %Apply segmenting to every vector
    fnames = fieldnames(out);
    for i = 1:length(fnames)
        temp2 = cell(1,length(indEnd));
        for j = 1:length(indEnd)
            temp1 = out.(fnames{i});
            temp2{j} = temp1(indSta(j):indEnd(j));
        end
        out.(fnames{i}) = temp2;
    end
end

%Add extras
out.off = off;
out.cal = cal;
out.opts = opts;
out.files = inNums;
out.comment = opts.comment;
out.name = sprintf('%s%s%sN%02d.mat', path, pre, mmddyy, inNums(1));
out.timeestamp = datestr(now, 'yy/mm/dd HH:MM:SS');

%Get raw filesize (before .mat compression)
wh = whos('out');
by = wh.bytes;
%Print status message
fprintf('Processed %s%sN%02d using (offN%d, calN%d) in %0.2fs, datasize %0.1fMB before compression. Now saving.\n', pre, mmddyy, inNums, toc(startT), by/2^20);
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
        varname = 'ContourData';
    end
end
save(out.name, varname)
end