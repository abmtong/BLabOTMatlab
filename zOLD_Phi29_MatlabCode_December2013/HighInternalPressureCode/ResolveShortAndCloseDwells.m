function [Dwells Status] = ResolveShortAndCloseDwells(PhageData, Dwells, Nmin, MinStep, FeedbackCycle)
% This function takes in the dwells as identified by the Ttest and the
% Binomial analysis, then it identifies the very short dwells (fewer points
% than Nmin) and tries to incorporate them into the nearest neighbor
% (nearest by mean). In addition, this function looks if there are any
% dwells that are too close to each other (by mean) and merges them if they
% are closer than MinStep. At the end, it gets rid of very short dwells
% right at the beginning or at the end of the subtrace (when the feedback
% kicked in). Status can be either 'Merged' or 'Nothing'. Merged means that
% some dwells were merged. Nothing means that nothing else can be merged,
% so it doesn't make sense to continue.
%
% Use: [Dwells Status] = ResolveShortAndCloseDwells(PhageData, Dwells, Nmin, MinStep, FeedbackCycle)
%
% Gheorghe Chistol, 25 Oct 2010

%% Getting Rid of the Dwells Separated by Very Small Step Sizes (Smaller than MinStep)
Status = 'Nothing'; %status refers to cleaning up data, merging dwells that are too close to each other or dwells that are too short
%the other Status calue can be Status='Merged';
i=1; %initialize the counter 
while i<=length(Dwells.mean) %go through the updated dwells, merge dwells going forward
    %DeltaNext is the mean difference of the current and the next dwell
    %DeltaPrev is the mean difference of the current and the previous dwell
    if i==1 %the very first dwell
        DeltaPrev = 1e5; %there is no prev dwell, set a giant number
    else
        DeltaPrev = abs(Dwells.mean(i)-Dwells.mean(i-1)); %take abs value
    end
    
    if i==length(Dwells.mean) %the very last dwell
        DeltaNext = 1e5; %there is no next dwell, set a giant number
    else
        DeltaNext = abs(Dwells.mean(i)-Dwells.mean(i+1)); %take abs value
    end

    if (DeltaNext<=MinStep) %if the next dwell is too close, proceed to merging
        %check if the previous dwell is too close. If both the previous dwell
        %and the next dwell are too close, you have to pick the one that's
        %closer and merge the current dwell with that one
        if (DeltaPrev<=MinStep) && (DeltaPrev<DeltaNext)
            %this means that the previous dwell is too close and it makes more
            %sense to merge the current dwell with the previous one
            Status='Merged';
            temp = PhageData.contourFiltered{FeedbackCycle}(Dwells.start(i-1):Dwells.end(i)); 
            %temp: contour length data from the trace corresponding to the merged dwell
            Dwells.start(i)  = []; %the current dwell was merged with the previous one
            Dwells.end(i-1)  = []; %remove the end of the prev dwell, since it has been merged
            Dwells.mean(i)   = []; %delete the mean for the curr dwell
            Dwells.std(i)    = []; %delete the std for the curr dwell
            Dwells.Npts(i)   = []; %delete the Npts for the curr dwell        
            Dwells.mean(i-1) = mean(temp); %update values based on saved contour data
            Dwells.std(i-1)  = std(temp);  
            Dwells.Npts(i-1) = length(temp); 
            %the counter "i" remains unchanged due to merging with prev dwell
        else
            %merge the current dwell with the next one
            Status='Merged';
            temp = PhageData.contourFiltered{FeedbackCycle}(Dwells.start(i):Dwells.end(i+1)); 
            %temp: contour length data from the trace corresponding to the merged dwell
            Dwells.start(i+1)= []; %the next dwell was merged with the current one
            Dwells.end(i)    = []; %remove the end of the current dwell, since it has been merged
            Dwells.mean(i+1) = []; %delete the mean for the next dwell
            Dwells.std(i+1)  = []; %delete the std for the next dwell
            Dwells.Npts(i+1) = []; %delete the Npts for the next dwell        
            Dwells.mean(i)   = mean(temp); %update values based on saved contour data
            Dwells.std(i)    = std(temp);  
            Dwells.Npts(i)   = length(temp); 
            i=i+1; %move to the next dwell
            %disp('Too close to the next dwell');
        end
    elseif (DeltaPrev<=MinStep) %if the previous step is too close, proceed to merging
        Status='Merged';
        temp = PhageData.contourFiltered{FeedbackCycle}(Dwells.start(i-1):Dwells.end(i)); 
        %temp: contour length data from the trace corresponding to the merged dwell
        Dwells.start(i)  = []; %the current dwell was merged with the previous one
        Dwells.end(i-1)  = []; %remove the end of the prev dwell, since it has been merged
        Dwells.mean(i)   = []; %delete the mean for the curr dwell
        Dwells.std(i)    = []; %delete the std for the curr dwell
        Dwells.Npts(i)   = []; %delete the Npts for the curr dwell        
        Dwells.mean(i-1) = mean(temp); %update values based on saved contour data
        Dwells.std(i-1)  = std(temp);  
        Dwells.Npts(i-1) = length(temp); 
        %the counter "i" remains unchanged due to merging with prev dwell
        %disp('Too close to the prev dwell');
    else %if the dwell has the proper duration, keep it unchanged
        i=i+1; %move over to the next dwell and repeat the procedure
    end
