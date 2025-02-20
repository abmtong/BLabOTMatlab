function out = RPp3_ret(inst, inOpts)
%p3: With the segments identified, let's fit to WLC
% ret: Fit retract curve to WLC

opts.retfil = 200; %Filter with this width, downsample
% opts.verbose = 1; %Plot fit
opts.frng = [0 25];

%XWLC info/guesses
opts.dwlcg = [50 900]; %DNA XWLC guess, [PL(nm) SM(pN)]
opts.dwlcc = 2000*.34; %DNA contour length guess, 0.34nm/bp
% Guess taken from what I've observed for DNA in HiRes
opts.pwlcg = 0.4; %Protein XWLC PL guess
opts.pwlcc = 0.35*106; %Protein contour length, will be used as a set value. ROSS is 106aa, but expts introduce loops that increase it
% Guess taken from https://www.pnas.org/doi/10.1073/pnas.1300596110

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Fit pre-rip to DNA XWLC (detected in p2) and post-rip to XWLC DNA+protein (set protein CL constant, as PL and CL are roughly inversely proportional at low PL)
len = length(inst);
optopts = optimoptions('lsqcurvefit', 'Display', 'off');
for i = 1:len
    %Get this pull
    tmp = inst(i);
    %Filter 
    x = double( windowFilter(@mean, tmp.ext( tmp.retind:end ), [], opts.retfil*2+1) );
    f = double( windowFilter(@mean, tmp.frc( tmp.retind:end ), [], opts.retfil*2+1) );
    ri = floor(tmp.refind / (opts.retfil*2+1));
    
    %Fit pre-rip to just XWLC
    xg = [opts.dwlcg opts.dwlcc 0 0];%PL (nm), SM (pN), CL (nm), dx, df, PL(protein) CL(protein) <<should probably fix
    lb = [0   0   0   -00 -0 ]; %set ext and frc offsets to 0, but can enable if needed
    ub = [1e3 1e4 inf  00  0 ];
    fitfcn = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) );
    dft = lsqcurvefit(fitfcn, xg, f(1:ri),x(1:ri), lb, ub, optopts);
    
    xg2 = [dft opts.pwlcg opts.pwlcc];%PL (nm), SM (pN), CL (nm), dx, df, PL(protein) CL(protein) <<should probably fix
    lb2 = [lb 0 opts.pwlcc ]; %set ext and frc offsets to 0, but can enable if needed
    ub2 = [ub 2 opts.pwlcc];
    fitfcn2 = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) + ((1:length(f)) < ri ) .* x0(7) .* XWLC(f-x0(5), x0(6),inf)  );
    pft = lsqcurvefit(fitfcn2, xg2, f, x, lb2, ub2, optopts);
    
    %Subtract away DNA portion
    extpro =  tmp.ext - XWLC( tmp.frc, pft(1), pft(2) ) * pft(3);
    
    %Convert to contour. Use filtered force
    ff = windowFilter(@median, tmp.frc, opts.retfil, 1);
    conpro = extpro ./ XWLC(ff, pft(end-1), inf);
    
    %Save
    inst(i).xwlcftret = pft;
    inst(i).conproret = conpro;
    
%     %Debug
%     figure, plot(x,f), hold on
%     plot(fitfcn2(pft, f), f, 'LineWidth', 2)
%     plot(fitfcn(dft, f), f, 'LineWidth', 2)
%     
%     figure, plot( windowFilter(@mean, inst(i).conpro, [], 5)  )
end

out = inst;


