function out = statehmm_findn(inx, verbose)
%Fit to N-state HMM

nmax = 10; %Lets just set some upper limit
nrep = 10; %Do HMM convergence by finding best lprob, repeating up to N times
npenalty = log(length(inx)); %BIC is klog(n_points)-2logprob, let's just use klogn/2-logprob, where k = num_params.
              %  Each additional state is another two variables (mu and transition probability), so penalty = 2logn/2 = logn

if nargin < 2
    verbose = 1;
end
              
%Initialize some vars
mdl = [];
lprob0 = -inf;

for i = 1:nmax
    %HMM fit
    tmp = stateHMMV2(inx, struct('ns', i, 'verbose', 0));
    lprob = tmp.logprob;
    for j = 2:nrep
        newtmp = stateHMMV2(inx, setfield(tmp, 'verbose', 0)); %#ok<SFLD>
        %See if it beats prev logprob
        if lprob < newtmp.logprob
            tmp = newtmp;
            lprob = newtmp.logprob;
        else
            break
        end
    end
    %So now best model and logprob are in tmp, lprob
    
    %See if it beats prev
    if lprob0 < lprob - npenalty
        %New model is better, overwrite vars
        mdl = tmp;
        lprob0 = lprob;
    else
        %New model is worse, exit
        break
    end
end
%Now best model is stored in mdl

out = mdl;

%Plot
if verbose
    figure, plot(inx, 'Color', [.7 .7 .7])
    hold on
    plot(mdl.mu(mdl.fit))
end





