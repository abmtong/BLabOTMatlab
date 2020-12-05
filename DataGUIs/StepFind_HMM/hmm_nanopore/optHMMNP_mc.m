function optHMMNP_mc(dat, mu0, seq, prevres, inOpts)

iter = 1;

%Requires prevres arg, generated e.g. first from optHMMNP_rec or the output from this fcn

%Monte Carlo options
opts.mcn = 100; %Number of mus to generate before moving on. ~1000pts, 1min per iter (V2C)
opts.mcprc = 80; %Percentile cutoff for what to use for next time

%Whether or not to do seqHMMp2c
opts.doC = 1;

%Whether or not to 
opts.sigMu = 1;
opts.sigtr = 1; %Noise to use for sigMu

%Regular opts
opts.verbose = 0;
opts.btprb = 0;
opts.minlen = 8;

%Fudge factors:
% Since we are trying to optimize for mu, we need some way to let the HMM find 'bad' steps that are actually 'good' but have the wrong mu
% Easy ways are either to decrease the transition probability or increase the sigma
%  For trnsprb, to tolerate a mis-place of a given Z-score and mean length N, it's P(x>Z)^N, which is ~1e-10-1e-20.
%  For sig, uncertainty in mean makes the observation function a convolution of two gaussians (one for observing, the other for which mean it actually is),
%   which essentially means 'increase sigma'. Conv(Gau(VarA), Gau(VarB)) = Gau(VarA+VarB), i.e. the 'reduced mass' of the variances.
%   Since for the most part, Var(Mu) >> Var(data), we could just replace it with Var(Mu) instead.
%    Maybe then we want to include Var of each state, and use this as different sigmas for each state? Now THATs an idea.
opts.trnsprb = 1e-10;


if nargin > 4
    opts = handleOpts(opts, inOpts);
end
ctpts = @(xx) cellfun(@(x)sum(cellfun(@length, x)),{xx.raw});

while true
    stT = tic;
    %Generate mus
    %Apply percentile cutoff to prev result
    prevpts = ctpts(prevres);
    [mu0, muraw] = updateMu(prevres(prevpts > prctile(prevpts, opts.mcprc)), mu0, 0);
    mus = updateMuMC(prevres(prevpts > prctile(prevpts, opts.mcprc)), mu0, opts.mcn);
    if opts.sigMu
    %Calculate 'net noise' the uncertainty in the state and the noise of the data (std varies as hypot.)
        musd = cellfun(@std, muraw);
        musd(isnan(musd)) = 10;
        opts.sig = hypot(musd, opts.sigtr); 
    end
    
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
    
    fprintf('optHMM_mc finished iter %d in %0.2fs\n', iter, toc(stT));
    iter = iter + 1;
end




