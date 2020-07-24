function [MinPenalty NB DwellNumber]=BurstAlignment_UsingGrid(TestBurstSize,SteppingFile)

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
        t=[0 DwellTime(1)];
        y=StepSize(1)*[1 1]-StepSize(1);
        UncertaintyRect = [0 -DwellStErr(i) DwellTime(i) 2*DwellStErr(i)];
    else
        UncertaintyRect = [sum(DwellTime(1:i-1)) sum(StepSize(2:i))-DwellStErr(i) DwellTime(i) 2*DwellStErr(i)];
        t=[sum(DwellTime(1:i-1)) sum(DwellTime(1:i))];
        y=sum(StepSize(1:i))*[1 1]-StepSize(1);
    end
    
    rectangle('Position',UncertaintyRect,'FaceColor',0.8*[1 1 1],'EdgeColor','none');
    plot(t,y,'k');
end

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

%% Set Up a grid with uniform spacing (given by the TestBurstSize) 
%set up the grid start sliding the grid from
%DwellStaircase(1)+0.6*TestBurstSize to DwellStaircase(1)-0.6*TestBurstSize
%compute the penalty associated with each of the grid configurations
%TestBurstSize=7; %the size of the test burst
StartLocation=[];
ConfigPenaltyPerBurst=[];
StartLocation=(DwellStaircase-0.6*TestBurstSize) : 0.05 : (DwellStaircase+0.6*TestBurstSize);
for sl=1:length(StartLocation) %sl is the index for StartLocation
    CurrentLocation = StartLocation(sl);
    GridLine=[]; %the gridlines that are spaced by TestBurstSize
    if CurrentLocation>DwellStaircase(1)
        GridLine(1)=CurrentLocation-TestBurstSize;
    else
        GridLine(1)=CurrentLocation;
    end
    
    %XLim=get(gca,'XLim');
    %plot(XLim,GridLines(end)*[1 1],':k');
    while GridLine(end)-TestBurstSize>DwellStaircase(end)
        GridLine(end+1)=GridLine(end)-TestBurstSize;
        %XLim=get(gca,'XLim');
        %plot(XLim,GridLines(end)*[1 1],':k');
    end
    %figure;hold on;
    %plot(GridLine,GridLine,'k+',GridLine,GridLine,'k.');
    %plot(DwellStaircase,DwellStaircase,'b.');
    %go through each GridLine and find the closest two dwells (one from
    %each side)
    ConfigPenalty(sl)=0;%we will add the penalty terms for this configuration as we go along
    ConfigPenaltyPerBurst(sl)=0;
    for gl=1:length(GridLine) %gl is the GridLine index
        DistanceFromGridLine=DwellStaircase-GridLine(gl);
        MinInd = find(abs(DistanceFromGridLine)==min(abs(DistanceFromGridLine)));
        if DistanceFromGridLine(MinInd)>0 %closest dwell to the gridline is above the line
            AboveInd = MinInd;
            BelowInd = MinInd+1;
        else %the closes dwell to the gridline is below the gridline
            AboveInd = MinInd-1;
            BelowInd = MinInd;
        end
        
        %Now we compute the penalties associated with the AboveDwell and
        %BelowDwell with respect to the current GridLine. The least of
        %these two penalties will contribute to the total penalty of the
        %current configuration
        if gl==1 %this is the first grid line, consider only BelowInd
            %compute the penalty between a dwell and the current grid line
            Penalty=BurstAlignment_ComputePenalty(DwellStaircase(BelowInd), GridLine(gl),...
                                                  DwellStErr(BelowInd), 0, TestBurstSize);
            ConfigPenalty(sl)=ConfigPenalty(sl)+Penalty;
        elseif gl==length(GridLine) %this is the last line, consider only AboveInd
            Penalty=BurstAlignment_ComputePenalty(DwellStaircase(AboveInd), GridLine(gl),...
                                                  DwellStErr(AboveInd), 0, TestBurstSize);
            ConfigPenalty(sl)=ConfigPenalty(sl)+Penalty;
        else %this is an inbetween line, consider both AboveInd and BelowInd
            PenaltyBelow=BurstAlignment_ComputePenalty(DwellStaircase(BelowInd), GridLine(gl),...
                                                  DwellStErr(BelowInd), 0, TestBurstSize);
            PenaltyAbove=BurstAlignment_ComputePenalty(DwellStaircase(AboveInd), GridLine(gl),...
                                                  DwellStErr(AboveInd), 0, TestBurstSize);
            %find the smallest penalty of the two, if they're equal, that's
            %the final penalty
            if PenaltyAbove<PenaltyBelow
                Penalty=PenaltyAbove;
            else
                Penalty=PenaltyBelow;
            end
            ConfigPenalty(sl)=ConfigPenalty(sl)+Penalty;
            ConfigPenaltyPerBurst(sl)=ConfigPenalty(sl)/length(GridLine);
            %length(GridLine)
        end
    end
end
%length(StartLocation)
%length(ConfigPenaltyPerBurst)
DwellNumber=length(DwellStaircase);
%figure;
%plot(StartLocation,ConfigPenaltyPerBurst,'ob');
close all;
MinPenalty=min(ConfigPenalty);
disp(['TestBurstSize: ' num2str(TestBurstSize) 'bp;  MinPenaltyPerBurst: ' num2str(MinPenalty)]);
NB=length(GridLine);
%n=1000;
%X=[];
%for i=1:length(DwellTime)
%    X=[X ones(1,n*DwellTime(i))*DwellStaircase(i)];
%end
%HistogramBins = min(X):0.5:max(X);
%[N, D] = GhePairWiseDistribution(X,HistogramBins);
%plot(D,N,'b');
%set(gca,'XLim',[3 60]);
%close all;

% Penalty(d-sd)=BurstAlignment_ComputePenalty(DwellStaircase(sd), DwellStaircase(d),...
%                                             DwellStErr(sd),     DwellStErr(d),...
%                                             TestBurstSize);
% BurstAlignment_DrawShading(DwellBefore,DwellAfter,gca);%shade the burst (or not depending on whether the previous burst was shaded)
