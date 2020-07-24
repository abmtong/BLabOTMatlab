% This script loads a stepping file, sets a TrialBurstSize search space and
% runs BurstAlignment_Walking several times to find the optimal burst size.
%
% Gheorghe Chistol, 28 Dec 2010

%Define the search space
TrialBurstSize=6:0.05:12;
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

%% Plot the Burst Alignment for the best solution
BurstAlignment_PlotStepping(StepSize, DwellTime, DwellStErr); hold on;

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

%%
%figure; hold on;
%plot(x,y,'.b');
%plot(x,Y,'-k');

%%

%figure;
%plot(DwellCandidates{46},'.k');
%NB=[];
%MinPen=[];
%DwellNumber=[];

%in this case Opt refers to the optimal circumstances
%OptGridStart - the location where the grid starts (the very first dwell is located at zero bp)
%OptBurstPen  - the penalty per burst
%OptTotPen    - the total penalty 
%OptBurstNum  - the number of bursts found in this data
%OptDwellNum  - the number of dwells that fall inside the grid and are used
%to calculate the penalty of the configuration (some of these dwells will
%no contribute to penalty, only the ones closest to the grid lines will actually contribute to the penalty) 
%DwellNum     - the total number of dwells in the current data set
