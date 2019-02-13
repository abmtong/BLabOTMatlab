function [out, scl] = prepTrHMM(tr, binsz)

%renormalize tr, so smallest point is binsz, trace is increasing
%scl relates tr and out by out = tr*scl(1) + scl(2)
scl = [1 0];
pfit = polyfit(1:length(tr),tr,1);
if pfit(1)<0
    tr = -tr;
    %tr=fliplr(tr);
    scl(1) = -1;
end
out = tr - min(tr)+binsz;
scl(2) = - min(tr)+binsz;
