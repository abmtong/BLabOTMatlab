function CropDataByHand()
% Open a phage trace and let the user crop the trace. This gives us Tstart
% and Tstop - the time limits that define the useful portion of the data.
% This start/stop time will be saved in a file named ***.crop. 
% The start time is written in the first line
% The stop time is wrtitten in the second line
% I re-wrote this function to allow zooming in and panning and made it
% easier to explore the trace
%
% USE: CropDataByHand()
%
% Gheorghe Chistol, 25 May 2011

    %% Load the phages
    AddMainCodePath; %add the old code folder to the path
    global analysisPath PhageTrace; %this is the analysis path
    if isempty(analysisPath) || strcmp(analysisPath,'0')
        disp('Analysis Path is not defined. Use SetAnalysisPath'); return;
    end

    [TraceFile, TracePath] = uigetfile([analysisPath filesep 'phage*.mat'], 'MultiSelect','off','Pick a Phi29 Trace');
    load([TracePath filesep TraceFile]);
    PhageTrace.Time      = stepdata.time;
    PhageTrace.Force     = stepdata.force;
    PhageTrace.Contour   = stepdata.contour;
    PhageTrace.TraceFile = TraceFile;
    PhageTrace.TracePath = TracePath;

    N=10; %for filtering down to 100Hz
    for fc=1:length(PhageTrace.Time)
        PhageTrace.FiltTime{fc}    = FilterAndDecimate(PhageTrace.Time{fc},    N);
        PhageTrace.FiltForce{fc}   = FilterAndDecimate(PhageTrace.Force{fc},   N);
        PhageTrace.FiltContour{fc} = FilterAndDecimate(PhageTrace.Contour{fc}, N);
    end
    
    %% Plot the Data 
    %DefineTraceBoundaries_SetTraceBoundaries(); %Call the functon that will define the Trace Boundaries
    figure('Units','normalized','Position',[0.0066 0.0625 0.9876 0.8685]);
    hold on;
    PhageTrace.MergedFiltTime    = []; %this is a merged Time/Contour vector that is used later for Yaxis limit finding
    PhageTrace.MergedFiltContour = [];
    
    for fc=1:length(PhageTrace.Time)
        PhageTrace.MergedFiltTime    = [PhageTrace.MergedFiltTime     PhageTrace.FiltTime{fc}];
        PhageTrace.MergedFiltContour = [PhageTrace.MergedFiltContour  PhageTrace.FiltContour{fc}];
        plot(PhageTrace.FiltTime{fc},PhageTrace.FiltContour{fc},'g');
    end
    %extend the XLim for more convenient cropping
    XLim = get(gca,'XLim');
    XLim(1) = XLim(1)-0.1*range(XLim);
    set(gca,'XLim',XLim);
    
    set(gca,'Box','on','Units','normalized','Position',[0.0482 0.0650 0.9370 0.8360],'Color','k');
    xlabel('Time (sec)'); 
    ylabel('Tether Length (bp)');
    title(['File: ' PhageTrace.TraceFile '; Define the Left/Right Boundaries']);
    %% Now proceed to creat the GUI and define the crop region
    CropDataByHand_GUI();
end