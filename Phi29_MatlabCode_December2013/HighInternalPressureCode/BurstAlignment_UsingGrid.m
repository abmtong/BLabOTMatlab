function [OptGridStart OptBurstPen OptTotPen OptBurstNum OptDwellNum DwellNum]=BurstAlignment_UsingGrid(TrialBurstSize,SteppingFile)
%[MinPenalty NB DwellNumber]=BurstAlignment_UsingGrid(TrialBurstSize,SteppingFile)
% This function tries to find the optimal burst size that corresponds to a
% feedback cycle. The function is given a stepping pattern and a range of
% Burst Sizes. We create a uniformly spaced grid with a spacing of the
% burst size and calculate a DeltaX^2 Penalty (it's basically least squares
% fitting with a twist). The Akaike information criterion will later be
% used used to compensate for over-fitting.
%
% USE: [OptGridStart OptBurstPen OptTotPen OptBurstNum]
%       =BurstAlignment_UsingGrid(TrialBurstSize,SteppingFile)
% 
% Gheorghe Chistol, 22 Dec 2010

global GridLinePenalty;
StepSize      = [];  
DwellStd      = [];  
DwellStErr    = [];  
DwellTime     = [];  
DwellLocation = []; 

%----- Read the stepping pattern from the text file
fid = fopen(SteppingFile);
tline = fgetl(fid); %take the header line off
tline = fgetl(fid); %get the first sata line
while ischar(tline)
    temp                 = sscanf(tline,'%f'); %read the current line #ok<*AGROW>
    StepSize(end+1)      = temp(1);
    DwellStd(end+1)      = temp(2);
    DwellStErr(end+1)    = temp(3);
    DwellTime(end+1)     = temp(4);
    DwellLocation(end+1) = temp(5); 
    tline                = fgetl(fid); %get the next line
end
fclose(fid);

%----- Plot the Stepping Pattern
close all; figure; hold on;
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
StepSize(1)=''; %DwellTime remains unchanged
for i=1:length(StepSize)
    if i==1 %deal with the very first dwell
        DwellStaircase(1)      = 0;
        DwellStaircase_Time{i} = [0 DwellTime(i)];
    elseif i==length(StepSize) %deal with the very last dwell
        DwellStaircase_Time{i}   = [sum(DwellTime(1:i-1)) sum(DwellTime(1:i))];
        DwellStaircase(i)        = sum(StepSize(1:i-1));
        DwellStaircase_Time{i+1} = [sum(DwellTime(1:i-1)) sum(DwellTime(1:i))];
        DwellStaircase(i+1)      = sum(StepSize(1:i));
    else %deal with the dwells in the middle
        DwellStaircase_Time{i} = [sum(DwellTime(1:i-1)) sum(DwellTime(1:i))];
        DwellStaircase(i)      = sum(StepSize(1:i-1));
    end
end

%----- Quick Consistency Check Plot (Staircase)
% for i=1:length(DwellTime)
%     hold on;
%     plot(DwellStaircase_Time{i},DwellStaircase(i)*[1 1],':g');
% end

%----- Set Up a Grid with Uniform Spacing (given by the current burst size) 
% The grid position can slide to find the optimal grid overlay on top of
% the stepping pattern
% From DwellStaircase(1)+0.6*TrialBurstSize to DwellStaircase(1)-0.6*TrialBurstSize
% Then we compute the penalty associated with each grid configuration

