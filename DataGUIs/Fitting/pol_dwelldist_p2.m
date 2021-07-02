function out = pol_dwelldist_p2(dws, inOpts)
%Part two: now that we have the dwell times, fit them to exponentials

%Fitting options
opts.xrng = [2e-3 inf]; %Crop some of the shorter dwells, because fitting is wonk
opts.prcmax = 99.9; %Crop the few superlong dwells by percentile - may cause pdf to underflow during search (esp. during mle, as it tries to fit that pt)
opts.nmax = 8; %max exponentials to fit
opts.fitsing = 1; %Fit traces separately?
opts.groupdws = 1; %Group N dwells together, fit as Gammas

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%If input is struct, batch
if isstruct(dws)
    rn = fieldnames(dws);
    out = [];
    %Do fitting
    for i = 1:length(rn);
        out.(rn{i}) = pol_dwelldist_p2(dws.(rn{i}), opts);
        fg = gcf;
        set(fg, 'Name', rn{i})
    end
    
    %Form table
    cn = [];
    for i = 1:opts.nmax
        cn = [cn {sprintf('a%d', i) sprintf('k%d', i)}]; %#ok<AGROW>
    end
    nrow = length(rn);
    ncol = length(cn);
    %Take each output in out
    dat = nan( nrow, ncol );
    datmcilo= nan(nrow, ncol);

    datc= nan( nrow, ncol );
    for i = 1:nrow
        %MLE fit
        tmp = out.(rn{i}).fit;
        tmp = reshape(tmp, 2, []);
        %Normalize by a's ... or keep reg 
        asum = sum(tmp(1,:));
        tmp(1,:) = tmp(1,:)/asum;
        %Sort by k's
        [~, si] = sort(tmp(2,:), 'descend');
        tmp = tmp(:,si);
        tmp = tmp(:)';
        dat(i,1:length(tmp)) = tmp;
        %Get CIs too
        [~, opti] = min(out.(rn{i}).fitraw.aics);
        tmpci = out.(rn{i}).fitraw.mfcis{opti}';
        tlo = tmpci(:,1)';
        tlo(1:2:end) = tlo(1:2:end)/asum;
        datmcilo(i,1:length(tlo)) = tlo;
        
        %Curve fit
        [~, opti] = min(out.(rn{i}).fitraw.aicscf);
        tmpc = out.(rn{i}).fitraw.cfits{opti};
        tmpc = reshape(tmpc, 2, []);
        %Normalize by a's
        tmpc(1,:) = tmpc(1,:)/sum(tmpc(1,:));
        %Sort by k's
        [~, si] = sort(tmpc(2,:), 'descend');
        tmpc = tmpc(:,si);
        tmpc = tmpc(:)';
        datc(i,1:length(tmpc)) = tmpc;
    end
    tbldat = mat2cell([dat; datmcilo], nrow*2, ones(1,ncol) );
    tbl = table( tbldat{:}, 'RowNames', [rn; strcat(rn, '_CI')], 'VariableNames', cn);
    try
        writetable(tbl, 'pol_dwelldistMLE.xls', 'WriteRowNames', true)
    catch
        warning('Writing MLE to .xls failed, try running in the same folder as %s', mfilename);
    end
    out.tblMLE = tbl;
    tbldat = mat2cell(datc, nrow, ones(1,ncol) );
    tbl = table( tbldat{:}, 'RowNames', rn, 'VariableNames', cn );
    %Write to file
    try
        writetable(tbl, 'pol_dwelldistCfit.xls', 'WriteRowNames', true)
    catch
        warning('Writing Cfit to .xls failed, try running in the same folder as %s', mfilename);
    end
    out.tblCfit = tbl;
    %Plot graphs of ki's and ai's
    %Crop to furthest right non-NaN column in dat
    maxcol = find(all(isnan(dat),1), 1, 'first')-1;
    if isempty(maxcol)
        maxcol = length(cn);
    end
    %Save args for p3 and run it
    out.pddp3 = {rn, cn(1:maxcol), dat(:,1:maxcol), datmcilo(:,1:maxcol)};
    pol_dwelldist_p3(out.pddp3{:})
    return
end

if opts.fitsing
    %Fit each trace separately
    if opts.groupdws == 1
        [o, or] = cellfun(@(x) fitnexp_hybrid(x( x > opts.xrng(1) & x < min(opts.xrng(2), prctile(x, opts.prcmax)) ), opts.nmax, 0), dws, 'Un', 0);
    else
        %Group dwells
        dwsgrp = cellfun(@(x) sum( reshape( x(1: opts.groupdws*floor(length(x)/opts.groupdws)), opts.groupdws, []), 1), dws, 'Un', 0);
        [o, or] = cellfun(@(x) fitngam_hybrid(x( x > opts.xrng(1) & x < min(opts.xrng(2), prctile(x, opts.prcmax)) ), opts.groupdws, opts.nmax, 0), dwsgrp, 'Un', 0);
    end
    out.sfit = o;
    out.sfitraw = or;
end

%Fit together
if opts.groupdws == 1
    dwall = [dws{:}];
    [oa, ora] = fitnexp_hybrid(dwall( dwall > opts.xrng(1) & dwall < min(opts.xrng(2), prctile(dwall, opts.prcmax)) ), opts.nmax, 1);
else
    dwsgrp = cellfun(@(x) sum( reshape( x(1: opts.groupdws*floor(length(x)/opts.groupdws)), opts.groupdws, []), 1), dws, 'Un', 0);
    dwall = [dwsgrp{:}];
    [oa, ora] = fitngam_hybrid(dwall( dwall > opts.xrng(1) & dwall < min(opts.xrng(2), prctile(dwall, opts.prcmax)) ), opts.nmax, opts.groupdws, 1);
end

%Save results in out
out.fit = oa;
out.fitraw = ora;
out.n = length(dwall);