function out = fitPFFD2(infp, inOpts)
%Fit Protein Folding Force-Distance curve
%Output: Fit in format [DNApl, DNAsm, DNAcl, Xoff, Foff, Ppl, Pcl]
% 2: Lets protein P and CL also change

%Data cropping
opts.cropstr1 = 'fx'; %Crop string 1, for pre-rip
opts.cropstr2 = 'fx2'; %Crop string 2, for post-rip

%Fit options
opts.dnagu = [50 900 2000];

opts.pwlcg = 0.6; %Protein persistence length
% opts.pwlcc = 93 * .35; %Protein contour length, nm
opts.pwlcc = 160; %Contour length, nm

opts.dsamp = 100; %Downsample by this amount

opts.verbose = 1; %Plot

%Select file
if nargin < 1 || isempty(infp)
    [f,p] = uigetfile('.mat');
    infp = fullfile(p,f);
end

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


%Load data
cd = load(infp);
cd = cd.ContourData;

%Load crop for data 1
[p, f, e] = fileparts(infp);
f = [f e];
cT = loadCrop(opts.cropstr1, p, f);
if isempty(cT)
    %No crop here, so set data = empty
    x1 = [];
    f1 = [];
else
    x1 = cd.extension( cd.time > cT(1) & cd.time < cT(2) );
    f1 = cd.force( cd.time > cT(1) & cd.time < cT(2) );
end

%Load crop for data 2
cT = loadCrop(opts.cropstr2, p, f);
if isempty(cT)
    %No crop here, so set data = empty
    x2 = [];
    f2 = [];
else
    x2 = cd.extension( cd.time > cT(1) & cd.time < cT(2) );
    f2 = cd.force( cd.time > cT(1) & cd.time < cT(2) );
end

%If both datas are empty, skip
if isempty(x1) && isempty(x2)
    out = [];
    fprintf('No crops found, crop the pre-rip region under cropstring %s and post-rip under cropstring %s\n', opts.cropstr1, opts.cropstr1)
    return
end

%Downsample
x1 = windowFilter(@mean, double(x1), [], opts.dsamp);
x2 = windowFilter(@mean, double(x2), [], opts.dsamp);
f1 = windowFilter(@mean, double(f1), [], opts.dsamp);
f2 = windowFilter(@mean, double(f2), [], opts.dsamp);

%Fit. Taken straight from p3

%Fit pre-rip to just XWLC, if it exists
xg = [opts.dnagu 0 0];%PL (nm), SM (pN), CL (nm), dx, df, PL(protein) CL(protein) <<should probably fix    
lb = [0   0   0   -00 -0 ]; %set ext and frc offsets to 0, but can enable if needed
ub = [1e4 1e5 inf  00  0 ];
optopts = optimoptions('lsqcurvefit', 'Display', 'off');
if ~isempty(x1)
    fitfcn = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) );
    dft = lsqcurvefit(fitfcn, xg, f1 ,x1, lb, ub, optopts);
else
    dft = xg;
end

%Fit everything together
xg2 = [dft opts.pwlcg opts.pwlcc];%PL (nm), SM (pN), CL (nm), dx, df, PL(protein) CL(protein) <<should probably fix
lb2 = [lb 0.1 0 ];
ub2 = [ub 2 2*opts.pwlcc];
len1 = length(f1);
len2 = length(f2);
fitfcn2 = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) + ((1:(len1+len2)) > len1 ) .* x0(7) .* XWLC(f-x0(5), x0(6),inf)  );
out = lsqcurvefit(fitfcn2, xg2, [f1 f2], [x1 x2], lb2, ub2, optopts);




if opts.verbose
    figure, hold on
    plot([x1 x2], [f1 f2]);
    plot( fitfcn2( out, [f1 f2]), [f1 f2] )
end

