function verdict=StepFinding_BinomialVerdict(Nabove,Ntotal,BinThresh)
%This function gives a verdict on whether a dwell is different from or 
%the same as the previous larger dwell. A dwell has a total number of
%points Ntotal, out of thich Nabove are above a certain given value. We
%have a binomial probability threshold (BinThresh). If a dwell is truly a
%single dwell we expect rougly 50% of the points to be above the mean. If
%however, the dwell is actually composed of other dwells, we can look at
%the subdwells and see how many of their points are above the mean of the
%big dwell. We use the Binomial distribution to evaluate the probability of
%a certain configuration (Nabove,Ntotal). If the probability of this
%configuration is less than the threshold, it means the subdwell is
%actually distinct, so the verdict is 'diff'. Otherwise, the verdict is
%'same', i.e. the subdwell is part of the big dwell.
%
%USE: verdict=StepFinding_BinomialVerdict(Nabove,Ntotal,BinThresh)
%
%Gheorghe Chistol, 16 March 2011

%Nabove = nr of pts above the mean
%Ntotal = total nr of pts in this dwell
if Nabove<Ntotal
    cdf=binocdf(Nabove,Ntotal,0.5);
else
    cdf=binocdf(Ntotal-Nabove,Ntotal,0.5);
end

if cdf<BinThresh
	%this configuration is unlikely, this dwell is on independent
    %from the original dwell
    verdict = 'diff'; 
else
    %this configuration is likely, this dwell is the same as the
    %original dwell
    verdict = 'same';
end