function out = pol_dwelldist_p2(dws, inOpts)
%Part two: now that we have the dwell times, fit them to exponentials

%Fitting options
opts.xrng = [2e-3 inf]; %Crop some of the shorter dwells, because fitting is wonk
opts.prcmax = 99.9; %Crop the few superlong dwells by percentile - may cause pdf to underflow during search (esp. during mle, as it tries to fit that pt)
opts.nmax = 5; %max exponentials to fit

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
    datmcihi= nan(nrow, ncol);
    datc= nan( nrow, ncol );
    for i = 1:nrow
        %MLE fit
        tmp = out.(rn{i}).fit;
        tmp = reshape(tmp, 2, []);
        %Normalize by a's
        tmp(1,:) = tmp(1,:)/sum(tmp(1,:));
        %Sort by k's
        [~, si] = sort(tmp(2,:), 'descend');
        tmp = tmp(:,si);
        tmp = tmp(:)';
        dat(i,1:length(tmp)) = tmp;
        %Get CIs too
        [~, opti] = min(out.(rn{i}).fitraw.aics);
        tmpci = out.(rn{i}).fitraw.mfcis(opti);
        tlo = tmpci(:,1)';
        thi = tmpci(:,2)';
        datmcilo(i,1:length(tlo)) = tlo;
        datmcihi(i,1:length(thi)) = thi;
        
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
    tbldat = mat2cell([dat; datmcilo; datmcihi], nrow*3, ones(1,ncol) );
    tbl = table( tbldat{:}, 'RowNames', [rn; rn; rn], 'VariableNames', cn);
    %Write to file
    writetable(tbl, 'pol_dwelldistMLE.xls', 'WriteRowNames', true)
    
    tbldat = mat2cell(datc, nrow, ones(1,ncol) );
    tbl = table( tbldat{:}, 'RowNames', rn, 'VariableNames', cn );
    %Write to file
    writetable(tbl, 'pol_dwelldistCfit.xls', 'WriteRowNames', true)
    return
end

%Fit each trace separately
[o, or] = cellfun(@(x) fitnexp_hybrid(x( x > opts.xrng(1) & x < min(opts.xrng(2), prctile(x, opts.prcmax)) ), opts.nmax, 0), dws, 'Un', 0);

%Fit together
dwall = [dws{:}];
[oa, ora] = fitnexp_hybrid(dwall( dwall > opts.xrng(1) & dwall < min(opts.xrng(2), prctile(dwall, opts.prcmax)) ), opts.nmax, 1);

%Save results in out
out.fit = oa;
out.fitraw = ora;
out.sfit = o;
out.sfitraw = or;