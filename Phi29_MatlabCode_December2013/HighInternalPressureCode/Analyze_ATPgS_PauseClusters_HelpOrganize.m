%once you get the pause cluster statistics from
%Analyze_ATPgS_PauseClusters, use this function to figure out the basic
%properties

Cluster = Cluster_250ATP_1000gS;

Cluster.Duration_25  = [Cluster_25ATP_20gS.Duration Cluster_25ATP_50gS.Duration Cluster_25ATP_100gS.Duration Cluster_25ATP_500gS.Duration];
Cluster.Duration_250 = [Cluster_250ATP_200gS.Duration Cluster_250ATP_500gS.Duration Cluster_250ATP_1000gS.Duration Cluster_250ATP_2000gS.Duration];
Cluster.Duration_25  = Cluster.Duration_25(Cluster.Duration_25>0.5 & Cluster.Duration_25<50);
Cluster.Duration_250 = Cluster.Duration_250(Cluster.Duration_250>0.5 & Cluster.Duration_250<50);

Cluster.DwellTime = Cluster.DwellTime(Cluster.DwellTime<10);
Cluster.Span_250 = [Cluster_250ATP_200gS.Span Cluster_250ATP_500gS.Span Cluster_250ATP_1000gS.Span Cluster_250ATP_2000gS.Span];
Cluster.Span_25  = [Cluster_25ATP_20gS.Span Cluster_25ATP_50gS.Span Cluster_25ATP_100gS.Span Cluster_25ATP_500gS.Span];

Cluster.DwellTime_250 = [Cluster_250ATP_200gS.DwellTime Cluster_250ATP_500gS.DwellTime Cluster_250ATP_1000gS.DwellTime Cluster_250ATP_2000gS.DwellTime];
Cluster.DwellTime_25 = [Cluster_25ATP_20gS.DwellTime Cluster_25ATP_50gS.DwellTime Cluster_25ATP_100gS.DwellTime Cluster_25ATP_500gS.DwellTime];
Cluster.Span      = Cluster.Span(Cluster.Span>0 & Cluster.Span<50);
Cluster.DwellTime_25  = Cluster.DwellTime_25(Cluster.DwellTime_25>0.5 & Cluster.DwellTime_25<10);
Cluster.DwellTime_250 = Cluster.DwellTime_250(Cluster.DwellTime_250>0.5 & Cluster.DwellTime_250<10);

%% Plot Cluster Dwell Histogram
Bin = 0.1;
Bins = 0.5+Bin/2:Bin:10;
close all;
figure; 
subplot(2,1,1);
hist(Cluster.DwellTime_25,Bins);
ylabel('25uM ATP')
title('GammaS-Induced Pause Cluster Dwells')
set(gca,'XLim',[0.5 10]);
legend('Mean Dwell = 2.14s');
subplot(2,1,2);
hist(Cluster.DwellTime_250,Bins);
ylabel('250uM ATP')
xlabel('Dwell Duration (sec)');
set(gca,'XLim',[0.5 10]);
legend('Mean Dwell = 1.91s');
%set(gca,'YScale','log');

%% Plot Cluster Span Histogram
close all;
Bin = 1;
Bins = 0+Bin/2:Bin:50;
figure;
subplot(2,1,1);
hist(Cluster.Span_25,Bins);
ylabel('25uM ATP');
title('GammaS-Induced Pause Cluster Span');
set(gca,'XLim',[0 50]);
subplot(2,1,2);
hist(Cluster.Span_250,Bins);
ylabel('250uM ATP');
xlabel('Pause Cluster Span (bp)');
set(gca,'XLim',[0 50]);

%% Plot Cluster Duration Histogram
close all;
Bin = 1;
Bins = 0.5+Bin/2:Bin:50;
figure;
subplot(2,1,1);
hist(Cluster.Duration_25,Bins);
ylabel('25uM ATP');
legend('Mean Duration = 6.07s');
title('GammaS-Induced Pause Cluster Duration');
set(gca,'XLim',[0.5 50]);
subplot(2,1,2);
hist(Cluster.Duration_250,Bins);
ylabel('250uM ATP');
legend('Mean Duration = 4.31s');
xlabel('Pause Cluster Duration (sec)');
set(gca,'XLim',[0.5 50]);
%%
title('[ATP]=25uM, Pause Cluster Dwell Statistics');
xlabel('Dwell Duration (sec)');
ylabel('Count');
[a b]=mle(Cluster.DwellTime,'distribution','exponential');
hold on;
y=exp(-Bins*a)*1000;
%plot(Bins,y,'g');
%%
clc;
round(Cluster.PackagedLength/1000)
length(Cluster.Duration)
length(Cluster.Duration)/(Cluster.PackagedLength/1000)
[a b]=mle(Cluster.Duration,'distribution','exponential')

Bin = 2;
Bins = Bin/2:Bin:50;
figure;
hist(Cluster.Span,Bins)
mean(Cluster.Span)
