function exflg = ABatchHMM_one(inpf, inOpts)
%Does HMM on one guy

%Set up defaults
opts.maxiter = 10;
opts.binsz = 0.1;
opts.maxstep = 15;
opts.verbose = 2;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

fcdata = load(inpf);
fcdata = fcdata.(fcdata);

%Add niter field if not present
if ~isfield(fcdata,'nhmm')
    fcdata.nhmm = 0;
end

while true
    %Check if done:
    %Check if converged
    
    %Check if gt niter
    
    
    
    %Do stepfinding
    fcdatanew = findStepHMMv2(fcdata);
    
    fcdata = fcdatanew;
    fcdata.nhmm = fcdata.nhmm+1;
    %Save
    save(inpf, 'fcdata')
end
