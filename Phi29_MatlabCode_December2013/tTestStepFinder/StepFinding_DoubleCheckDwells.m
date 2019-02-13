function Dwells=StepFinding_DoubleCheckDwells(Data,Dwells)
% This function looks for inconsistencies in the dwell structure and
% removes them. This includes for example dwells with zero duration.
%
% USE: Dwells=StepFinding_DoubleCheckDwells(Dwells)
%
% Gheorghe Chistol, 16 Mar 2011

%Check the Dwell durations, if there are dwells with zero
%duration, remove them, update the StepSize and other values accordingly
RemoveIndex = find(Dwells.Npts==1); %index of the dwells that need to be removed
for ri=1:length(RemoveIndex)
    s=RemoveIndex(ri);
    if s>1
       Dwells.end(s-1)=Dwells.start(s); %the current dwell, "s" will be removed, adjust the previous dwell accordingly
    else
        Dwells.start(s+1)=Dwells.start(s); %in case the very first dwell has a zero duration
    end
end

Dwells.start(RemoveIndex)=[]; %remove the data corresponding to those zero-duration dwells
Dwells.end(RemoveIndex)=[]; %remove the data corresponding to those zero-duration dwells
disp(['...' num2str(length(RemoveIndex)) ' zero-duration Dwells removed']);

%----- Recalculate the remaining parameters based on start & end values
Dwells.Npts          = []; %#ok<*AGROW>
Dwells.mean          = [];
Dwells.std           = [];
Dwells.StepSize      = [];
Dwells.StepLocation  = [];
Dwells.DwellTime     = [];
Dwells.DwellLocation = [];

for s=1:length(Dwells.start)
    ContData = Data.FilteredContour(Dwells.start(s):Dwells.end(s)); %contour data
    TimeData = Data.FilteredTime(Dwells.start(s):Dwells.end(s)); %time data
    Dwells.Npts(s)          = length(ContData);
    Dwells.mean(s)          = mean(ContData);
    Dwells.std(s)           = std(ContData);
    Dwells.DwellTime(s)     = TimeData(end)-TimeData(1);
    Dwells.DwellLocation(s) = mean(ContData); %same thing as mean                    
end

for s=1:length(Dwells.mean)-1 %we can't calculate the step-size after the last dwell
    Dwells.StepSize(s)     = Dwells.mean(s+1)-Dwells.mean(s);
    Dwells.StepLocation(s) = (Dwells.mean(s+1)+Dwells.mean(s))/2; %where along the substrate did this step occur?
end