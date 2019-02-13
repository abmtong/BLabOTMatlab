%% Set the Analysis Path
%close all;
global analysisPath;
if isempty(analysisPath)
    disp('analysisPath not defined. Use "SetAnalysisPath" to define it');
    return;
else
    disp(['analysisPath has been set to: ' analysisPath]);
end

%% Load the Index File
SteppingFile = uigetfile([ [analysisPath '\'] '*.steps'], 'Please select one Stepping File','MultiSelect', 'off');
SteppingFile = [analysisPath '\' SteppingFile];
if ~exist(SteppingFile) %if no files were selected or file doesn't exist
    disp('No Stepping File was selected'); return;
end

StepSize=[];  
DwellStd=[];  
DwellStErr=[];  
DwellTime=[];  
DwellLocation=[]; 

fid = fopen(SteppingFile);
tline = fgetl(fid); %take the header line off
tline = fgetl(fid); %get the first sata line
%disp([tline]);
while ischar(tline)
    %Now get the feedback cycles specified in the index file
    temp = sscanf(tline,'%f'); %#ok<*AGROW>
    StepSize(end+1)=temp(1);
    DwellStd(end+1)=temp(2);
    DwellStErr(end+1)=temp(3);
    DwellTime(end+1)=temp(4);
    DwellLocation(end+1)=temp(5); 
    tline = fgetl(fid);
end
fclose(fid);

%% Plot the Stepping Pattern
close all;
figure; hold on;
for i=1:length(StepSize)
    %plot step
    if i==1
        t=[0 0];
        y=[0 StepSize(i)]-StepSize(1);
    else
        t=sum(DwellTime(1:i-1))*[1 1];
        y=[sum(StepSize(1:i-1)) sum(StepSize(1:i))]-StepSize(1);
    end
    plot(t,y,'b');
    %plot dwell
    if i==1
        %t=[0 DwellTime(1)];
        %y=StepSize(1)*[1 1]-StepSize(1);
        UncertaintyRect = [0 -DwellStd(i) DwellTime(i) 2*DwellStd(i)];
    else
        %t=[sum(DwellTime(1:i-1)) sum(DwellTime(1:i))];
        %y=sum(StepSize(1:i))*[1 1]-StepSize(1);
        UncertaintyRect = [sum(DwellTime(1:i-1)) sum(StepSize(2:i))-DwellStd(i) DwellTime(i) 2*DwellStd(i)];
    end
    %plot(t,y,'r');
    h=rectangle('Position',UncertaintyRect,'FaceColor','b','EdgeColor','none');
    %get(h)
    %return
end

%% Searching for a penalty minimum
%you can start the penalty walk anywhere within the first 2*TestBurstSize 
%if the penalty increases for PenaltyRiseN consecutive steps, then further
%exploration is abandoned
NoProgressStepsMax=3; %if the penalty increases for 5 consecutive steps, further exploration is abandoned
TestBurstSize=10; %the size of the test burst

DwellStaircase=[];
DwellStaircase_Time=[];
%We will remove the very first step, 
%From now on dwell(i) is followed by step(i)
DwellTime; StepSize(1)='';
for i=1:length(StepSize)
    if i==1 %deal with the veri first one
        DwellStaircase(1)=0;
        DwellStaircase_Time{i}=[0 DwellTime(i)];
    else %deal with the ones in the middle
        DwellStaircase_Time{i}=[sum(DwellTime(1:i-1)) sum(DwellTime(1:i))];
        DwellStaircase(i)=sum(StepSize(1:i-1));
    end
end
%Deal With the last dwell
DwellStaircase_Time{end+1}=[sum(DwellTime(1:end-1)) sum(DwellTime(1:end))];
DwellStaircase(end+1)=sum(StepSize(1:end));
%just checking if I know what I'm doin'
%  for i=1:length(DwellTime)
%      hold on;
%      plot(DwellStaircase_Time{i},DwellStaircase(i)*[1 1],':g');
%  end

StartDwellPool=find(abs(DwellStaircase)<2*TestBurstSize); %the pool of dwells where we can start our penalty search/exploration
sd=1;
b=1;

%for sd=1:length(StartDwellPool) %sd is the index for the Start Dwell
while sd<length(DwellStaircase)-1
    %calculate the penalty forward
    PenaltyMinimumSearchStatus=1;
    d=sd+1; %we start our search with the dwell immediately following the Start Dwell
    NoProgressSteps=0; 

    BurstStartIndex(b)=sd; %this is the current burst starts
    
    Penalty=[];
    while PenaltyMinimumSearchStatus==1 && d<=length(DwellStaircase)
        %compute the penalty for the d-th dwell
        Penalty(d-sd)=BurstAlignment_ComputePenalty(DwellStaircase(sd), DwellStaircase(d),...
                                                    DwellStErr(sd),     DwellStErr(d),...
                                                    TestBurstSize);
        if (d-sd)>1 %we are more than one step away from the start, we have at least two penalties to compare
            PrevPenalty=Penalty(d-sd-1);
            CurrPenalty=Penalty(d-sd);
            if CurrPenalty<PrevPenalty
                %we've made progress in our burst search, explore further
                NoProgressSteps=0;
            else
                NoProgressSteps=NoProgressSteps+1; %increment the counter for the number of steps where we made no progress
                if NoProgressSteps>NoProgressStepsMax || d==length(DwellStaircase)
                    %the second condition will avoid referencing
                    %non-existent data after the trace is finished
                    PenaltyMinimumSearchStatus=0;
                end
            end
        end
        d=d+1;
    end
    %we now found a local minimum
    MinInd          = find(Penalty==min(Penalty));
    DwellBefore     = DwellStaircase(sd);
    DwellAfter      = DwellStaircase(sd+MinInd);
    if logical(rem(b,2)) %if it's an odd-numbered burst, plot shading
        BurstAlignment_DrawShading(DwellBefore,DwellAfter,gca);%shade the burst (or not depending on whether the previous burst was shaded)
    end
    BurstStopIndex(b)   = sd+MinInd;
    b=b+1;
    sd=sd+MinInd;
    %if b==10
    %    return;
    %end
end

TotalPenalty=sum(Penalty)/b;
PenaltyPerBurst=TotalPenalty/length(BurstStopIndex);
title(['Penalty Per Burst ' num2str(PenaltyPerBurst)]);