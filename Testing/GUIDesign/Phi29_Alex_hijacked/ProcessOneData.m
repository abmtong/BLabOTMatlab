function out = ProcessOneData(filepath, inNums, inOpts)
%HIJACKED FOR TESTING

%Processes one data-offset-cal combo, numbers specified in inNums, filepath leads to any data file in the folder
%Specifically, filepath must point to any file that starts MMDDYY

%Options struct defaults. You can run this code fragment (highlight then F9) to get the default struct opts in your workspace
opts.numLanes = 8;
opts.numSamples = 1;
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
%OffsetV2 is a 8x[]x2 matrix, with (:,:,2) being the local std at each point
 rawoff = readDat(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)), 1, 8, 'double', 1);
 rawoff = rawoff(:,1:(end/2));
%Ghe's offset is this
%  rawoff = offset_legacy(sprintf('%s\\%sN%02d.dat', path, mmddyy, inNums(2)));
%  fprintf('Using Ghe's offest...\n');
 
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
            dec = 200;
            thr = 1e-5;
            pad = dec*5; %Pts to pad on each side
        case 2.5e3
            dec = 50;
            thr = 2e-4;
            pad = dec*1;
        case 62.5e3 %same as 50kHz
            dec = 200;
            thr = 1e-5;
            pad = dec*5;
        otherwise
            error('No velocity thresholding options for that Fsamp')
    end
    
    %Use velocity thresholding to find steps in mirror movement
    ind = diff(abs(smooth(velocityThresh(rawdat(5,:), dec))) > thr)';
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
end


%x0 = [rA, rB];
%lsrdata = [AX AY BX BY] nx4
%mirdata = [MX MY] nx2
%caldata = [Fc, D] x [AX AY BX BY], = [cal.AX.fit(1:2); ...]
%vtind = [indsta indend]; nx2
%opts = others, in struct.

lsrdata = [dat.AX(:) dat.AY(:) dat.BX(:) dat.BY(:)];
mirdata = [rawdat(5,:)' rawdat(6,:)'];
caldata = [cal.AX.fit(1:2); cal.AY.fit(1:2); cal.BX.fit(1:2); cal.BY.fit(1:2)];
%check if one segment
if length(indEnd) == 1
    fprintf('Only one segment, skipping');
    return;
end
vtind = [indEnd(1:end-1)' indSta(2:end)'];

opts.wV = 9.1e-10; %Water viscosity at 24C, pNs/nm^2. D2O is 1.25e-10 at 20C
%opts.wV = 1.25e-9; %D2O viscosity at 20C, pNs/nm^2
opts.kT = 4.10; %kB*T at 24C, pN*nm


% options = optimset(@lsqnonlin);
% options.MaxFunEvals = 1e4;
% options.MaxIter = 1e4;
% % options.TolX = 1e-12;
% % options.TolFun = 1e-12;
% options.Display = 'iter';
% options.Algorithm = 'levenberg-marquardt';
Guess = [opts.raA opts.raB];

fitfcn = @(x0) APDoptfcn([x0, x0], lsrdata, mirdata, caldata, vtind, opts);

x = 0.5:0.01:1.5;
z = zeros(1,length(x));
stt = tic;
for i = 1:length(x)
    z(i) = mean( fitfcn( x( [i,i] ) .* Guess ).^2 );
end
ent = toc(stt);
[~, mzi] = min(z);
figure('Name', sprintf('N%02d diag', inNums(1)))
plot(x,z)

fprintf('Rel. bead radius for N%02d is %0.2f um; took %0.1fs\n', inNums(1), x(mzi), ent);

%%Results
%{
From 2D mesh, result seems to rely only on (dA + dB) (i.e. result is x-y symmetric), so optimize only along diagonal

Distribution i smostly good (most within +- 10%, major outliers > probably something wrong (flag user if so) )
e.g. 
a = [58    97    92   100    95    81    97   124   103]
     ^ probably double tether                 ^ 

%}


% %Bead makers report 0.05-0.1 CV, with some extra large outliers, so aim for -30% to +50% of size
% ub = 1.5 * Guess;
% lb = 0.7 * Guess;
% stt = tic;
% bsz = lsqnonlin(fitfcn, Guess, [], [], options);
% ent = toc(stt);

% fprintf('Real bead radius is [%0.2f, %0.2f] nm; took %0.1fs\n', bsz, ent);

%Then send this through the regular POD with the optimized bead size

end