clear global GridLinePenalty;
global GridLinePenalty;
%GridLinePenalty={}; %initialize the data structure
for tbs=1:length(TrialBurstSize) %tbs indexes the trial burst sizes 
    % we will cycle through all the burst sizes
    CurrentBurstSize         = TrialBurstSize(tbs);
    NumberOfDwellsUsed{tbs}  = []; %the number of dwells that are used in a particular case
    GridStartLocation{tbs}   = []; %where the current burst grid starts
    GridStartLocation{tbs}   = (DwellStaircase-0.6*TrialBurstSize(tbs)) ...
                                : 0.1 : ...
                               (DwellStaircase+0.6*TrialBurstSize(tbs));
    GridLinePenalty{tbs}={};
    for gsl=1:length(GridStartLocation{tbs}) %gsl is the index for GridStartLocation
        CurrentStartLocation = GridStartLocation{tbs}(gsl); %where the current grid starts
        %each grid line will have a penalty associated with it
        GridLinePenalty{tbs}{gsl} = [];
        
        GridLine{gsl}=[]; %the gridlines that are spaced by TrialBurstSize

        %the first grid line should not be above the highest dwell
        if CurrentStartLocation>max(DwellStaircase)
            GridLineStart=CurrentStartLocation-CurrentBurstSize;
        else
            GridLineStart=CurrentStartLocation;
        end

        %the last grid line should not be below the lowest dwell
        GridLine{gsl} = GridLineStart:-CurrentBurstSize:min(DwellStaircase);
        
        %calculate the number of dwells that are used in the current calculation
        NumberOfDwellsUsed{tbs}(gsl) = ...
        sum(DwellStaircase<max(GridLine{gsl}) & DwellStaircase>min(GridLine{gsl}));
                                         
        for gl=1:length(GridLine{gsl}) %gl is the GridLine index
            % find the closest dwells to the current gridline, namely:
            % the closest dwell Above the gridline and
            % the closest dwell Below the gridline
            DistanceFromGridLine = (DwellStaircase-GridLine{gsl}(gl));
            MinInd = find(abs(DistanceFromGridLine)==min(abs(DistanceFromGridLine)));

            if DistanceFromGridLine(MinInd)>0 %closest dwell is above the line
                AboveInd = MinInd;
                BelowInd = MinInd+1;
            else %closest dwell is below the gridline
                AboveInd = MinInd-1;
                BelowInd = MinInd;
            end

            % now we compute the penalties associated with the dwell Above and
            % dwell Below with respect to the current GridLine. The least of
            % these two penalties will contribute to the total penalty of the
            % current configuration
            if gl==1 %this is the first grid line, consider only the dwell Below
                %compute the penalty between the dwell and the current grid line
                Penalty = BurstAlignment_ComputePenalty(DwellStaircase(BelowInd),GridLine{gsl}(gl),DwellStErr(BelowInd),0,CurrentBurstSize);
                GridLinePenalty{tbs}{gsl}(gl) = Penalty;
            elseif gl==length(GridLine) %this is the last line, consider only the dwell Above
                Penalty = BurstAlignment_ComputePenalty(DwellStaircase(AboveInd),GridLine{gsl}(gl),DwellStErr(AboveInd),0,CurrentBurstSize);
                GridLinePenalty{tbs}{gsl}(gl) = Penalty;
            else %this is an inbetween grid line, consider both dwells Above and Below
                PenaltyBelow = BurstAlignment_ComputePenalty(DwellStaircase(BelowInd),GridLine{gsl}(gl),DwellStErr(BelowInd),0,CurrentBurstSize);
                PenaltyAbove = BurstAlignment_ComputePenalty(DwellStaircase(AboveInd),GridLine{gsl}(gl),DwellStErr(AboveInd),0,CurrentBurstSize);
                %find the smallest penalty of the two
                %if PenaltyAbove<=PenaltyBelow
                %    Penalty=PenaltyAbove;
                %else
                %    Penalty=PenaltyBelow;
                %end
                if PenaltyAbove==PenaltyBelow
                    Penalty=PenaltyAbove;
                elseif PenaltyAbove>3*PenaltyBelow
                    Penalty=PenaltyBelow;
                elseif PenaltyBelow>3*PenaltyAbove
                    Penalty=PenaltyAbove;
                else
                    Penalty=PenaltyAbove+PenaltyBelow;
                end
                GridLinePenalty{tbs}{gsl}(gl)=Penalty;
            end
            %GridLinePenalty{tbs}{gsl}
        end
        %return
    end
    %size(GridLinePenalty)
end
%length(TrialBurstSize)
%return

%  tbs - test burst size index
%  gsl - grid start location index
%  gl  - grid line index
% TrialBurstSize(tbs)
%    GridStartLocation{tbs}(gsl)
%       GridLine{gsl}(gl)    
%       GridLinePenalty{tbs}{gsl}(gl)
% PenaltyPerBurst{tbs}(gsl) = []; % penalty per burst 
                                  % for a given Grid Start Location (gsl) 
                                  % for a given Test Burst Size (tbs)
NumberOfBursts  = {};
TotalPenalty    = {};
PenaltyPerBurst = {};
OptGridStart = [];
OptBurstPen  = [];
OptTotPen    = [];
OptBurstNum  = [];

%P=[]; %list of all penalty values
%X=[]; %trial burst size
%Y=[]; %grid start location
for tbs=1:length(TrialBurstSize)
    NumberOfBursts{tbs}  = [];
    TotalPenalty{tbs}    = [];
    PenaltyPerBurst{tbs} = [];
    for gsl=1:length(GridStartLocation{tbs})
        NumberOfBursts{tbs}(gsl)  = (length(GridLinePenalty{tbs}{gsl})-1); %the number of gridlines minus one
        TotalPenalty{tbs}(gsl)    = sum(GridLinePenalty{tbs}{gsl});        %the sum of all penalties for that grid
        PenaltyPerBurst{tbs}(gsl) = TotalPenalty{tbs}(gsl)/NumberOfBursts{tbs}(gsl);
    end
    
    %For a given trial burst size, the global minimum corresponds to a
    %specific Grid Start Location
    Ind = find(PenaltyPerBurst{tbs}==min(PenaltyPerBurst{tbs}));
    Ind=Ind(1); %just in case we have multiple equal minima
    
    OptGridStart(tbs) = GridStartLocation{tbs}(Ind); %the value of the optimal grid start location
    OptBurstPen(tbs)  = PenaltyPerBurst{tbs}(Ind);
    OptTotPen(tbs)    = TotalPenalty{tbs}(Ind);
    OptBurstNum(tbs)  = NumberOfBursts{tbs}(Ind);
    OptDwellNum(tbs)  = NumberOfDwellsUsed{tbs}(Ind);
    %X=[X TrialBurstSize(tbs)*ones(1,length(PenaltyPerBurst{tbs}))]; %#ok<*AGROW>
    %Y=[Y GridStartLocation{tbs}];
    %P=[P PenaltyPerBurst{tbs}];
end
DwellNum = length(DwellStaircase);
%----------- Plot the 2D PenaltyPerBurst Surface
% figure; hold on;
% MinP=min(P);
% MaxP=max(P);
% Color = 1-(P-MinP)./(MaxP-MinP); %black corresponds to minimum PenaltyPerBurst
%                                  %white corresponds to maximum PenaltyPerBurst
% for i=1:length(Color)
%    plot(X(i),Y(i),'.','Color',[1 1 1]*Color(i));
% end
% xlabel('Trial Burst Size (bp)');
% ylabel('Grid Start Location (bp)');
% title('Penalty Per Burst 2D Surface (white - minima)');