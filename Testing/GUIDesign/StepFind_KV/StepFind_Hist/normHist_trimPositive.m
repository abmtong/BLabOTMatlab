function outP = normHist_trimPositive(inP)

%check if raw data or output from normHist
a = size(inP);
if a(1) > 1 && a(2) == 3
    %output is from normHist, do nothing
else
    inP = normHist(inP);
end

outP = inP(inP(:,1)>0,:);