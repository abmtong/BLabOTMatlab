function Pauses=DetectPauses_Identify(Time, ContourLength, DPI)
% this function identifies individual pauses based on the DataPauseIndex,
% i.e. DPI. This is a sub-routine for DetectPauses.m
%
% USE: Pauses=DetectPauses_Identify(Time, ContourLength,bDPI)
%
% Gheorghe Chistol, 28 Aug 2010

%Initialize the "Pauses" data structure, make it empty
Pauses.Start=[]; Pauses.End=[]; Pauses.Duration=[]; Pauses.Index=[]; 
Status=0; %the initial status of the pause search

%Status for "JustStartedTheForLoop" is 0
%Status for "ProcessingPause" is 1
%Status for "FinishedProcessingPause" is -1

%'i' is a dummy counter, a way to index things
for i=1:(length(DPI)-1) %go through the red points, if there are consecutive red points, this means they belong to the same pause    
    if (Status==-1 | Status==0); %if you finished the prev pause OR you just started , then this must be a new pause
        if DPI(i+1)-DPI(i)==1 
            %they belong to the same pause
            %mark the start of the current pause, append to existing data
             Pauses.Start = [Pauses.Start Time(DPI(i))];
             Pauses.Index{end+1} = DPI(i); %add a new entry to the Index section of Pauses
             Status = 1; %we are currently processing a pause, Status set to 1
             %disp(['Found Pause Start @' num2str(Pauses.Start(end))]);
        end
    else
        %the Status must be 1, we're currently processing a pause
        if DPI(i+1)-DPI(i)>1
            %we found the end of the pause
            Pauses.End = [Pauses.End Time(DPI(i))]; %mark the end of the pause
            Pauses.Index{end} = [Pauses.Index{end}:DPI(i)]; %this is the span of the pause, in terms of trace index
            CurrentDuration = Pauses.End(end)-Pauses.Start(end); %the duration of the pause we just finished processing, temporary variable
            Pauses.Duration = [Pauses.Duration CurrentDuration]; %append the current duration to the list of existing durations 
            %we now finished processing the current pause, so update status
            Status=-1; %finished with the current pause, status is -1
            %disp(['Found Pause End @' num2str(Pauses.End(end))]);
%            disp(['Status is ' num2str(Status)]);
        end
    end
    
    %deal with the very last point, special case
    if i==length(DPI)-1 %we're at the second to last point
       if DPI(i+1)-DPI(i)==1 %the second to last point and the last point belong to the same pause
            if Status==1 %we were in the middle of a pause
               %we found the end of the last pause
                Pauses.End        = [Pauses.End Time(DPI(i+1))]; %mark the end of the pause
                Pauses.Index{end} = [Pauses.Index{end}:DPI(i+1)]; %this is the span of the pause, in terms of trace index
                CurrentDuration   = Pauses.End(end)-Pauses.Start(end); %the duration of the pause we just finished processing, temporary variable
                Pauses.Duration   = [Pauses.Duration CurrentDuration]; %append the current duration to the list of existing durations 
                %disp(['Found Pause End @' num2str(Pauses.End(end))]);
                %we now finished processing the last pause, we finished
            else
                %Status must be -1 right now, so we just found another
                %pause, consisting of only 2 points
                Pauses.Start      = [Pauses.End Time(DPI(i))  ]; %mark the start of the pause
                Pauses.End        = [Pauses.End Time(DPI(i+1))]; %mark the end of the pause
                Pauses.Index{end} = [Pauses.Index{end}:DPI(i+1)]; %this is the span of the pause, in terms of trace index                
                Status = -1; %finished with the current pause, status is -1
                CurrentDuration   = Pauses.End(end)-Pauses.Start(end); %the duration of the pause we just finished processing, temporary variable
                Pauses.Duration   = [Pauses.Duration CurrentDuration]; %append the current duration to the list of existing durations 
                %disp(['Found Pause Start @' num2str(Pauses.Start(end))]);
                %disp(['Found Pause End @' num2str(Pauses.End(end))]);
                %we now finished processing the last pause, we finished
            end
       end
    end
%                disp(['Status is ' num2str(Status)]);
end

%% Once all the pauses have been detected, go and calculate the Pause Location and LocationSTD
Pauses.Location = []; %location on the DNA
Pauses.LocationSTD = []; %uncertainty in the location due to STD

%go through each pause and calculate location/STD
for i=1:length(Pauses.Duration)
    Pauses.Location(i)    = mean(ContourLength(Pauses.Index{i})); %calculate location of the pause along the DNA
    Pauses.LocationSTD(i) =  std(ContourLength(Pauses.Index{i})); %calculate location uncertainty of the pause along the DNA
end