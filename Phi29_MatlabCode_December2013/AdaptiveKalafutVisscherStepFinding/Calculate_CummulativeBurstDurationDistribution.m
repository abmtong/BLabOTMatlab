function CummulativeBurst = Calculate_CummulativeBurstDurationDistribution(Burst)

NormHist=zeros(1,0.1/0.005 + 1);
binning=[0:0.005:0.1];


for i=1:length(Burst)
    close all;
    BurstVector=Burst(i).Duration;
    BurstVector=BurstVector(~isnan(BurstVector));
    TempNormHist=hist(BurstVector,binning)/sum(BurstVector);
    figure;
    bar(binning,TempNormHist);
    NormHist= NormHist + TempNormHist;
    pause(1)
end

FinalHist=NormHist/sum(NormHist);
figure;
bar(binning,FinalHist);

end