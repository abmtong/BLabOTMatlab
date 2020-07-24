function exflgs = ABatchHMM(inOpts)
% Runs findStepHMM on pHMM files

[f, p] = uigetfile('pHMM*.mat','Mu', 'on');
if ~p
    return
end
if ~iscell(f)
    f={f};
end

%Set up defaults
opts.maxiter = 10;
opts.binsz = 0.1;
opts.maxstep = 15;
opts.verbose = 2;

if nargin > 0
    opts = handleOpts(opts, inOpts);
end

%Maybe have binsize change? Start large, become smaller after a few iters [to speed convergence]

len = length(f);
exflgs = zeros(1,len);
%For each file...
parfor i = 1:len
    try
        exflgs(i) = ABatchHMM_one([p f{i}], opts);
    catch
        exflgs(i) = -1;
    end 
end