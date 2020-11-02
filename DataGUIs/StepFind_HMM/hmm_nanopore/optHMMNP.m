function [out, outraw] = optHMMNP(dat, mu, seq, inOpts)

opts.verbose = 0;
opts.trnsprb = 1e-20;
opts.minlen = 8;
opts.doC = 0;
opts.verboseopt = 1;

if nargin > 3
    opts = handleOpts(opts, inOpts);
end

niter = length(dat);
nt = 'ATGC';
stT = tic;

opts.mu = mu;

newmu = cell(1,niter);
parfor i = 1:niter;
    tr = dat{i};
    if isempty(tr)
        continue
    end
    
    %Do sequencing
    res = seqHMM(tr, opts);
    
    % Get mu update
    if opts.doC
        tmp1 = seqHMMp2c(tr, res, seq, opts);
        %Hm this may skip those that would have been found by p2. Maybe do both?
        tmp2 = seqHMMp2(tr, res, seq, opts);
        newmu{i} = [tmp1;tmp2]; %This may double-count some, I am ok with this. Weight 7-len more.
    else
        newmu{i} = seqHMMp2(tr, res, seq, opts);
    end
end

[out, outraw] = seqHMMp3(newmu, opts.verbose);
hold on
plot( mu, (1:256)+.1 , 'o', 'Color', [.7 .7 .7])
newmu = out(:,1)';

fprintf('%d traces analyzed in %0.2fs, %d/256 levels found with %d points\n', niter, toc(stT), sum(~isnan(newmu)), sum( cellfun(@length, outraw)))