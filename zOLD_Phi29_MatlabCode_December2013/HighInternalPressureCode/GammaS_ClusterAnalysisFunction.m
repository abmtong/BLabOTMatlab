function Cluster = GammaS_ClusterAnalysisFunction(FinalDwells,FileIndex,FeedbackCycleIndex,Tmin,Lmin)
% This function identifies gammaS induced clusters and calculates their
% duration and span. This particular function is standalone, intended to be
% used with StepFinding functions and help visualize gammaS clusters on
% StepFinding figures;
%
% Cluster.Duration = ClusterDuration;
% Cluster.Span     = ClusterSpan;
% Cluster.Dwells   = ClusterDwells;
% Cluster.Steps    = ClusterSteps;
% Cluster.StartTime = ClusterStartTime;
% Cluster.StartLocation = ClusterStartLocation;
%
% USE: [ClusterDuration ClusterSpan ClusterStartTime ClusterStartLocation] = ...
%         GammaS_ClusterAnalysisFunction(FinalDwells,FileIndex,FeedbackCycleIndex,Tmin,Lmin)
%
% Gheorghe Chistol, 26 Jan 2011

%loop through all the dwells and look for 
%a: consecutive dwells longer than 0.5sec
%b: dwells longer than 0.5 sec that are separated by 12bp or less
%c: individual dwells longer than 0.5sec that don't satisfy a&b

if nargin==3
    %the user didn't specify Tmin and Lmin for GammaS cluster detection
    Tmin=0.5; %0.5sec
    Lmin=12;  %12 bp
end

ClusterDuration=[];
ClusterSpan=[];
ClusterStartTime=[]; %measured with respect to the start of the current feedback trace
ClusterStartLocation=[]; %measured with respect to the start of the current feedback trace
ClusterDwells = {}; %the list of all the dwells that belong to a cluster
ClusterSteps = {}; %the list of all steps that belong to a cluster
%the dwell-times and dwell-locations for the current feedback trace
Bandwidth          = FinalDwells{FileIndex}{FeedbackCycleIndex}.Band;  
tempDwellTime      = FinalDwells{FileIndex}{FeedbackCycleIndex}.DwellTime; 
tempDwellLocation  = FinalDwells{FileIndex}{FeedbackCycleIndex}.DwellLocation;
tempStepSize       = FinalDwells{FileIndex}{FeedbackCycleIndex}.StepSize;  
%tempDwellStartTime = FinalDwells{FileIndex}{FeedbackCycleIndex}.start./Bandwidth;
%tempDwellEndTime   = FinalDwells{FileIndex}{FeedbackCycleIndex}.end./Bandwidth;
%tempNpts           = FinalDwells{FileIndex}{FeedbackCycleIndex}.Npts;

CD=1;

while CD<length(tempDwellTime) %CD is the index of the Current Dwell
   if tempDwellTime(CD)>Tmin %the current dwell is caused by GammaS
       %mark the StartTime and StartLocation
       if CD==1
           %the cluster starts with the very first dwell in the fedback cycle
           ClusterStartTime(end+1)     = 0;
           ClusterStartLocation(end+1) = 0;
       else
           ClusterStartTime(end+1)     = sum(tempDwellTime(1:CD-1))+(CD-1)/Bandwidth; %relative to the start of the trace
           ClusterStartLocation(end+1) = sum(tempStepSize(1:CD-1));  %relative to the start of the trace
       end
         
       Status = 'Continue'; %the default, to get the while loop going
       currentClusterDuration = tempDwellTime(CD)+1/Bandwidth;
       currentClusterSpan     = -tempStepSize(CD); %the step size after the current dwell
       LD = CD; %last dwell that satisfied the gS cluster condition

       while strcmp(Status,'Continue')
           %the search for the end of the cluster is still on
           %find all dwells within Lmin of the last dwell that satisfied the gS cluster condition
           NearbyDwellInd=find(tempDwellLocation<tempDwellLocation(LD)+Lmin & tempDwellLocation>tempDwellLocation(LD)-Lmin);
           % tempDwellLocation<tempDwellLocation(LD)+Lmin condition takes
           % care of backtracks
           temp = tempDwellTime(NearbyDwellInd); %#ok<*FNDSB> %the list of dwelltimes of nearby dwells
           LongDwellInd = temp>Tmin;
           NearbyLongDwellInd = NearbyDwellInd.*LongDwellInd;
           %[CD LD]
           %NearbyLongDwellInd
           %NearbyLongDwellInd 
           if sum(NearbyLongDwellInd)>0 && max(NearbyLongDwellInd)>LD
               %we now have a dwell that is longer than Tmin within the Lmin distance from the current long dwell
               %the second statement was added to avoid going into infinite
               %loops due to backtracks (happened before). The second
               %statement ensures the search flows forward at all times
               LD=max(NearbyLongDwellInd); %last long gS dwell in the NearbyLongDwell set
               currentClusterDuration = sum(tempDwellTime(CD:LD))+(LD-CD+1)/Bandwidth;	
               if LD<length(tempDwellTime)
                   currentClusterSpan     = sum(-tempStepSize(CD:LD)); %the step size after the current dwell
               else %deal with the very last dwell, we don't have a corresponding step measurement, give it 10bp of stepsize
                   currentClusterSpan     = sum(-tempStepSize(CD:LD-1)); %the step size after the current dwell
               end
           else
               %we have reached the end of the cluster, terminate cluster
               ClusterDuration(end+1) = currentClusterDuration;
               ClusterSpan(end+1)     = currentClusterSpan;
               ClusterDwells{end+1}   = tempDwellTime(CD:LD);
               if LD==length(tempDwellTime)
                   ClusterSteps{end+1} = -tempStepSize(CD:LD-1); %convert from negative to positive steps
               else
                   ClusterSteps{end+1} = -tempStepSize(CD:LD); %convert from negative to positive steps
               end
               CD=LD+1;
               Status='Stop'; %no need to continue the current while loop
               currentClusterDuration = 0; %reset value
               currentClusterSpan     = 0; %reset value
           end
       end
   else
       %no cluster was found, look for clusters starting at the next dwell
       CD=CD+1; %nothing interesting happened, move on to the next dwell
   end
   %length(tempDwellTime)
end
Cluster.Duration = ClusterDuration;
Cluster.Span     = ClusterSpan;
Cluster.Dwells   = ClusterDwells;
Cluster.Steps    = ClusterSteps;
Cluster.StartTime = ClusterStartTime;
Cluster.StartLocation = ClusterStartLocation;