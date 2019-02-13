function CropTraceByHand()
% Open a phage trace and let the user crop the trace. This gives us Tstart
% and Tstop - the time limits that define the useful portion of the data.
% This start/stop time will be saved in a file named ***.crop. 
% The start time is written in the first line
% The stop time is wrtitten in the second line
% I re-wrote this function to allow zooming in and panning and made it
% easier to explore the trace
%
% I use guidata to save/get data to/from the figure. This
% lets us get by without declaring data in a global variable
%
% USE: CropTraceByHand()
%
% Gheorghe Chistol, 15 Feb 2012

    FilterFactor = 10; %filter the data by this factor before plotting
    MaxDnaLength = 10000; %anything longer than that will be ignored
    
    %% Load the phages
    global analysisPath; %this is the analysis path
    
    [Trace.FileName, Trace.FilePath] = uigetfile([analysisPath filesep 'phage*.mat'], 'MultiSelect','off','Pick a Phi29 Trace');
    stepdata = load([Trace.FilePath filesep Trace.FileName],'stepdata');
    stepdata = stepdata.stepdata;
    
    %organize data into the structure "Trace", to use with "guidata" later
    for fc = 1:length(stepdata.time)
        Trace.Time{fc}    = FilterAndDecimate(stepdata.time{fc},    FilterFactor);
        Trace.Force{fc}   = FilterAndDecimate(stepdata.force{fc},   FilterFactor);
        Trace.Contour{fc} = FilterAndDecimate(stepdata.contour{fc}, FilterFactor);
    end
    
    %% Plot the Data 
    figure('Units','normalized','Position',[0.0066 0.0625 0.9876 0.8685]); hold on;
    Trace.MergedTime    = []; %this is a merged Time/Contour vector that is used later for Yaxis limit finding
    Trace.MergedContour = [];
    Trace.MergedForce = [];%A
    
    sp1 = subplot(2,1,1); hold on;
    for fc=1:length(Trace.Time)
        Trace.MergedTime    = [Trace.MergedTime     Trace.Time{fc}   ];
        Trace.MergedContour = [Trace.MergedContour  Trace.Contour{fc}];
        plot(Trace.Time{fc}, Trace.Force{fc},'b');
    end
    sp2 = subplot(2,1,2); hold on;
    for fc=1:length(Trace.Time)
        plot(Trace.Time{fc}, Trace.Contour{fc},'b');
    end        
    linkaxes([sp1, sp2],'x');
    
    %extend the XLim for more convenient cropping
    XLim = get(gca,'XLim');
    XLim(1) = XLim(1)-0.1*range(XLim);
    set(gca,'XLim',XLim);
    
    YLim = get(gca,'YLim');
    if YLim(2) > MaxDnaLength
        YLim(2) = MaxDnaLength;
        set(gca,'YLim',YLim);
    end
    
 %   set(gca,'Box','on','Units','normalized','Position',[0.0482 0.0650 0.9370 0.8360],'Color','w');
    xlabel('Time (sec)'); 
    ylabel('Tether Length (bp)');
    title(['File: ' Trace.FileName '; Define the Left/Right Boundaries']);

    Trace.Boundaries.Left        = [];
    Trace.Boundaries.LeftHandle  = [];
    Trace.Boundaries.Right       = [];
    Trace.Boundaries.RightHandle = [];

    % Check if there already exists a crop file for this trace
    if exist([Trace.FilePath filesep 'CropFiles'],'dir');
        CropFile = [Trace.FilePath filesep 'CropFiles' filesep Trace.FileName(6:end-4) '.crop'];
        if exist(CropFile,'file')
            FID = fopen(CropFile); %open the *.crop file
            Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
            Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
            fclose(FID);
            YLim = get(gca,'YLim');
            PatchX = [Tstart Tstart Tstop Tstop];
            PatchY = [YLim(1) YLim(2) YLim(2) YLim(1)];
            h = patch(PatchX,PatchY,'y'); %plot the range of the previous crop file
            set(h,'FaceAlpha',0.25);
            Trace.Boundaries.Left  = Tstart;
            Trace.Boundaries.Right = Tstop;            
        end
    end
    %axis tight;
    %% Now proceed to creat the GUI and define the crop region
    guidata(gcf,Trace); %save data to the figure
    CropTraceByHand_Gui();
    
end