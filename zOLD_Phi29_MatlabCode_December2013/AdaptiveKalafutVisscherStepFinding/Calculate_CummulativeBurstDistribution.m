function CummulativeBurst = Calculate_CummulativeBurstDistribution(Burst)

NormHist=zeros(1,20/1 + 1)
binning=[0:1:20];


for i=1:length(Burst)
    close all;
    TempNormHist=hist(Burst(i).Size,binning)/sum(Burst(i).Size);
    figure;
    bar(binning,TempNormHist);
    NormHist= NormHist + TempNormHist;
    pause(1)
end

FinalHist=NormHist/sum(NormHist);
figure;
bar(binning,FinalHist);

end