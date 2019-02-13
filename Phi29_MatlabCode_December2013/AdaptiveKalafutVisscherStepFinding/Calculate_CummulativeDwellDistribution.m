function CummulativeDwell = Calculate_CummulativeDwellDistribution(Dwell)

NormHist=zeros(1,1/0.02 + 1)
binning=[0:0.02:1];


for i=1:length(Dwell)
    close all;
    TempNormHist=hist(Dwell(i).Duration,binning)/sum(Dwell(i).Duration);
    figure;
    bar(binning,TempNormHist);
    NormHist= NormHist + TempNormHist;
    pause(1)
end

FinalHist=NormHist/sum(NormHist);
figure;
bar(binning,FinalHist);

end