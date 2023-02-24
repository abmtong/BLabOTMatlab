function out = RP_passive(infp, inOpts)
%Works on a passive mode exp't
% File must be cropped to include one single passive mode section (could automate this, but ... eh)

%Algo: Find the two wells (U and P, by @findpeaks or smth), use linspace(well1, well2, n_states) to generate mu
%     Downsample data to remove bead autocorrelation / detector delay (to ~Fc/2 Hz or , e.g. 15kHz)

opts.cropstr = '';
opts.fil = 10; %Downsample by this much, to make chain Markovian + computation time
opts.binsz = .1; %Bin size, nm, for histogram to find U/F size
opts.nint = 3; %Number of intermediats
opts.trnsprb = 1e-4; %Guess for transition probability, pts, i.e. the off-diagonal elements of the HMM transition mtx
opts.estsd = 1; %Estimated SD of noise; see usage

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    infp = cellfun(@(x)fullfile(p, x), f, 'Un', 0);
end

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


if iscell(infp)
    out = cellfun(@(x)RP_passive(x, opts), infp, 'Un', 0);
    %Add file field
    for i = 1:length(out)
        [~, f, ~] = fileparts(infp{i});
        [out{i}.file] = deal(f);
    end
    %And combine
    out = [out{:}];
    return
end

%Get data
cd = load(infp);
cd = cd.ContourData;
[p, f, e] = fileparts(infp);
ct = loadCrop(opts.cropstr, p, [f e]);

%Crop
ext = double(cd.extension);
frc = double(cd.force);
cti = [find(cd.time > ct(1), 1, 'first') find(cd.time < ct(2), 1, 'last')];
ext = ext(cti(1):cti(2));
frc = frc(cti(1):cti(2));
len = length(ext);

%Downsample
extF = windowFilter(@mean, ext, [], opts.fil);
% frcF = windowFilter(@mean, frc, [], opts.fil);


%Bin to a histogram
[hy, hx] = nhistc(extF, opts.binsz);

% %Use findpeaks to detect the U and F wells
% *Assumes the histogram is gaussian enough (enough to saturate the bins so each well has one major peak (not spiky) ; else gaussian filter to smooth)
[fpy, fpx] = findpeaks(hy, hx);
[fpy, si] = sort(fpy, 'descend'); %Sort heights
fpx = fpx(si);
%Find the highest peak; and then the next highest peak at least 2*sd away
ind2 = find( abs(fpx(2:end) - fpx(1)) > 2*opts.estsd, 1, 'first') +1;
xuf = fpx([1 ind2]);
[xuf, si2] = sort(xuf);
fpy = fpy([1 ind2]);
fpy = fpy(si2);
% xuf = prctile(extF, [25 75]); %Eh, let's just estimate the two with first/third quartile
%Might need a better guess...


%Maybe better to fit two guassians. Also gives us noise. Let's use the above as a starting point for fitting
fitfcn = @(x0, x) normpdf(x, x0(1), x0(2)) * x0(3) + normpdf(x, x0(4), x0(5)) * x0(6);
% x0 = [ gaussian 1 [mean sd amp] , gaussian 2 [mean sd amp] ]
xg = [xuf(1) opts.estsd fpy(1)*sqrt(2*pi*opts.estsd) xuf(2) opts.estsd fpy(2)*sqrt(2*pi*opts.estsd)];
lb = [hx(1) 0 0 hx(1) 0 0];
ub = [hx(end) inf inf hx(end) inf inf];
%Fit to a sum of two gaussians
ft = lsqcurvefit(fitfcn, xg, hx, hy, lb, ub, optimoptions('lsqcurvefit', 'Display', 'off'));

%Debug: check fitting
% figure, plot(hx,hy), hold on, plot(hx, fitfcn(ft, hx))

%Extract sig/mu from this fit
xuf2 = ft([1 4]);
sig = ft([2 5]);

[xuf2, si2] = sort(xuf2);
sig = sig(si2);

%Let's assume there's n intermediates, evenly spaced (as a first assumption)
ns = 2+opts.nint; %Number of states: U, F, and intermediates
mu = linspace(xuf2(1), xuf2(2), ns);
%Noise. Let's hope we can ignore force dependence... (else need to recode HMM)
% sig = linspace(sig(1), sig(2), ns);
sig = mean(sig);

%Assemble HMM model
mdlg.mu = mu;
mdlg.sig = sig;
ag = ones(ns)*opts.trnsprb*opts.fil + diag(ones(1,ns));
mdlg.a = bsxfun(@rdivide, ag, sum(ag,2));
mdlg.verbose = 0;

%And let's fit to a HMM
mdl = stateHMMV2(extF, mdlg);
vitfit = mdl.fit;

%Let's get TPs
ftp = [];
utp = [];
indch = find( diff(vitfit) & (vitfit(1:end-1) == 1 | vitfit(1:end-1) == ns ) ); %Find indicies where a transition happens == vitfit changes
for i = 1:length(indch)
    %Get this index
    curind = indch(i);
    %Find next time in F state
    tmp1 = find(vitfit(curind+1:end) == 1, 1, 'first');
    %And find next time in U state
    tmp2 = find(vitfit(curind+1:end) == ns, 1, 'first');
    if isempty(tmp1)
        tmp1 = length(vitfit);
    end
    if isempty(tmp2)
        tmp2 = length(vitfit);
    end
    switch vitfit(curind)
        case 1 %Transit from F state
            %If next U is sooner, save this as a F>U TP
            if tmp2 < tmp1
                utp = [utp {curind + [0 tmp2]}]; %#ok<AGROW>
            end
        case ns %Tranist from U state
            %If next F is sooner, save this as a U>F TP
            if tmp1 < tmp2
                ftp = [ftp {curind + [0 tmp1]}]; %#ok<AGROW>
            end
    end
end
%Extract the raw data (pad with 2*opts.fil points)
ftpx = cell(1,length(ftp));
ftpxf = cell(1,length(ftp));
extf2 = windowFilter(@mean, ext, ceil(opts.fil/2), 1);
for i = 1:length(ftp)
    ind1 = max(1  , opts.fil * (ftp{i}(1) -2));
    ind2 = min(len, opts.fil * (ftp{i}(2) +2));
    ftpx{i} = ext(ind1:ind2);
    ftpxf{i} = extf2(ind1:ind2);
end
utpx = cell(1,length(utp));
utpxf = cell(1,length(utp));
for i = 1:length(utp)
    ind1 = max(1  , opts.fil * (utp{i}(1) -2));
    ind2 = min(len, opts.fil * (utp{i}(2) +2));
    utpx{i} = ext(ind1:ind2);
    utpxf{i} = extf2(ind1:ind2);
end

%Assemble output
out.ext = ext;
out.extf = extF;
out.utp = ftpx;
out.utpf = ftpxf;
out.ftp = ftpx;
out.ftpf = ftpxf;
out.hmmfit = mdl;


%Inspect the transition mtx...
% a = mdl.a;
% mu = mdl.mu;

% out= mdl;
%Things to notice: 













