function [FirstDwell SecondDwell] = KV_ValidateDwells_SplitSandwich(FirstDwell, SecondDwell, FiltT, FiltY)
    % This script uses the Schwartz Information Criterion to split data between
    % two validated dwells. Originally there are two validated dwells
    % (FirstDwell and Second Dwell) and an unvalidated candidate dwell sandwiched between
    % the two. At this point we have determined that the unvalidated candidate
    % dwell is a false positive and should be somehow split between the two
    % validated dwells that surround it. How exactly we split it is decided
    % using the Schwartz Information Criterion.
    %
    % FirstDwell  - the first  (spatially on top)    validated dwell 
    % SecondDwell - the second (spatially on bottom) validated dwell
    % FiltT       - time vector at the bandwidth used for KV stepfinding
    % FiltY       - contour vector at the bandwidth used for KV stepfinding
    %
    % Gheorghe Chistol, 30 June 2011

    %the dwell data structure is as follows
    % CandidateDwells(d).
    %                    Start
    %                    Finish
    %                    Mean
    %                    StartTime
    %                    FinishTime
    %                    DwellTime
    %                    DwellLocation
    %
    %         sometimes .MergeStatus
    %                   .PrecursorDwell(1)
    %                   .PrecursorDwell(2)

    %% Find only one step - separating FirstDwell from the SecondDwell
    %so we're splitting the proverbial sandwich in two
    Y = FiltY(FirstDwell.Start:SecondDwell.Finish); %our Y-data vector now covers only the two dwells and whatever's in between
    T = FiltT(FirstDwell.Start:SecondDwell.Finish); %our T-data vector now covers only the two dwells and whatever's in between

    % DwellInd(1).Start  = 1;
    % DwellInd(1).Finish = length(Y); %there is only one dwell at the moment
    % DwellInd(1).Mean   = mean(Y); 
    % DwellInd(1).Var    = sum((Y-DwellInd(1).Mean).^2);

    %at the beginning there are no steps and all, data belongs to the same dwell
    %Y is the vertical axis data, T is the horizontal axis data

    tempSIC = NaN*ones(1,length(Y)); %list of SIC values that we later use to decide how to "split the sandwich" 

    for TentativeStepIndex = 2:length(Y)-1 %can't have a step at the first or last point
        %for each point compute the Schwartz Information Criterion score
        %the SIC score corresponding to a putative step at each individual
        %data point. The point with the lowest SIC score is where we "split
        %the sandwich" 

        tempDwellInd(1).Start  = 1;
        tempDwellInd(1).Finish = TentativeStepIndex;
        tempDwellInd(2).Start  = TentativeStepIndex+1;
        tempDwellInd(2).Finish = length(Y);
        tempDwellInd(1).Mean   = NaN;
        tempDwellInd(2).Mean   = NaN;
        tempDwellInd(1).Var    = NaN;
        tempDwellInd(2).Var    = NaN;
        [tempSIC(TentativeStepIndex) ~]= KV_ComputeSIC(Y,TentativeStepIndex,tempDwellInd,1); %use the standard penalty of 1, doesn't really matter here though
    end

    %find the lowest SIC, place a step there
    StepIndex = find(tempSIC==min(tempSIC),1,'last'); %find 

    %this StepIndex is being counted with respect to the start of the FirstDwell
    StepIndex = StepIndex-1+FirstDwell.Start; %in the grand scheme of things
    
    %FirstDwell.Start          remains unchanged
    FirstDwell.Finish        = StepIndex;
    FirstDwell.Mean          = mean(FiltY(FirstDwell.Start:FirstDwell.Finish));
    FirstDwell.DwellLocation = mean(FiltY(FirstDwell.Start:FirstDwell.Finish));
    FirstDwell.StartTime     = FiltT(FirstDwell.Start);
    FirstDwell.FinishTime    = FiltT(FirstDwell.Finish);
    FirstDwell.DwellTime     = range([FirstDwell.StartTime FirstDwell.FinishTime]);
    
    %SecondDwell.Finish         remains unchanged
    SecondDwell.Start         = StepIndex+1;
    SecondDwell.Mean          = mean(FiltY(SecondDwell.Start:SecondDwell.Finish));
    SecondDwell.DwellLocation = mean(FiltY(SecondDwell.Start:SecondDwell.Finish)); %same thing as the mean
    SecondDwell.StartTime     = FiltT(SecondDwell.Start);
    SecondDwell.FinishTime    = FiltT(SecondDwell.Finish);
    SecondDwell.DwellTime     = range([SecondDwell.StartTime SecondDwell.FinishTime]);

end