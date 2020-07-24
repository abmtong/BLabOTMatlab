%Summarize_ATP_GammaS_Cluster_Statistics.m
C=[10 20 50 100];
N=[10 25 91 171];
DNA=[20 30 31 25]; %in kb
ErrN=sqrt(N);
PauseDensity=N./DNA;
PauseDensityErr=ErrN./DNA;

p=polyfit([0 C],[0 PauseDensity],1);
x=0:1:100;
y=polyval(p,x);
figure;
errorbar(C,PauseDensity,PauseDensityErr,'.b','MarkerSize',20,'LineWidth',2);
hold on;
plot(x,y,':k');
set(gca,'FontSize',14)
xlabel('ATP-{\gamma}-S Concentration (nM)');
ylabel('Pause Density (per kb DNA)');
title('ATP-{\gamma}-S Induced Pause Density')
axis([0 120 0 8])