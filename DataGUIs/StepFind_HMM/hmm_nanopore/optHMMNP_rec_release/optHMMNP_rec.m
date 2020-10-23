function out = optHMMNP_rec(dat, mu, seq, inOpts)

iter = 1;

lastn = 50;
lastnres = [];
opts.verbose = 0;

if nargin > 3
    opts = handleOpts(opts, inOpts);
end

%Continually do, use @assignin to keep track of outputs

while true
    [out.mu, out.raw] = optHMMNP(dat, mu, seq, opts);
    %Reassign mu, by using last 50 results
    lastnres(mod(iter-1,lastn)+1).raw = out.raw; %#ok<AGROW>
    munew = updateMu(lastnres, mu, ~mod(iter, 50)); %Plot something every 50 iters (~1hr)
    mu = munew;
    out.munew = munew;
    %Assign result to workspace
    if mod(iter, 1) == 0
        assignin('base', 'tmp' , out)
        evalin('base', sprintf('opt(%d) = tmp;', iter))
    end

    iter = iter + 1;
end




