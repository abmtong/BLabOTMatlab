TrialBurstSize=8.5:0.1:11;
%TrialBurstSize=10;
% Set the Analysis Path
close all;
global analysisPath;
if isempty(analysisPath)
    disp('analysisPath not defined. Use "SetAnalysisPath" to define it');
    return;
else
    %disp(['analysisPath has been set to: ' analysisPath]);
end


%% Load the Index File
SteppingFileName = uigetfile([ [analysisPath '\'] '*.steps'], 'Please select one Stepping File','MultiSelect', 'off');
SteppingFile = [analysisPath '\' SteppingFileName];
if ~exist(SteppingFile) %if no files were selected or file doesn't exist
    disp('No Stepping File was selected'); return;
end
NB=[];
MinPen=[];
DwellNumber=[];
%for i=1:length(B)
    %[MinPen(i) NB(i) DwellNumber(i)]=BurstAlignment_UsingGrid(B(i),SteppingFile);
%end
[OptGridStart OptBurstPen OptTotPen OptBurstNum OptDwellNum DwellNum] = ...
BurstAlignment_UsingGrid(TrialBurstSize,SteppingFile);

%in this case Opt refers to the optimal circumstances
%OptGridStart - the location where the grid starts (the very first dwell is located at zero bp)
%OptBurstPen  - the penalty per burst
%OptTotPen    - the total penalty 
%OptBurstNum  - the number of bursts found in this data
%OptDwellNum  - the number of dwells that fall inside the grid and are used
%to calculate the penalty of the configuration (some of these dwells will
%no contribute to penalty, only the ones closest to the grid lines will actually contribute to the penalty) 
%DwellNum     - the total number of dwells in the current data set
%%
%AkaikeScore = 2*OptBurstNum+DwellNum.*log(OptTotPen);
AkaikeScore = 2*2+DwellNum.*log(OptTotPen);
MinInd = find(AkaikeScore==min(AkaikeScore));
X = TrialBurstSize(MinInd); %best burst size that fits this data set

%----- Shade the Bursts (as calculated)
DwellStaircase=[];
for i=1:OptBurstNum(MinInd)+2
    DwellStaircase(i)=OptGridStart(MinInd)-(i-1)*X;
end

for i=2:length(DwellStaircase)
    DwellBefore = DwellStaircase(i-1);
    DwellAfter  = DwellStaircase(i);
    if rem(i,2)==0
        %draw the shade
        BurstAlignment_DrawShading(DwellBefore,DwellAfter,gca);
    end
end
figure;
subplot(2,1,1)
plot(TrialBurstSize,OptBurstPen,'.k',...
     TrialBurstSize,OptBurstPen,'-k');
%hold on; plot(8.725*[1 1],[0 8000],':r');
legend('Optimal Penalty per Burst','Location','SE');
subplot(2,1,2)
plot(TrialBurstSize,AkaikeScore,'.b',...
     TrialBurstSize,AkaikeScore,'-b');

YLim=get(gca,'YLim');
hold on;
plot(X*[1 1],YLim,':r');
%plot(X+1*[1 1],YLim,':r');
%plot(X+2*[1 1],YLim,':r');
legend('Akaike Score','Location','SE');
xlabel('Burst Size (bp)');
subplot(2,1,1);
title([SteppingFileName],'Interpreter','none');
set(gcf,'Position',[30 200 560 420]);