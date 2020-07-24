function Pauses = DetectPauses(Time, ContourLength, FileName, VelThr, MinPauseDuration, TetherLimit, PlotOption)
% This function detects pauses using treshold VelThr. Vary the threshold as
% needed, depending on the filtering and quality of data. You need to give
% this functions a trace that has been filtered and cropped.
%
% USE: Pauses = DetectPauses(Time, ContourLength, FileName, VelThr,
% MinPauseDuration, TetherLimit, PlotOption)
%
% Gheorghe Chistol, December 11th, 2009
% Gheorghe Chistol, December 19th, 2009

%% Calculate Velocity, identify potential pauses (DPI)
Vel = diff(ContourLength)./diff(Time); %velocity in bp/sec
VPI = find(abs(Vel)<VelThr); %Velocity Pause Index = VPI
DPI = DetectPauses_VPItoDPI(ContourLength,VPI); %convert VelocityPauseIndex to DataPauseIndex

%% Identify Individual pauses based on the DPI
Pauses=DetectPauses_Identify(Time, ContourLength, DPI);
disp(['Preliminary Pauses Detected ' num2str(length(Pauses.Duration))]); %display how many pauses were preliminarily detected

%% Check the slope, if the tentative pause is consistently sloped one way,
% it's probably not a real pause, just a slow translocation
Pauses=DetectPauses_CheckSlope(Time, ContourLength, Pauses, VelThr);

%% Merge neighboring pauses where possible 
Pauses = DetectPauses_Merge(Pauses, Time, ContourLength, VelThr);%merge neighboring pauses, where possible

%% Remove all pauses that are shorter than MinPauseDuration 
% or below the TetherLimit,
Status=1;
i=1;
if ~isempty(Pauses.Duration)
    while Status

        if Pauses.Duration(i) < MinPauseDuration || ...
           Pauses.Location(i) < TetherLimit
            %this pause is too short, remove it
            Pauses.Start(i)       = [];
            Pauses.End(i)         = [];
            Pauses.Duration(i)    = [];
            Pauses.Location(i)    = [];
            Pauses.LocationSTD(i) = [];
            Pauses.Index(i)       = [];
        else
            i=i+1;
        end

        if i>length(Pauses.Duration)
            Status=0; %stop the loop, all pauses removed
        end
    end      
end
disp(['Final Pauses Detected: ' num2str(length(Pauses.Duration))]); %display how many pauses were finally detected

%% Plot the detected pauses at the end 
%PlotOption can be 'none' or 'plot'
if PlotOption=='plot'
    figure;
    plot(Time, ContourLength,'-b'); %plot all data in blue
    hold on;
    %plot the points that have been labeled as part of a pause in red,
    for i=1:length(Pauses.Index);
        X = [Pauses.Start(i) Pauses.End(i)];
        Y = Pauses.Location(i)*[1 1]; %conver from nm to bp
        line(X,Y,'Color','r','LineWidth',3);
        plot(Time(Pauses.Index{i}), ContourLength(Pauses.Index{i}),'.r'); 
    end
    xlabel('Time (sec)');
    ylabel('Tether Length (bp)');
    title([FileName ': Final Pause Detection']);
end