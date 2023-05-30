function out = RPpass_p2_xwlc(inst, inOpts)
%Finds the rips / futile excursions
%Input: output of RPpass_p2 (!!)

opts.nint = 2; %Number of intermediates. Higher = finds more excursions, but try not to do so high.
opts.fil = 200; %Filtering TP estimation. Doubles as a time cutoff (2*dsamp/Fs = time threshold)
                  %Filter so any excursion from the baseline is 'obvious'
opts.kdfbinsz = 0.01; %Bin size, nm, just for histogram to estimate F/U well
opts.kdfsd = 1; %SD for kdf

%U/F detection options
opts.maxoob = inf; %Max number of out-of-bounds points
opts.pwlcc = 0.35*106; %We'll just set the F-U distance = full contour.
opts.szrng = 10 * [.5 2]; %Acceptable U-F distance. To catch cases where there aren't two peaks, etc. Try 1/2 to 2x the expected size.

%Drift correction options
opts.fixdrift = 1;

opts.xwlcft = [49.05 523.49 0.6]; %XWLC fit: PL SM PLp

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(inst);
for i = 1:len
    tmp = inst(i);
    %Get data
    ext = double( tmp.ext );
    frc = double( tmp.frc );
    
    if ~isfield(tmp, 'conpro')
        continue
    end
    
    %Let's actually crop the edges since the filtering is so large
    opts.fil = (length(ext) - length(tmp.conpro)) / 2;
    if length(ext) > 2*opts.fil+1
        ext =  ext( 1+opts.fil: end-opts.fil );
        frc =  frc( 1+opts.fil: end-opts.fil );
    else %Tiny trace, ignore
        continue
    end
    
    %Use extension/forces from p2 to calculate DNA component
    conD = tmp.extuf(1) / XWLC( tmp.folfrc(1), opts.xwlcft(1), opts.xwlcft(2)) ;
%     conD = mu(1) / 
    ext = ext - XWLC( frc, opts.xwlcft(1), opts.xwlcft(2) ) * conD;
    
    %Reapply drift correction
    mu = tmp.extuf(3:4);
    ext = ext - ( (1:length(ext))*tmp.driftslope(1) + tmp.driftslope(2) ) * ( diff(mu) ) / opts.pwlcc;
    
    con = ext ./ XWLC( frc, opts.xwlcft(3), inf );
    
    %Recalc U/F
    conF = windowFilter(@mean, con, opts.fil, 1);
    tra = round( conF / opts.pwlcc * (opts.nint+2) );
    
    con = con / median(con(tra == opts.nint+2)) * opts.pwlcc;
    
    inst(i).conpro = con;
    %Assume mu(1) is 
