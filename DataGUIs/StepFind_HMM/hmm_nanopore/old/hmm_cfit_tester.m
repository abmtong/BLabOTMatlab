function hmm_cfit_tester()

%Generate random means
mus = randn(1,20); %40 steps, heights distributed normally

%Repeat some steps to get 50
sts = [1:length(mus) randi(length(mus),1,10)];
sts = sts(randperm(length(sts)));

sig = .1; %spread is ~6

%Make random lengths
dwlens = ceil(exprnd(20,1,length(sts)));
inds = [1 cumsum(dwlens)];

%Assemble to trace, add noise
tr = ind2tra(inds, mus(sts));
trsig = tr + randn(size(tr))*sig;

%Fit trsig
trfit = hmm_cfit(trsig, sts, mus, 1);

figure, plot(trsig, 'Color', [.7 .7 .7]), hold on
plot(tr, 'g');
plot(trfit, 'r');