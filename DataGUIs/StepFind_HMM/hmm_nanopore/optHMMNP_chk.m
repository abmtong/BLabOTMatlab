function optHMMNP_chk(dat, mu0, seq, inOpts)

%Check on optHMMNP

%Pick nplot random traces
nplot = 10;
len = length(dat);
rng = randperm(len, min(nplot, len));

%Set verbose flag to plot
inOpts.verbose = 1;
inOpts.mu = mu0;

%do seqHMM
for i = rng
    tr = dat{i};
    %Check for nonempty
    if isempty(tr)
        continue
    end
    
    tmp = seqHMM(tr, inOpts);
    fg = gcf;
    fg.Name = [fg.Name sprintf(' Trace %d', i)];
    fprintf('Trace %d:\n', i)
    seqHMMp2(tr, tmp, seq, inOpts);
    drawnow
end
