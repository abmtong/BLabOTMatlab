%Gheorghe Chistol, 3 June 2010, Preparation for Group Meeting
%add the path so I can use the functions in the main Analysis folder
path('C:\Documents and Settings\Phi29\Desktop\MatlabCode\MatlabFilesGhe\MatlabGeneral\NewAnalysisCode\',path);
clear all; close all;
%% Load the sample 21kb trace
load('SamplePhageTrace_21kb.mat');
Trace=stepdata; clear stepdata;
N=20;
T=[];
L=[];
for i=2:length(Trace.time)-3
    T = [T FilterAndDecimate(Trace.time{i},N)];
    L = [L FilterAndDecimate(Trace.contour{i},N)];
end

%% Load the sample empty-capsid trace
load('SamplePhageTrace_EmptyCapsid.mat');
Trace=stepdata; clear stepdata;
N=20;
T2=[];
L2=[];
for i=2:length(Trace.time)-4
    T2 = [T2 FilterAndDecimate(Trace.time{i},N)];
    L2 = [L2 FilterAndDecimate(Trace.contour{i},N)];
end

%%
figure; hold on;
plot(T,L,'k');
plot(T2,L2,'k');
title('Phi29 Packaging 21kb DNA vs 10kb DNA');
xlabel('Time (sec)');
ylabel('DNA Contour Length (bp)')
    