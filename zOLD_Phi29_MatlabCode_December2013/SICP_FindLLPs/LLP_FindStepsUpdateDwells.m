function [DwellInd StepInd] = LLP_FindStepsUpdateDwells(Y,StepInd,DwellInd,i)
% update the location of the dwell given the old StepInd (includes all the
% previously detected steps), the index of the current step i (only one
% step at a time). Y is the vertical axis data
%
% DwellInd(d).Start
% DwellInd(d).Finish
% DwellInd(d).Mean
% DwellInd(d).Var
%
% USE: [DwellInd StepInd] = KV_UpdateDwellCoordinate(Y,StepInd,DwellInd,i)
%
% Gheorghe Chistol, 05 Apr 2011
%
% Making a change. dth dwell ends at point i and d+1th dwell begins at point i as well.
%

if isempty(StepInd)
    %this is the very first step, there will be only two dwells
    StepInd = i;
    DwellInd(1).Start  = 1;
    DwellInd(1).Finish = i;
    DwellInd(1).Mean   = NaN; %since the dwell was updated, the mean is now different, will be calculated by KV_ComputeSIC()
    DwellInd(1).Var    = NaN; %will be computed by KV_ComputeSIC()
    
    DwellInd(2).Start  = i;
    DwellInd(2).Finish = length(Y);
    DwellInd(2).Mean   = NaN;
    DwellInd(2).Var    = NaN;
else
    if i<min(StepInd) %there are no previous steps before the current one
        StepInd            = [i StepInd]; %append the current step at the very beginning of the StepInd
        DwellInd(2:end+1)  = DwellInd; %shift all dwells to the right by one
        DwellInd(1).Finish = i; %where the very first dwell ends
        DwellInd(1).Mean   = NaN;
        DwellInd(2).Start  = i; %where the updated second dwell starts
        DwellInd(2).Mean   = NaN;
    elseif i>max(StepInd) %there are no previous steps after the current one
        StepInd                = [StepInd i]; %append the current step at the very end of the StepInd
        DwellInd(end+1)        = DwellInd(end); %make a copy of the last dwell index
        DwellInd(end-1).Finish = i; %this is where the second to last dwell ends
        DwellInd(end-1).Mean   = NaN;
        DwellInd(end).Start    = i; %this is where the updated last dwell starts
        DwellInd(end).Mean     = NaN;
        %no need to update the start of the second-to-last dwell and the
        %finish of the last dwell since they remain valid
    else %the are previous steps before and after the current step
        k = find(StepInd-i<0,1,'Last');
        %k is the position in StepInd of the Index of the step right before
        %the step at Y(i)
        %stepBef = StepInd(k);   %the index (in Y) of the step right before i
        %stepAft = StepInd(k+1); %the index (in Y) of the step right after i

        StepInd(k+1:end+1) = StepInd(k:end); %shift over
        StepInd(k+1)       = i; %record the current step index, right after the kth previously identified step
        
        d = k+1; %the k-th step corresponds to the d-th dwell
        %d-th dwell effectively breaks in two parts, which become 
        %d-th and (d+1)-th updated dwells
        DwellInd(d+1:end+1) = DwellInd(d:end); %shift over
        DwellInd(d).Finish  = i;
        DwellInd(d).Mean    = NaN;
        DwellInd(d+1).Start = i;
        DwellInd(d+1).Mean  = NaN;
        %no need to update the start of the d-th dwell or the finish of the
        %(d+1)-th dwell
    end
end