% 
%     %'Convert to contour' by setting mu(1) -> 0, mu(2) -> opts.pwlcc
%     con = (ext - mu(1)) / diff(mu) * opts.pwlcc;
%     conF = (extF - mu(1)) / diff(mu) * opts.pwlcc;
%     
%     
%     %Convert trace to 'state space', so F = 1, U = opts.nint+2
%     tra = conF / opts.pwlcc * (opts.nint + 1) +1;
%     
%     %And just take the nearest state
%     tra = round(tra);
%     
%     %Sanity check: states are from 1 to nint+2
%     tfoob = tra < 0 | tra > opts.nint+2;
%     oob = sum(tfoob);
%     if oob
%         if oob > opts.maxoob
%             warning('Found %d/%d out-of-bounds states, probably error, skipping.', oob, length(tra))
%             figure('Name', sprintf('Data Skipped for too many OoB states: %s', inst(i).file))
%             plot(conF)
%             hold on
%             xx = (1:length(conF));
%             plot(xx(tfoob), conF(tfoob), 'o')
%             legend({'Data' 'Out-of-bounds data'})
%             drawnow
%             continue
%         else
%             warning('Found %d/%d out-of-bounds states, consider filtering more or finding fewer intermediates', oob, length(tra))
%             figure('Name', sprintf('Data has a few OoB states, check: %s', inst(i).file) )
%             plot(conF)
%             hold on
%             xx = (1:length(conF));
%             plot(xx(tfoob), conF(tfoob), 'o')
%             legend({'Data' 'Out-of-bounds data'})
%             drawnow
%         end
%             
%         %And fix by coercing values
%         tra = min(max(tra, 1) , opts.nint+2);
%     end
%     
%     %Fix drift, if asked. Assumes drift is linear, independent
%     if opts.fixdrift
%         %Separate states at U, F
%         xxf = 1:length(conF);
%         isxxf = tra==1;
%         xxf = xxf(isxxf); %Is this faster or worse than find(isxxu)?
%         stf = conF(isxxf);
%         
%         xxu = 1:length(conF);
%         isxxu = tra==opts.nint+2;
%         xxu = xxu(isxxu);
%         stu = conF(isxxu);
%         
%         %Lets downsample by 100x for speed (we've already filtered)
%         xxf = xxf(1:100:end);
%         xxu = xxu(1:100:end);
%         stf = stf(1:100:end);
%         stu = stu(1:100:end);
%         
%         %Fit to line: two offsets, single slope
%         fittf = [ones(1, length(xxf)) zeros(1, length(xxu))];
%         fitfcn = @(x0,x) x0(1)*x + x0(2)*fittf + x0(3)*~fittf;
%         ftop = optimoptions('lsqcurvefit', 'Display', 'off');
%         ft = lsqcurvefit(fitfcn, [0 0 opts.pwlcc], [xxf xxu], [stf stu], [], [], ftop);
%         
%         %Debug: Check fitting
% %         figure, hold on, plot(conF), plot([1 length(conF)], polyval( ft([1 3]), [1 length(conF)])), plot([1 length(conF)], polyval( ft([1 2]), [1 length(conF)]))
%         
%         %Subtract F state line
%         con  = con  - ft(1) * (1:length(con)) - ft(2);
%         conF = conF - ft(1) * (1:length(con)) - ft(2);
%         
%         %Recalc mu
%         mu = [median( extF (tra==1)), median( extF( tra== opts.nint+2))];
%         
%         %Recalc tra
%         tra = round (conF / opts.pwlcc * (opts.nint + 1) +1);
%         tra = min(max(tra, 1) , opts.nint+2);
%         
%     else
%         ft = [];
%     end
%     
%     
%     %Convert trace to staircase index
%     [in, me] = tra2ind(tra);
%     
%     %Get the four types of excursions: F>U, U>F, F>F, U>U
%     %Find where the trace is at F or U
%     fu = find( me == 1 | me == opts.nint+2);
%     hei = length(fu)-1;
%     outraw = zeros(hei,4); %Store [start, end, type] here, type = [0, 1, 2, 3] == [U>U, U>F, F>U, F>F]
%     isfolded = me(fu) == 1; %Simplifies type calculation, as it is equivalent to binary u->0, f->1
%     
%     for j = 1:hei
%         %Starting index is right edge of fu(j), end is left edge of fu(j+1), type is (see above)
%         ki = in(fu(j)+1):in(fu(j+1));
%         crp = conF(ki);
%         tt = 2*isfolded(j) + isfolded(j+1);
%         
%         %Refine guess by finding mid crossing / mid deviations
%         switch tt
%             case 1 %U>F
%                 %Middle crossing
%                 iref = find(crp < opts.pwlcc/2, 1, 'first' );
%             case 2 %F>U
%                 %Middle crossing
%                 iref = find(crp > opts.pwlcc/2, 1, 'first' );
% %             case 0 %U>U
% %                 %Lowest value
% %                 [~, iref] = min(crp);
% %             case 3 %F>F
% %                 %Highest value
% %                 [~, iref] = max(crp);
%             otherwise %Just take middle point
%                 iref = round( length(ki)/2 );
% %             otherwise %Convert to cumulative absolute deviations and pick 'middle' value?
% %                 % Or just pick lowest/highest value?
% %                 cad = [0 cumsum( abs( diff( crp ) ) )];
% %                 iref = find( cad > cad(end)/2, 1, 'first');
%         end
%         %Convert snip index to real index
%         iref = iref + ki(1) -1;
% 
% %         %Refine guess by finding a step with K-V
% %         %Place one step with K-V for F>U , or two for F>F
% %         if tt == 1 || tt == 2 %U>F or F>U
% %             tin = AFindStepsV5(crp, 0, 1, 0);
% %         else %U>U or F>F
% %             tin = AFindStepsV5(crp, 0, 2, 0);
% %         end
% %           iref = tin(2)+ki(1)-1;
%         %Save all four data anyway: 'middle', left edge, right edge, type
%         outraw(j,:) = [iref, ki(1), ki(end), tt];
%         
%     end
%     
%     %Get the median force, ext of each state as a marker of 'position'
%     folfrc = median( inst(i).frc( tra == 1 ) );
%     folext = median( inst(i).ext( tra == 1 ) );
%     unffrc = median( inst(i).frc( tra == opts.nint+2 ) );
%     unfext = median( inst(i).ext( tra == opts.nint+2 ) );
%     
%     %Redo calculation with these new extensions? No real difference, keep original
% %     con = (ext - folext) / (unfext - folext) * opts.pwlcc;
%     
%     %Save
%     inst(i).conpro = con;
%     inst(i).extuf = [folext unfext mu]; %Can sanity check diff(mu) vs. force
%     inst(i).rips = outraw;
%     inst(i).folfrc = [folfrc unffrc];
%     inst(i).driftslope = ft;
end

% %Remove empty conpro == skipped
% ki = cellfun(@isempty, {inst.conpro});
% %Save the rejects as second output?
% rejects = inst(ki);
% %Remove rejects
% inst = inst(~ki);

out = inst;














