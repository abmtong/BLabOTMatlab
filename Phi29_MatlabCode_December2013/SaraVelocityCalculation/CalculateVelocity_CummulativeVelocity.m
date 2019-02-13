function CummulativeVelocity = CalculateVelocity_CummulativeVelocity(Velocities)

NormHist=zeros(1,200/10 + 1)
binning=[0:10:200];


for i=1:length(Velocities.Velocities)
    close all;
    TempNormHist=hist(Velocities.Velocities{i},binning)/sum(Velocities.Velocities{i});
    figure;
    bar(binning,TempNormHist);
    NormHist= NormHist + TempNormHist;
    pause(1)
end

FinalHist=NormHist/sum(NormHist);
figure;
bar(binning,FinalHist);

end