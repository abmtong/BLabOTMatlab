function out = RPp3V2(inst, inOpts)
%p3: With the segments identified, let's fit to WLC
%V2: Fit to three pieces: pull pre-rip, pull post-rip, relax pre-refold
%    Also protein WLC is allowed to vary. May need to 'normalize' this length in p3b

% opts.procon =  0.38*66 ; %Protein contour, nm: lets say 0.4nm/aa
opts.fil = 30; %Filter with this width, downsample
% opts.verbose = 1; %Plot fit

%Fitting Options: XWLC info/guesses
opts.dwlcg = [50 900]; %DNA XWLC guess, [PL(nm) SM(pN)]
opts.dwlcc = 2000*.34; %DNA contour length guess, 0.34nm/bp
% Guess taken from what I've observed for DNA in HiRes
opts.pwlcg = 0.4; %Protein XWLC PL guess
opts.pwlcc = 0.38*106; %Protein contour length, will be used as a set value. ROSS is 106aa, but expts introduce loops that increase it
% opts.pwlcc = 0.35*78; %FoldIII
opts.fminretract = 12; %Force cutoff for retraction part. Useful for better fitting protein param.s

opts.xwlcopt = [1 1 1 1 1 1 1]; %Set to 0 to fix these to guess

% Guess taken from https://www.pnas.org/doi/10.1073/pnas.1300596110

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Fit pre-rip to DNA XWLC (detected in p2) and post-rip to XWLC DNA+protein (set protein CL constant, as PL and CL are roughly inversely proportional at low PL)
len = length(inst);
optopts = optimoptions('lsqcurvefit', 'Display', 'off');
ki = true(1,len);
for i = 1:len
    %Get this pull
    tmp = inst(i);
    %Filter 
    x = double( windowFilter(@mean, tmp.ext( 1:tmp.retind ), [], opts.fil*2+1) );
    f = double( windowFilter(@mean, tmp.frc( 1:tmp.retind ), [], opts.fil*2+1) );
    ri = floor(tmp.ripind / (opts.fil*2+1));
    xr = double( windowFilter(@mean, tmp.ext( tmp.retind+1:end ), [], opts.fil*2+1) );
    fr = double( windowFilter(@mean, tmp.frc( tmp.retind+1:end ), [], opts.fil*2+1) );
    mi = find( fr < opts.fminretract, 1, 'first' );
    xr = xr(1:mi);
    fr = fr(1:mi);
%     r2 = length(x);
    x = [x xr]; %#ok<AGROW>
    f = [f fr]; %#ok<AGROW>
    
    %ri must be at least be length(xg) below, else lsqcurvefit will error. Just skip if so [probably a bad rip detection]
    if ri < 5
        fprintf('Skipping pull %d/%d, probably bad rip detection\n', i, len)
        ki(i) = false;
        continue
    end
    
    %Fit pre-rip to just XWLC
    xg = [opts.dwlcg opts.dwlcc 0 0];%PL (nm), SM (pN), CL (nm), dx, df, PL(protein) CL(protein) <<should probably fix
    lb = [0   0   0   -00 -0 ]; %set ext and frc offsets to 0, but can enable if needed
    ub = [1e3 1e4 inf  00  0 ];
    fitfcn = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) );
    dft = lsqcurvefit(fitfcn, xg, f(1:ri),x(1:ri), lb, ub, optopts);
    
    xg2 = [dft opts.pwlcg opts.pwlcc];%PL (nm), SM (pN), CL (nm), dx, df, PL(protein) CL(protein) <<should probably fix
    lb2 = [lb 0.1 0 ]; %set ext and frc offsets to 0, but can enable if needed
    ub2 = [ub 2 opts.pwlcc*3];
    fitfcn2 = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) + ...
            ((1:length(f)) > ri ) .* x0(7) .* XWLC(f-x0(5), x0(6),inf) );
    pft = lsqcurvefit(fitfcn2, xg2, f, x, lb2, ub2, optopts);
    
    %Subtract away DNA portion
    extpro =  tmp.ext - XWLC( tmp.frc, pft(1), pft(2) ) * pft(3);
    
    %Convert to contour
    conpro = extpro ./ XWLC(tmp.frc, pft(end-1), inf);
    
    %Save
    inst(i).xwlcft = pft;
    inst(i).conpro = conpro;
    
%     %Debug
%     figure, plot(x,f), hold on
%     plot(fitfcn2(pft, f), f, 'LineWidth', 2)
%     plot(fitfcn(dft, f), f, 'LineWidth', 2)
%     
%     figure, plot( windowFilter(@mean, inst(i).conpro, [], 5)  )
end

%Crop out those that failed processing
out = inst(ki);