end

%% Getting Rid of the Short Dwells (both forward and backward)
i=1; %initialize the counter
while i<=length(Dwells.mean) %go through each dwell and check its duration going
    if Dwells.Npts(i)<Nmin %if the dwell is too short
        %Dwells.Npts(i)
        %DeltaPrev is the mean difference of the current and the previous dwell
        %DeltaNext is the mean difference of the current and the next dwell
        
        if i==1 %the very first dwell
            DeltaPrev = 1e5; %random large number, there is no previous dwell
        else
            DeltaPrev = abs(Dwells.mean(i)-Dwells.mean(i-1)); %take abs value
        end
        
        if i==length(Dwells.mean) %the very last dwell
            DeltaNext = 1e5; %there is no next dwell, set a giant number
        else
            DeltaNext = abs(Dwells.mean(i)-Dwells.mean(i+1)); %take abs value
        end
        
        if (DeltaNext<=DeltaPrev) %if the next dwell is closer
             Status='Merged';
             %merge the current dwell with the next dwell
             temp = PhageData.contourFiltered{FeedbackCycle}(Dwells.start(i):Dwells.end(i+1)); 
             %temp: contour length data from the trace corresponding to the merged dwell
             Dwells.start(i+1) = []; %delete the start of the next dwell since it's incorporated into the current dwell
             Dwells.end(i)     = []; %delete the end of the current dwell, since it's being merged with the next dwell
             Dwells.mean(i+1)  = []; %kill the mean for the next dwell since it is being incorporated into the current dwell
             Dwells.std(i+1)   = []; %kill the std for the next dwell since it is being incorporated into the current dwell
             Dwells.Npts(i+1)  = []; %kill the Npts for the next dwell since it is being incorporated into the current dwell             
             Dwells.mean(i)    = mean(temp); %calculate the values based on the saved contour data for both dwells
             Dwells.std(i)     = std(temp); 
             Dwells.Npts(i)    = length(temp); 
             %disp('Short Dwell: Next Dwell is Closer');
             i=i+1; %go to the next one
        else %if the previous dwell is closer
             %merge the current dwell with the previous dwell
             if i~=1
                 Status='Merged';
                 temp = PhageData.contourFiltered{FeedbackCycle}(Dwells.start(i-1):Dwells.end(i)); 
                 %temp: contour length data from the trace corresponding to the merged dwell
                 Dwells.start(i)   = []; %delete the start of the current dwell since it's merged with the previous one
                 Dwells.end(i-1)   = []; %delete the end of the previous dwell, since it's being merged with the current dwell
                 Dwells.mean(i)    = []; %kill the mean for the current dwell since it is being merged with the previous one
                 Dwells.std(i)     = []; %kill the std for the current dwell since it is being merged with the previous one
                 Dwells.Npts(i)    = []; %kill the Npts for the current dwell since it is being merged with the previous one
                 Dwells.mean(i-1)  = mean(temp); %calculate the values based on the saved contour data for both dwells
                 Dwells.std(i-1)   = std(temp); 
                 Dwells.Npts(i-1)  = length(temp);
                 %the counter "i" remains the same, since we liquidated the "i"th dwell
                 %disp('Short Dwell: Prev Dwell is Closer');
             end
        end
    else %if the dwell has the proper duration, keep it unchanged
        i=i+1; %move over to the next dwell and repeat the procedure
    end
end

%% Calculate the Stepsize
Dwells.StepSize=[]; %clean it up first
for i=1:length(Dwells.mean)-1
    Dwells.StepSize(i)=Dwells.mean(i)-Dwells.mean(i+1);
    %there are N dwells and only N-1 steps
end