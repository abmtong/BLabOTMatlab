function Pauses = DetectPauses_Merge(Pauses, Time, ContourLength, VelThr)
% This function merges two consecutive pauses if the two pauses should in
% fact be a single pause. This is done in iterations, until no more pauses
% can be merged. This is a subroutine for DetectPauses.m
%
% USE: Pauses = DetectPauses_Merge(Pauses, Time, ContourLength, VelThr)
%
% Gheorghe Chistol, 28 Aug 2010

%% See if consecutive pauses can be merged into a single pause
Status = 'merged'; %initial status gives us a go to try to unify pauses
while Status=='merged'
    UpdatedPauses.Start=[]; UpdatedPauses.End=[]; %blank structure
    UpdatedPauses.Duration=[]; UpdatedPauses.Location=[]; %blank structure
    UpdatedPauses.LocationSTD=[]; UpdatedPauses.Index=[]; %blank structure
    
    if length(Pauses.Duration)<1
        Status='failed'; %can't possibly merge 1 or 0 pauses
    end
    
    i=1;
    while i<length(Pauses.Duration)
        Status = 'failed'; %in case we do merge a pause sometime during the cycle, the Status will change to 'merged' and everything will be okay
        %check if pause i and i+1 could possibly be a single pause
        IndPause1  = Pauses.Index{i};   %index of the first pause
        IndPause2  = Pauses.Index{i+1}; %index of the second pause
        IndBetween = Pauses.Index{i}(end)+1:Pauses.Index{i+1}(1)-1; %index of the points in between the two pauses
        IndTotal   = Pauses.Index{i}(1):Pauses.Index{i+1}(end); %index of pause1, pause2 and points in between
        %look at Pause1+Pause2+InBetween
        x = Time(IndTotal);        %time span
        y = ContourLength(IndTotal); %length span, in basepairs
        p = polyfit(x,y,1); %fit the data to a straight line
        Slope = p(1); %the slope of the data. If the slope is small enough, we got ourselves a pause
        
        
%        if abs(Slope)<=VelThr/sqrt(length(IndTotal));
        DeltaL=abs(Pauses.Location(i)-Pauses.Location(i+1)); %the difference in Pause1 and Pause2 location
        DeltaT=Pauses.Start(i+1)-Pauses.End(i); %the time between Pause1 and Pause2
        STDBetween  = std(ContourLength(IndBetween)); %standard dev for Pause1+Pause2+InBetween
        STDPause1 = Pauses.LocationSTD(i); %standard dev for Pause1  
        STDPause2 = Pauses.LocationSTD(i+1); %standard dev for Pause2
        %if the velocity between the two pauses is small enough, the two
        %pauses can be merged. The SQRT(N) is neccesary to penalize long DeltaT
        %if StandardDev of InBetween is too large, can't merge them
        if DeltaL/DeltaT<VelThr/sqrt(length(IndBetween)) && STDBetween<(STDPause1+STDPause2)
            
            Status = 'merged'; %succesful merging of two pauses
            UpdatedPauses.Index{end+1} = IndTotal; %the two pauses and the in-between are merged
            if i==length(Pauses.Duration)-2 %if this is the 3rd to last pause, having been merged with the 2nd to last pause
               UpdatedPauses.Index{end+1} = Pauses.Index{end}; %the last pause remains a single pause
            end
            i=i+2; %two consecutive pauses have been merged, skip one step
            %disp('Merged a pause');
        else 
            UpdatedPauses.Index{end+1} = IndPause1; %the i-th pause remains a single pause
            if i==length(Pauses.Duration)-1 %if this is the second to last pause
               UpdatedPauses.Index{end+1} = IndPause2; %the last pause remains a single pause
            end
            i=i+1;            
            %disp('Failed to merge a pause');
        end
    end
       
    if ~isempty(UpdatedPauses.Index)
        for i=1:length(UpdatedPauses.Index)
            %fill in the blanks for UpdatePauses
            UpdatedPauses.Start(i)       = Time(UpdatedPauses.Index{i}(1)   ); 
            UpdatedPauses.End(i)         = Time(UpdatedPauses.Index{i}(end) );
            UpdatedPauses.Duration(i)    = UpdatedPauses.End(i)-UpdatedPauses.Start(i);
            UpdatedPauses.Location(i)    = mean(ContourLength(UpdatedPauses.Index{i}));
            UpdatedPauses.LocationSTD(i) = std(ContourLength(UpdatedPauses.Index{i}));
        end
        Pauses = UpdatedPauses; %substitute UpdatedPauses for pauses
    else
        Status='failed'; %no need to continue this process of merging, because there is only one pause left
    end
end