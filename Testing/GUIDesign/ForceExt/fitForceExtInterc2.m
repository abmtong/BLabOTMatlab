function outOpts = fitForceExtInterc2( inExt, inFor, inGuess, verbose )
%Fits a force-extension trace to an intercalated model. Requires a non-intercalted ForExt param.s
%inGuess = [pl sm cl dx(nm), n, KI]
%Source: Biebricher & Heller, 2014. DOI:10.1038/ncomms8304

%2: Fit all 6 params. Works okay, but too many degrees of freedom (>multiple solutions)

%lsqcurvefit requires double
if ~isa(inExt,'double')
    inExt = double(inExt);
end
if ~isa(inFor,'double')
    inFor = double(inFor);
end

%cutoff forces, eventually pass as param.
cut1 = 40;
cut2 = 2;
ind1 = find(inFor > cut1, 1, 'first');
ind2 = find(inFor < cut2, 1, 'last');
if isempty(ind1)
    ind1 = length(inFor);
end
if isempty(ind2)
    ind2 = 1;
end
inExt = inExt(ind2:ind1);
inFor = inFor(ind2:ind1);


%Default guess
if nargin < 3 || isempty(inGuess)
    inGuess = [50 600 5000 .34 2.5 1];
end

%bounds
lb = [1e1 1e1 1e2 0 1e-1 1e-4];
ub = [1e4 2e3 1e5 1 1e+1 1e+4];

fitfcn = @(opts,force)( ForExt_Interc( force, opts(1:3), opts(4), opts(5), opts(6) ) ); 

%Mute lsqcurvefit
options=optimset('Display','off');
%options.MaxFunEvals = 10000;
%Unmute if verbose
if verbose
    options.Display = [];
end


%While we plot force-extension, we calculate extension-force
outOpts = lsqcurvefit(fitfcn, inGuess, inFor, inExt, lb, ub, options);


if nargin >= 4 && verbose
    figure('Name','Force-Ext-Interc fit')
    subplot(3,1,[1 2])
    plot(inExt, inFor, 'Color',[0.7 0.7 0.7])
    hold on
    range = cut2:0.1:cut1;
    plot(fitfcn(outOpts,range), range, 'Color',[0.3 0.3 1])
    hold off
    subplot(3,1,3)
    plot(inExt - fitfcn(outOpts,inFor))
    fprintf('PL=%0.2fnm, SM=%0.2fpN, CL=%0.2fbp, dx=%0.2fnm, n=%0.2fbp, KI=%0.2e\n' ,outOpts(1),outOpts(2),outOpts(3),outOpts(4),outOpts(5),outOpts(6))
end