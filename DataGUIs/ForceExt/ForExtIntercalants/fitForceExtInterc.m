function outOpts = fitForceExtInterc( inExt, inFor, inXWLC, inGuess, verbose )
%Fits a force-extension trace to an intercalated model. Requires non-intercalted ForExt param.s
%inGuess = [dx(nm), n, KI]
%Source: Biebricher & Heller, 2014. DOI:10.1038/ncomms8304

%A lot of common code between this and @fitForceExt

%lsqcurvefit requires double
if ~isa(inExt,'double')
    inExt = double(inExt);
end
if ~isa(inFor,'double')
    inFor = double(inFor);
end

loF = 3;
hiF = 40;
%cutoff forces - eventually pass these as an option or something
[inExt, inFor] = trimTrace(inExt, inFor, loF, hiF);

%Default guess
if nargin < 4 || isempty(inGuess)
    inGuess = [.34 2 1];
end

%bounds: [dx(nm), n, KI]
lb = [0.0 01 1e-4];
ub = [1.0 20 1e+4];

%Mute lsqcurvefit
options=optimoptions(@lsqcurvefit);
options.Display = 'off';
%Unmute if verbose
if nargin >= 5 && verbose
    options.Display = 'final';
end

fitfcn = @(opts,force)( ForExt_Interc( force, inXWLC, opts(1), opts(2), opts(3) ) ); 

%While we plot force-extension, we calculate extension-force
[outOpts, ~, res, exflag] = lsqcurvefit(fitfcn, inGuess, inFor, inExt, lb, ub, options);

%Warn for weird exit cases, even if verbose==0
if exflag ~= 3 %Change in residual < tolerance
    ST = dbstack;
    fprintf('%s: lsqcurvefit exited for a nonstandard reason, try verbose\n',ST.name)
end 

if nargin >= 4 && verbose
    figure('Name','Force-Ext fit')
    subplot(3,1,[1 2])
    plot(inExt, inFor, 'Color',[0.7 0.7 0.7])
    hold on
    range = loF:0.1:hiF;
    plot(fitfcn(outOpts,range), range, 'Color',[0.3 0.3 1])
    hold off
    subplot(3,1,3)
    plot(inExt, res)
    fprintf('dx=%0.2fnm, n=%0.2fbp, KI=%0.2g; Elongation=%0.3g%%\n' ,outOpts(1),outOpts(2),outOpts(3), outOpts(1)/outOpts(2)*100)
end