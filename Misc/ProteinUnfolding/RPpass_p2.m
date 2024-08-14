function [out, rejects] = RPpass_p2(inst, inOpts)
%Finds the rips / futile excursions
%Input: output of RP_passiveV2

opts.nint = 2; %Number of intermediates. Higher = finds more excursions, but try not to do so high.
opts.fil = 200; %Filtering TP estimation. Doubles as a time cutoff (2*dsamp/Fs = time threshold)
                  %Filter so any excursion from the baseline is 'obvious'
opts.kdfbinsz = 0.01; %Bin size, nm, just for histogram to estimate F/U well
opts.kdfsd = 1; %SD for kdf

%U/F detection options
opts.maxoob = inf; %Max number of out-of-bounds points
opts.pwlcc = 0.35*106; %We'll just set the F-U distance = full contour.
opts.szrng = 10 * [.5 2]; %Acceptable U-F distance. To catch cases where there aren't two peaks, etc. Try 1/2 to 2x the expected size.
opts.ppl = 0.6; %Protein persistence length

%Contour calculation method
opts.conmeth = 1; %1 = Just set U/F = peaks, 2: use XWLC like RP
opts.xwlcft = [50 900 825 0 0 0.6 37.1]; %XWLC fit options, same as RP

%Drift correction options
opts.fixdrift = 1;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(inst);
[inst.conpro] = deal([]); %Add field, in case all sections fail, later refs to conpro won't error
for i = 1:len
    %Get data
    ext = double( inst(i).ext );
    frc = double( inst(i).frc );
    %Filter
    extF = windowFilter(@median, ext, opts.fil, 1);
    frcF = windowFilter(@median, frc, opts.fil, 1); %Only used if XWLC is used, but eh
    
    %Let's actually crop the edges since the filtering is so large
    if length(ext) > 2*opts.fil+1
        ext  =  ext( 1+opts.fil: end-opts.fil );
        extF = extF( 1+opts.fil: end-opts.fil );
        frc =   frc( 1+opts.fil: end-opts.fil );
        frcF = frcF( 1+opts.fil: end-opts.fil );
    else %Tiny trace, ignore
        continue
    end
    %Find U/F loc with findpeaks
