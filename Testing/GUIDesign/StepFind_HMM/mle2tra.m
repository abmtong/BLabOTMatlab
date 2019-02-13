function [outind, outmea, outtra] = mle2tra(mle, mindist)
%want to merge steps in mle HMM fit to a true staircase, as that often fits better than vitterbi

%KV seems to work pretty well for this
[outind, outmea, outtra] = AFindStepsV5(mle, 400);


%{
%merge all steps smaller than mindist
len = length(mle);
pos = mle(1);
outind = 1;

%only register the step if it's moved more than mindist away
for i = 1:len-1
    if mle(i) > pos + mindist
        outind = [outind i]; %can write this out, e.g. outind = zeroes(size(mle)); ... outind(i) = i; ... outind = sort(outind(outind>0));
        pos = mle(i);
    end
end
outmea = mle(outind);
outind = [outind len];
outtra = ind2tra(outind, outmea);

%}