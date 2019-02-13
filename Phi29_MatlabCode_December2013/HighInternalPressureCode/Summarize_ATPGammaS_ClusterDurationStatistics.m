% This script loads a series of cluster statistics structures, then plots
% the data and estimates the exponential lifetime using a Maximum Likelyhood
% Estimator
%
% The Cluster Statistics Structures can be generated using the following
% function: Cluster_20nM_PNP = Analyze_ATPgS_PauseClusters;
% 
% This script requires the following data structures to be loaded into
% the matlab workspace:
%
% Cluster_20nM_PNP
% Cluster_50nM_PNP
% Cluster_100nM_PNP
% Cluster_500nM_PNP

PNP_Conc = [20 50 100 500]; %in nM
ClusterDuration{1} = Cluster_20nM_PNP.Duration; %duration is in sec
ClusterDuration{2} = Cluster_50nM_PNP.Duration; %duration is in sec
ClusterDuration{3} = Cluster_100nM_PNP.Duration; %duration is in sec
ClusterDuration{4} = Cluster_500nM_PNP.Duration; %duration is in sec

%% Remove all Clusters longer than MaxClusterDuration 
%this is done to avoid double-gamma-S pauses, especially at higher concentrations
MaxClusterDuration = 50; %in seconds
for i=1:length(ClusterDuration)
    KeepInd = ClusterDuration{i}<MaxClusterDuration;
    ClusterDuration{i} = ClusterDuration{i}(KeepInd);
end

%% Plot the data, calculate the Tau for the distributions
Bins = 0:2:MaxClusterDuration;
%now go through the duration data for each concentration and calculate the
%Tau as well as plot the data

Tau = zeros(1,length(ClusterDuration)); %the exponential lifetime of the cluster duration
LegendText = [];
X=[];
Y=[]; %X and Y data for plotting

Marker = {'.b','^r','om','+k'};
figure; hold on;

for i=1:length(ClusterDuration)
    [n x] = hist(ClusterDuration{i},Bins);
    %remove all the zeros and normalize the distribution
    KeepInd = n>0;
    n = n(KeepInd);
    x = x(KeepInd);
    n = n/sum(n); %normalize the distribution
    X{i} = x;
    Y{i} = n;
    plot(X{i},Y{i},Marker{i});
    
    Tau(i) = mle(ClusterDuration{i},'distribution','exponential');
    LegendText{i} = ['[AMP-PNP] = ' sprintf('%d',PNP_Conc(i)) ' nM, {\tau} = ' sprintf('%2.1f',Tau(i)) ' sec, (N = ' sprintf('%d',length(ClusterDuration{i})) ')'];
end

legend(LegendText{1},LegendText{2},LegendText{3},LegendText{4})
set(gca,'FontSize',10);
xlabel('ATP-{\gamma}-S Induced Pause Cluster Duration (sec)');
ylabel('Probability (normalized)');