%     [p, x] = nhistc(extF, opts.binsz);
    [p, x] = kdf(extF, opts.kdfbinsz, opts.kdfsd);
    %Assemble : get peaks with @findpeaks. Assume smoothness
    [pkht, mu] = findpeaks(p, x);
    %Sort by peak height and take highest two
    [~, si] = sort(pkht, 'descend');
    
    %Reject trace if we don't find two peaks
    if length(si) < 2
        warning('Skipping this section, no transitions')
        figure('Name', sprintf('Data skipped for no transitions: %s', inst(i).file))
        plot(extF)
        drawnow
        continue
    end
    %Else take the two peaks
    mu = sort(mu( si(1:2) ));
    
    %Reject trace if two peaks aren't 'right' distance apart
    if diff(mu) < opts.szrng(1) || diff(mu) > opts.szrng(2)
        warning('Skipping this section, transition size (%0.2f) seems wrong (expecting %0.2f-%0.2f)', diff(mu), opts.szrng(1), opts.szrng(2))
        figure('Name', sprintf('Data skipped for improper transition size: %s', inst(i).file))
        plot(extF)
        hold on
        plot([1 length(extF)], mu(1) * [1 1])
        plot([1 length(extF)], mu(2) * [1 1])
        drawnow
        continue
    end
    

    
    %'Convert to contour' by setting mu(1) -> 0, mu(2) -> opts.pwlcc
    switch opts.conmeth
        case 1
            con = (ext - mu(1)) / diff(mu) * opts.pwlcc;
            conF = (extF - mu(1)) / diff(mu) * opts.pwlcc;
        case 2
            xwlcft = opts.xwlcft;
            %Convert: contour = ( total ext - DNA ext ) / WLC_protein
            %Should we use a filtered force in this calc? Probably not?
            con = (ext - XWLC( frc, xwlcft(1), xwlcft(2) ) * xwlcft(3) ) ./ XWLC(frc, xwlcft(end-1), inf);
            conF = (extF - XWLC( frcF, xwlcft(1), xwlcft(2) ) * xwlcft(3) ) ./ XWLC(frcF, xwlcft(end-1), inf);
    end
    
    %Convert trace to 'state space', so F = 1, U = opts.nint+2
    tra = conF / opts.pwlcc * (opts.nint + 1) +1;
    
    %And just take the nearest state
    tra = round(tra);
    
    %Sanity check: states are from 1 to nint+2
    tfoob = tra < 0 | tra > opts.nint+2;
    oob = sum(tfoob);
    if oob
        if oob > opts.maxoob
            warning('Found %d/%d out-of-bounds states, probably error, skipping.', oob, length(tra))
            figure('Name', sprintf('Data Skipped for too many OoB states: %s', inst(i).file))
            plot(conF)
            hold on
            xx = (1:length(conF));
            plot(xx(tfoob), conF(tfoob), 'o')
            legend({'Data' 'Out-of-bounds data'})
            drawnow
            continue
        else
            warning('Found %d/%d out-of-bounds states, consider filtering more or finding fewer intermediates', oob, length(tra))
            figure('Name', sprintf('Data has a few OoB states, check: %s', inst(i).file) )
            plot(conF)
            hold on
            xx = (1:length(conF));
            plot(xx(tfoob), conF(tfoob), 'o')
            legend({'Data' 'Out-of-bounds data'})
            drawnow
        end
            
        %And fix by coercing values
        tra = min(max(tra, 1) , opts.nint+2);
    end
    
    %Fix drift, if asked. Assumes drift is linear, independent
    if opts.fixdrift
        %Separate states at U, F
        xxf = 1:length(conF);
        isxxf = tra==1;
        xxf = xxf(isxxf); %Is this faster or worse than find(isxxu)?
        stf = conF(isxxf);
        
        xxu = 1:length(conF);
        isxxu = tra==opts.nint+2;
        xxu = xxu(isxxu);
        stu = conF(isxxu);
        
        %Lets downsample by 100x for speed (we've already filtered)
        xxf = xxf(1:100:end);
        xxu = xxu(1:100:end);
        stf = stf(1:100:end);
        stu = stu(1:100:end);
        
        %Fit to line: two offsets, single slope
        fittf = [ones(1, length(xxf)) zeros(1, length(xxu))];
        fitfcn = @(x0,x) x0(1)*x + x0(2)*fittf + x0(3)*~fittf;
        ftop = optimoptions('lsqcurvefit', 'Display', 'off');
        ft = lsqcurvefit(fitfcn, [0 0 opts.pwlcc], [xxf xxu], [stf stu], [], [], ftop);
        
        %Debug: Check fitting
%         figure, hold on, plot(conF), plot([1 length(conF)], polyval( ft([1 3]), [1 length(conF)])), plot([1 length(conF)], polyval( ft([1 2]), [1 length(conF)]))
        
        %Subtract F state line
        con  = con  - ft(1) * (1:length(con)) - ft(2);
        conF = conF - ft(1) * (1:length(con)) - ft(2);
        
        %Recalc mu
        mu = [median( extF (tra==1)), median( extF( tra== opts.nint+2))];
        
        %Recalc tra
        tra = round (conF / opts.pwlcc * (opts.nint + 1) +1);
        tra = min(max(tra, 1) , opts.nint+2);
        
    else
        ft = [];
    end
    
    
    %Convert trace to staircase index
    [in, me] = tra2ind(tra);
    
    %Get the four types of excursions: F>U, U>F, F>F, U>U
    %Find where the trace is at F or U
    fu = find( me == 1 | me == opts.nint+2);
    hei = length(fu)-1;
    outraw = zeros(hei,4); %Store [start, end, type] here, type = [0, 1, 2, 3] == [U>U, U>F, F>U, F>F]
    isfolded = me(fu) == 1; %Simplifies type calculation, as it is equivalent to binary u->0, f->1
    
    for j = 1:hei
        %Starting index is right edge of fu(j), end is left edge of fu(j+1), type is (see above)
        ki = in(fu(j)+1):in(fu(j+1));
        crp = conF(ki);
        tt = 2*isfolded(j) + isfolded(j+1);
        
        %Refine guess by finding mid crossing / mid deviations
        switch tt
            case 1 %U>F
                %Middle crossing
                iref = find(crp < opts.pwlcc/2, 1, 'first' );
            case 2 %F>U
                %Middle crossing
                iref = find(crp > opts.pwlcc/2, 1, 'first' );
%             case 0 %U>U
%                 %Lowest value
%                 [~, iref] = min(crp);
%             case 3 %F>F
%                 %Highest value
%                 [~, iref] = max(crp);
            otherwise %Just take middle point
                iref = round( length(ki)/2 );
%             otherwise %Convert to cumulative absolute deviations and pick 'middle' value?
%                 % Or just pick lowest/highest value?
%                 cad = [0 cumsum( abs( diff( crp ) ) )];
%                 iref = find( cad > cad(end)/2, 1, 'first');
        end
        %Convert snip index to real index
        iref = iref + ki(1) -1;

%         %Refine guess by finding a step with K-V
%         %Place one step with K-V for F>U , or two for F>F
%         if tt == 1 || tt == 2 %U>F or F>U
%             tin = AFindStepsV5(crp, 0, 1, 0);
%         else %U>U or F>F
%             tin = AFindStepsV5(crp, 0, 2, 0);
%         end
%           iref = tin(2)+ki(1)-1;
        %Save all four data anyway: 'middle', left edge, right edge, type
        outraw(j,:) = [[iref, ki(1), ki(end)] + opts.fil, tt]; %Convert back to pre-cropped index
        
    end
    
    %Get the median force, ext of each state as a marker of 'position'
    folfrc = median( inst(i).frc( tra == 1 ) );
    folext = median( inst(i).ext( tra == 1 ) );
    unffrc = median( inst(i).frc( tra == opts.nint+2 ) );
    unfext = median( inst(i).ext( tra == opts.nint+2 ) );
    
    %Redo calculation with these new extensions? No real difference, keep original
%     con = (ext - folext) / (unfext - folext) * opts.pwlcc;
    
    %Save
    inst(i).conpro = con;
    inst(i).extuf = [folext unfext mu]; %Can sanity check diff(mu) vs. force
    inst(i).rips = outraw;
    inst(i).folfrc = [folfrc unffrc];
    inst(i).driftslope = ft;
end

%Remove empty conpro == skipped
ki = cellfun(@isempty, {inst.conpro});
%Save the rejects as second output?
rejects = inst(ki);
%Remove rejects
inst = inst(~ki);

out = inst;














