function outOpts = fitForceExt( inExt, inFor, inOpts, verbose )
%Fits a force-extension trace to the XWLC model.
%opts.inGuess = [PersistenceLength(nm), StretchModulus(pN), ContourLength(bp)]

%lsqcurvefit requires double
if ~isa(inExt,'double')
    inExt = double(inExt);
end
if ~isa(inFor,'double')
    inFor = double(inFor);
end

if nargin < 4
    verbose = 0;
end

%Default Params
%Cutoff forces, for fitting
opts.loF = 5;
opts.hiF = 30;
%Guess for fitting: [ PL(nm) SM(pN) CL(bp) Off(nm) ]
opts.inGuess = [50 1200 4000 0];

if nargin >= 3 && ~isempty(inOpts)
    fn = fieldnames(inOpts);
    for i = 1:length(fn)
        opts.(fn{i}) = inOpts.(fn{i});
    end
end

[inExt, inFor] = trimTrace(inExt, inFor, opts.loF, opts.hiF);
%bounds
lb = [1 1 1 -400];
ub = [1e3 1e4 1e4 400];

% fitfcn = @(opts,force)( opts(3) * .34 * ForceExt_XWLC_Wikipedia(force, opts(1),opts(2)) + opts(4) );
fitfcn = @(opts,force)( opts(3) * .34 * XWLC_legacy(force, opts(1),opts(2)) + opts(4) );

%Mute lsqcurvefit
options=optimoptions(@lsqcurvefit);
options.Display = 'off';
%Unmute if verbose
if nargin >= 4 && verbose
    options.Display = 'final';
end


%While we plot force-extension, we calculate extension-force
[outOpts, ~, outResid, exflag] = lsqcurvefit(fitfcn, opts.inGuess, inFor, inExt, lb, ub,options);

%Warn for weird exit cases, even if verbose==0
if exflag ~= 3 %"Standard" exit: change in residual less than fnc tolerance
    ST = dbstack;
    fprintf('%s: lsqcurvefit exited for a nonstandard reason, try verbose\n',ST(1).name)
end 

if nargin >= 4 && verbose
    figure('Name','Force-Ext fit')
    subplot(3,1,[1 2])
    plot(inExt, inFor, 'Color',[0.7 0.7 0.7])
    hold on
    range = loF:0.1:hiF;
    plot(fitfcn(outOpts,range), range, 'Color',[0.3 0.3 1])
    hold off
        msg = sprintf('PerLen=%0.2fnm, StrMod=%0.2fpN, ConLen=%0.2fbp\n' ,outOpts(1),outOpts(2),outOpts(3));
    text(inExt(1),hiF,msg)
    disp(msg)
    subplot(3,1,3)
    plot(inExt, outResid)
end