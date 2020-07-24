function obp = withoutabat(niter, pid, zonepct, zoneswpct)

%Define number of simulations to run
if nargin < 1
    niter = 50;
end

if nargin < 2
    pid = 'bondb001'; %Barry Bonds
end

if nargin < 3
    zonepct = []; %Chance of a pitch to be in the zone
end

if nargin < 4
    zoneswpct = []; %Chance of a swung-at pitch to be in the zone
end

%Select all .EVA/.EVN files to process
[f, p] = uigetfile('*.EV*', 'MultiSelect', 'on');

if ~p %no file picked
    return
end
if ~iscell(f)
    f = {f};
end

obp = zeros(1, niter);
%Parallelize because this implementation is slow
stT= tic;
parfor j = 1:niter
    %Simulate for each team (as each .EV* file has only home games)
    pas = cellfun(@(x)withoutabat_one([p x], pid, zonepct, zoneswpct, 0), f, 'Uni', 0);
    %Concatenate
    pas = [pas{:}];
    %Calculate OBP
    obp(j) = sum(pas == 0) / sum(pas ~= -1);
end
enT = toc(stT);

figure('Name', sprintf('Monte Carlo for %s', pid))
subplot(2, 1, 1)
plot(ones(1, niter), obp, 'o')
subplot(2, 1, 2)
hist(obp, 30)
fprintf('Average OBP for player %s is %0.3f +/- %0.3f from %d iters in %0.1fmin\n', pid, mean(obp), std(obp), niter, enT/60)

