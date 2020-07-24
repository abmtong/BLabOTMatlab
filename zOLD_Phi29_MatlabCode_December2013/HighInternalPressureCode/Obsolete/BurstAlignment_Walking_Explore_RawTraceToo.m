% This script loads a stepping file, sets a TrialBurstSize search space and
% runs BurstAlignment_Walking several times to find the optimal burst size.
%
% Gheorghe Chistol, 28 Dec 2010

%Define the search space
TrialBurstSize=6:0.05:14;
%TrialBurstSize=[7.5 7.9 8.0];
close all;

%Load the Data
[StepSize DwellTime DwellLocation DwellStd DwellStErr FileName]=BurstAlignment_LoadSteppingFile();

%Plot the Stepping Pattern
%BurstAlignment_PlotStepping(StepSize, DwellTime, DwellStErr);

%Create the Staircase
DwellStaircase=[]; DwellStaircase_Time=[];
%We will remove the very first step, From now on dwell(i) is followed by step(i)
TempStepSize=StepSize(2:end);
for i=1:length(TempStepSize)
    if i==1 %deal with the veri first one
        DwellStaircase(1)=0;
        DwellStaircase_Time{i}=[0 DwellTime(i)];
    else %deal with the ones in the middle
        DwellStaircase_Time{i}=[sum(DwellTime(1:i-1)) sum(DwellTime(1:i))];
        DwellStaircase(i)=sum(TempStepSize(1:i-1));
    end
end
%Deal With the last dwell
DwellStaircase_Time{end+1}=[sum(DwellTime(1:end-1)) sum(DwellTime(1:end))];
DwellStaircase(end+1)=sum(TempStepSize(1:end));
%just checking if I know what I'm doin'
%  for i=1:length(DwellTime)
%      hold on;
%      plot(DwellStaircase_Time{i},DwellStaircase(i)*[1 1],':g');
%  end
[TotalPenalty PenaltyPerBurst NumberOfBursts DwellCandidates]=BurstAlignment_Walking(TrialBurstSize,DwellStaircase,DwellStErr,StepSize,DwellTime);
clear AkaikeScore;
for i=1:length(PenaltyPerBurst)
    AkaikeScore(i)=2*NumberOfBursts(i)+length(DwellStaircase)*log(TotalPenalty(i));
    %AkaikeScore(i)=2+log(TotalPenalty(i));
end

figure;
subplot(2,1,1)
plot(TrialBurstSize,PenaltyPerBurst,'.b');
legend('Penalty Per Burst');
title([FileName],'Interpreter','none');
subplot(2,1,2)
plot(TrialBurstSize,AkaikeScore,'.k');
legend('AkaikeScore');
set(gcf,'Position',[15   170   560   420]);
xlabel('Trial Burst Size (bp)');

BestSolution=find(AkaikeScore==min(AkaikeScore));
BestSolution=BestSolution(1); %just in case there are more than one equal minima

%% Load the Raw Data Trace, then filter it
global analysisPath;
CurrentPhageFileName = [analysisPath '\' 'phage' FileName(1:9) '.mat'];
load(CurrentPhageFileName);
FeedbackCycle = str2num(FileName(11:12));
t=stepdata.time{FeedbackCycle}; %indexed data fromt the current trace
c=stepdata.contour{FeedbackCycle}; %indexed data fromt the current trace
FilterBand=200; %bandwidth of the filtered data
FilterFactor = round(2500/FilterBand);
T=FilterAndDecimate(t,FilterFactor); %filter time vector
C=FilterAndDecimate(c,FilterFactor); %filter contour length vector
%% offset the contour data accordingly
Ind=T<T(end) & T>=T(end)-DwellTime(end);
ContourOffset=mean(C(Ind))-DwellStaircase(end);
C=C-ContourOffset;
TimeOffset = T(end)-sum(DwellTime);
T=T-TimeOffset;

%% Plot Raw Data
figure; hold on;
plot(T,C,'-','Color',[0.3 0.3 0.3]);
for i=1:length(StepSize)
    if i==1
        t=[0 0]; y=[0 StepSize(i)]-StepSize(1);
    else
        t=sum(DwellTime(1:i-1))*[1 1]; y=[sum(StepSize(1:i-1)) sum(StepSize(1:i))]-StepSize(1);
    end
    plot(t,y,'b');
    if i==1
        t=[0 DwellTime(1)]; y=StepSize(1)*[1 1]-StepSize(1);
        UncertaintyRect = [0 -DwellStErr(i) DwellTime(i) 2*DwellStErr(i)];
    else
        UncertaintyRect = [sum(DwellTime(1:i-1)) sum(StepSize(2:i))-DwellStErr(i) DwellTime(i) 2*DwellStErr(i)];
        t=[sum(DwellTime(1:i-1)) sum(DwellTime(1:i))]; y=sum(StepSize(1:i))*[1 1]-StepSize(1);
    end
    if DwellStErr(i)>0 %sometimes the StErr is too small
        rectangle('Position',UncertaintyRect,'FaceColor',0.8*[1 1 1],'EdgeColor','none');
    end
    plot(t,y,'k');
end

%% Plot the Burst Alignment for the best solution
%BurstAlignment_PlotStepping(StepSize, DwellTime, DwellStErr);
x=1:1:length(DwellCandidates{BestSolution});
y=DwellCandidates{BestSolution};
p=polyfit(x,y,1);
Y=polyval(p,x);

for k=1:length(DwellCandidates{BestSolution})-1
    DwellBefore = DwellCandidates{BestSolution}(k);
    DwellAfter  = DwellCandidates{BestSolution}(k+1);
    if logical(rem(k,2))
        BurstAlignment_DrawShading(DwellBefore,DwellAfter,gca,'m');
    else
        BurstAlignment_DrawShading(DwellBefore,DwellAfter,gca,'g');
    end
    
end
hold on;
%plot the best guess for bursts
for k=1:length(DwellCandidates{BestSolution})
    plot(get(gca,'XLim'),Y(k)*[1 1],':k');
end
title([FileName ', Best Solution Burst=' num2str(TrialBurstSize(BestSolution)) 'bp'],'Interpreter','none');
set(gcf,'Position',[590   170   560   420]);
