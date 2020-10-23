function [out, outraw] = optHMMNP(dat, mu, seq, inOpts)

opts.verbose = 0;
opts.trnsprb = 1e-20;
opts.minlen = 8;
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
    newmu{i} = seqHMMp2(tr, res, seq, opts);
end

[out, outraw] = seqHMMp3(newmu, opts.verbose);
hold on
plot( mu, (1:256)+.1 , 'o', 'Color', [.7 .7 .7])
newmu = out(:,1)';

fprintf('%d traces analyzed in %0.2fs.\n', niter, toc(stT))
fprintf('%d/256 levels found with %d points\n', sum(~isnan(newmu)), sum( cellfun(@length, outraw)));