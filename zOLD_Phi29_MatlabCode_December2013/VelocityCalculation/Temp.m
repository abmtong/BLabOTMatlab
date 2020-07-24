        FiltTrace.File=Trace.file; %keep the filename
        %go through each subtrace and filter it
        Contour = []; %unified data - one vector for the entire trace
        Force = []; %unified force - one vector for the entire trace
        Time    = []; %unified time - one vector for the entire trace
        for n=1:length(Trace.time)
            FiltTrace.Time{n} = FilterAndDecimate(Trace.time{n}, N); %filter the time and the other important values
            FiltTrace.Contour{n} = FilterAndDecimate(Trace.contour{n}, N);
            FiltTrace.Force{n} = FilterAndDecimate(Trace.force{n}, N);
            
            Time    = [Time    FiltTrace.Time{n}];
            TempSize=size(FiltTrace.Contour{n});
            if TempSize(1)==1
                Contour = [Contour FiltTrace.Contour{n}]; %#ok<*AGROW>
                Force   = [Force   FiltTrace.Force{n}];
            else
                Contour = [Contour FiltTrace.Contour{n}']; %#ok<*AGROW>
                Force   = [Force   FiltTrace.Force{n}'];
            end
        end
                
        %% Go through each subtrace and break ip up into smaller fragments.
        %Fit a straight line through those fragments and save the vel data
        Vel.Velocity = []; %velocity value
        Vel.Location = []; %location where velocity was measured
        Vel.LocStart = [];
        Vel.LocEnd   = [];
        Vel.Force    = []; %the average force across the segment
        Vel.Segment  = []; %the length of the segment across which the velocity was calculated (in bp)
        
        Ind = 1:length(Time); %total index of the time vector
        Ind(Time>Tstop)=[]; %remove the points outside the time crop region
        Ind(Time<Tstart)=[]; %remove the points outside the time crop region
        Time    = Time(Ind); %cropped time vector
        Contour = Contour(Ind); %cropped contour vector
        Force   = Force(Ind); %cropped force vector
        %% We break up the trace into VelWinLength fragments and calculate the velocity on each of those fragments
        
        Time(isnan(Contour))    = [];
        Contour(isnan(Contour)) = [];
        
        FinishL = Contour(end); %we start at the very end of the trace since we care most about the stuff at the end
        StartL  = FinishL+VelWinLength; %we define the window with StartL:FinishL
        %FinishL
        %StartL
        while StartL < Contour(1) %as long as we're staying within the cropped part of the trace
            Ind=1:length(Contour); %complete index of the cropped contour vector
            KeepFromBelow=Contour>FinishL;
            KeepFromAbove=Contour<StartL;
            Keep = KeepFromAbove.*KeepFromBelow;
            Remove = ~Keep;
            
            Ind(Remove)=[];
            %length(Ind)
            
            if ~isempty(Ind)
                %calculate the velocity with a simple division, I tried doing a
                %linear fit but there's not much of a difference between the two
                if length(Ind)>1
                    Vel.Velocity(end+1) = (Contour(Ind(1))-Contour(Ind(end)))/(Time(Ind(1))-Time(Ind(end)));
                    Vel.Location(end+1) = mean(Contour(Ind)); %location where velocity was measured
                    Vel.LocStart(end+1) = max(Contour(Ind));
                    Vel.LocEnd(end+1)   = min(Contour(Ind));
                    Vel.Force(end+1)    = mean(Force(Ind)); %force where velocity was measured
                    Vel.Segment(end+1)  = abs((Contour(Ind(1))-Contour(Ind(end)))); %we need a positive value here
                    %disp(num2str(Vel.Velocity(end)));
                end
            end
            %define the new Start:Finish limits for the next calculation
            FinishL  = StartL; %what used to be the start is now the finish
            StartL   = FinishL+VelWinLength; %adjust the start accordingly
        end
        %% Find the Pauses and remove the velocity measurements that contain the pauses
        AnalyzeInd=Contour>TetherLimit; %we only want to find pauses here
        if ~isempty(AnalyzeInd)
            Pauses = DetectPauses(Time, Contour, File{i}, VelThr, MinPauseDur, TetherLimit,'plot');
            for p=1:length(Pauses.Duration) % go through all pauses
                v=1; VelRemoveStatus=1;
                while VelRemoveStatus %go through all velocity measurements
                    if Vel.LocStart(v) > Pauses.Location(p) && ...
                       Vel.LocEnd(v)   < Pauses.Location(p)
                       %this velocity measurement window contains a pause,
                       %discard this velocity measurement
                       Vel.Velocity(v)=[];
                       Vel.Location(v)=[];
                       Vel.LocStart(v)=[];
                       Vel.LocEnd(v)  =[];
                       Vel.Force(v)   =[];
                       Vel.Segment(v) =[];
                       disp('1 Velocity measurement discarded due to a pause');
                    else 
                        v=v+1; %this velocity measurement is ok, look at the next one
                    end
                    if v>length(Vel.Velocity)
                        VelRemoveStatus=0; %stop the loop
                    end
                end
            end
        end
        %% Save the Velocity Data in a separate file in a separate folder
        Folder = [analysisPath '\' 'VelocityData'];
        if ~exist(Folder,'dir') %if this folder doesn't exist, create it
            mkdir(Folder); %create it
        end        
        
        FileMAT = [Folder '\' File{i}(1:end-4) '_velocity.mat'];
        %save (FileMAT, 'Trace','FiltTrace','Vel','Parameters'); %save data to MAT file
        save (FileMAT, 'Time','Contour','Vel','Parameters'); %save data to MAT file
        disp(['Saved file ' FileMAT ]); %show message in terminal
        
        %% Plot the Velocity Histogram for the entire trace
        if strcmp(PlotOption,'plot')
            HistBins=HistLowerLim:HistBinWidth:HistUpperLim;
            figure; hist(Vel.Velocity,HistBins);
            set(gca,'XLim',[HistLowerLim HistUpperLim]);
            set(gca,'YLimMode','auto');
            title(File{i});
            % Plot Velocity versus Location
            figure; plot(Vel.Location, Vel.Velocity,'.b');
            xlabel('Location (bp)'); ylabel('Velocity (bp/sec)');
            title(File{i});
        end
        
