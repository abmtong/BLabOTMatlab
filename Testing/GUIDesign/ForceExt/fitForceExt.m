function [outOpts, fitfcn] = fitForceExt( inExt, inFor, inOpts, verbose )
%Fits a force-extension trace to the XWLC model.
%x0 = [PL(nm), SM(pN), CL(bp) OffX(nm) OffF(pN)]

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
opts.loF = 1;
opts.hiF = inf;
%Guess for fitting: [ PL(nm) SM(pN) CL(bp) Off(nm) Off(F) ]
opts.x0 = [50 1200 4000 0 0];
%Fitting bounds: Override to allow for e.g. force/ext offsets to be set
opts.lb = [0   0   0   -00 -0];
opts.ub = [1e3 1e4 inf  00  0];

if nargin >= 3 && ~isempty(inOpts)
    fn = fieldnames(inOpts);
    for i = 1:length(fn)
        opts.(fn{i}) = inOpts.(fn{i});
    end
end

[inExt, inFor] = trimTrace(inExt, inFor, opts.loF, opts.hiF);

%Fitfcn: ext(F)
fitfcn = @(opts,force)( opts(3) * .34 * XWLC(force-opts(5), opts(1),opts(2), [], 2) + opts(4) );

%Fit ext-force curve
[outOpts, ~, outResid, exflag] = lsqcurvefit(fitfcn, opts.x0, inFor, inExt, opts.lb, opts.ub, optimoptions(@lsqcurvefit, 'Display', 'off'));

%Warn for weird exit cases, even if verbose==0
if exflag ~= 3 %"3=Standard" exit: change in residual less than fnc tolerance
    ST = dbstack;
    fprintf('%s: lsqcurvefit exited for a nonstandard reason, try verbose\n',ST(1).name)
end 

if nargin >= 4 && verbose
    figure('Name','Force-Ext fit')
    subplot(3,1,[1 2])
    plot(inExt, inFor, 'o', 'Color',[0.7 0.7 0.7])
    hold on
    range = opts.loF:0.1:opts.hiF;
    plot(fitfcn(outOpts,range), range, 'Color',[0.3 0.3 1])
    hold off
        msg = sprintf('PerLen=%0.2fnm, StrMod=%0.2fpN, ConLen=%0.2fbp, OffsetX=%0.2fnm, OffsetF = %0.2fpN\n' ,outOpts);
    text(inExt(1),opts.hiF,msg)
    disp(msg)
    subplot(3,1,3)
    plot(inExt, outResid, 'o')
end