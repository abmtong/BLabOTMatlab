function optHMMNP_mc(dat, mu0, seq, prevres, inOpts)

iter = 1;

%Requires prevres arg, generated e.g. first from optHMMNP_rec or the output from this fcn

%Monte Carlo options
opts.mcn = 100; %Number of mus to generate before moving on. ~1000pts, 1min per iter (V2C)
opts.mcprc = 80; %Percentile cutoff for what to use for next time

opts.doC = 1;

%Regular opts
opts.verbose = 0;
opts.trnsprb = 1e-10;
opts.btprb = 0;
opts.minlen = 8;


if nargin > 4
    opts = handleOpts(opts, inOpts);
end
ctpts = @(xx) cellfun(@(x)sum(cellfun(@length, x)),{xx.raw});

while true
    %Generate mus
    %Apply percentile cutoff to prev result
    prevpts = ctpts(prevres);
    mu0 = updateMu(prevres(prevpts > prctile(prevpts, opts.mcprc)), mu0, 0);
    mus = updateMuMC(prevres(prevpts > prctile(prevpts, opts.mcprc)), mu0, opts.mcn);
    
    for i = opts.mcn:-1:1
        [newres(i).mu, newres(i).raw] = optHMMNP(dat, mus(i, :), seq, opts);
    end
    
    %Assign result to workspace
    if mod(iter, 1) == 0
        assignin('base', 'tmp' , newres)
        evalin('base', sprintf('optMC(%d) = {tmp};', iter))
    end
    
    %Update
    prevres = newres;
    
    iter = iter + 1;
end




