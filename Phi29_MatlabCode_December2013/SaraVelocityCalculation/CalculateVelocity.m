function CalculateVelocity()
% This function requires *.mat and the corresponding *.crop files. It
% calculates the velocity single or multiple phage traces at once. It was
% written to investigate whether ATP binding is affected in the late stages
% of packaging. All data is saved in the AnalysisFolder\VelocityData\
% The most important saved data are: Velocity (vector), Location (vector)
%                                    and Parameters (structure)
% Please look over the parameters at the beginning of the function to make sure everything is ok.
% Pay attention to MinPauseDur especially. The other parameters are ok.
%
% USE: CalculateVelocity()
%
% Gheorghe Chistol, 13 Oct 2012

    ForceBoundaries   = [7:1:12]; %force intervals, either in 1 or 2 pN intervals is ok
    Band              = 2500; %bandwidth of raw data
    FiltBand          = 50; %filtering for finding pauses (important)
    VelFiltBand       = 25; %filtering for calculating force bins (not too important)
    MinContSpan       = 10; %in bp, a region of data needs to have at least this many basepairs worth of data
    MinNumPts         = 5; %you need more than this many points to get a good linear fit for velocity
    MinPauseDur       = 1; %in sec, the shortest pause duration
    MinSlipSize       = 5; %in bp
    MaxTimeSpan       = 10; %if a feedback cycle is longer than MaxTimeSpan seconds, break it up this helps makes step-finding much faster
    FeedbackCycleTmin = 0.3; %each feedback cycle should contain at least 0.3sec worth of data
    StepFindPenalty   = 3;
    FiltFact          = round(Band/FiltBand); %this is the filtering factor
    VelFiltFact       = round(Band/VelFiltBand); %this is the filtering factor
    
    %% Add the folder where Sic Step-Finding code is to the path
    global analysisPath;    
    PlotOption = 'Plot'; % either 'Plot' or 'NoPlot'
    CurrDir = pwd;
    temp = findstr(CurrDir,filesep); temp = temp(end); %pick the last occurence of '\' or '/'
    addpath([CurrDir(1:temp) 'SicStepFinder']);
    
    %% Select all Phage Traces of interest
    [FileName, FilePath] = uigetfile([ analysisPath filesep 'phage*.mat'], 'MultiSelect', 'on');

    if ~iscell(FileName) %if there is only one file, make it into a cell, for easier processing later
        temp=FileName; clear FileName; FileName{1}=temp; clear temp;
    end

    %% Process one file at a time
    for f = 1:length(FileName)
        %identify the crop file corresponding to the current trace file
        CropFile = [FilePath filesep 'CropFiles' filesep FileName{f}(6:end-4) '.crop']; 

        if ~exist(CropFile,'file') %do not process trace if crop file doesn't exist
            %the Crop *.crop file doesn't exist, skip the corresponding *.pro file
            disp([FileName{f} ' was skipped because it has no crop (*.crop) file']);
        else
            disp([FileName{f} ' is being processed now']);
            temp = load([FilePath filesep FileName{f}]); %load a single specified phage file
            Trace = temp.stepdata; clear temp; %load the data and clear intermediate data

            FID = fopen(CropFile); %open the *.crop file
            Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
            Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
            fclose(FID);
            Data = []; %initialize data structure
            for fc = 1:length(Trace.time) % 'fc' is the index of the feedback cycle
                CropInd = Trace.time{fc}>Tstart & Trace.time{fc}<Tstop; %the points to be included in analysis
                Time    = Trace.time{fc}(CropInd);
                Contour = Trace.contour{fc}(CropInd);
                Force   = Trace.force{fc}(CropInd);
                %remove the NaN entries in Contour
                RemInd = isnan(Contour);
                temp   = sum(RemInd);                
                
                if temp>0
                    Contour(RemInd) = [];
                    Force(RemInd)   = [];
                    Time(RemInd)    = [];
                    disp([num2str(temp) ' NaN points removed']);
                end
                
                if isempty(Time)
                    %if there is no data
                    disp(['Skipping FC#' num2str(fc) ', no data']);
                elseif range(Time)<FeedbackCycleTmin 
                    %if the current feedback cycle is too short, ignore
                    disp(['Skipping FC#' num2str(fc) ', too short']);
                else
                    %if the feedback cycle long enough, analyze
                    FiltTime    = FilterAndDecimate(Time,    FiltFact);
                    FiltContour = FilterAndDecimate(Contour, FiltFact);
                    FiltForce   = FilterAndDecimate(Force,   FiltFact);
                    %DwellInd    = KV_FindSteps(FiltContour, StepFindPenalty);
                    
                    
                    %this will take forever to analyze using SIC if range(FiltTime)>MaxTimeSpan
                    NumFrag = ceil(range(FiltTime)/MaxTimeSpan); %number of fragments
                    IndIncr = round(length(FiltTime)/NumFrag); %index increment for breaking up the trace
                    disp(['Number of fragments = ' num2str(NumFrag)]);
                    for nf = 1:NumFrag
                        tempIndKeep = (1+(nf-1)*IndIncr) : (nf*IndIncr);
                        tempIndKeep = tempIndKeep(tempIndKeep<=length(FiltTime));
                        if ~isempty(tempIndKeep)
                            tempDwellInd = KV_FindSteps(FiltContour(tempIndKeep), StepFindPenalty);
                            if nf==1
                                DwellInd = tempDwellInd;
                            else
                                DwellInd = [DwellInd tempDwellInd]; %merge all the results together
                            end
                        end
                    end
                        
                   
                    ind = length(Data)+1;
                    Data(ind).Time          = Time;
                    Data(ind).Contour       = Contour;
                    Data(ind).Force         = Force;
                    Data(ind).FiltTime      = FiltTime;
                    Data(ind).FiltContour   = FiltContour;
                    Data(ind).FiltForce     = FiltForce;
                    Data(ind).FeedbackCycle = fc;
                    Data(ind).FileName      = FileName{f};
                    Data(ind).FilePath      = FilePath;
                   
                    
                    [Data(ind).Dwells Data(ind).LadderTime Data(ind).LadderContour Data(ind).LadderForce] = ...
                        CalculateVelocity_OrganizeDwellData(DwellInd,Data(ind).FiltTime,Data(ind).FiltForce);

                    [Data(ind).NoPauses Data(ind).Slips Data(ind).Pauses Data(ind).SlipPauseFreeSegments] = ...
                        CalculateVelocity_RemoveSlipsPauses(Data(ind), MinPauseDur, MinSlipSize);
                    %display(length(Data(ind).Slips));
                    
                    PlotSave.FilePath = [Data(ind).FilePath filesep 'SaraPauseCalculation' filesep Data(ind).FileName(1:end-4)]; %FilePath is the same as analysisPath
                    PlotSave.FileName = [Data(ind).FileName(1:end-4) '_fc' num2str(Data(ind).FeedbackCycle) '.png'];
                    
                    Data(ind).Velocity = CalculateVelocity_DivideAndConquer(Data(ind),ForceBoundaries,VelFiltFact,MinContSpan,MinNumPts,PlotOption,PlotSave); %#ok<*AGROW>
                    
                    
                    
                    %save the parameters to the data with clear names
                    Data(ind).Parameters.DataAcquisitionBandwidth           = FiltBand;
                    Data(ind).Parameters.StepFindingFilterBandwidth         = FiltBand;
                    Data(ind).Parameters.StepFindingFilterFactor            = FiltFact;
                    Data(ind).Parameters.StepFindingPenalty                 = StepFindPenalty;
                    Data(ind).Parameters.VelocityCalculationFilterBandwidth = VelFiltBand;
                    Data(ind).Parameters.VelocityCalculationFilterFactor    = VelFiltFact;
                    Data(ind).Parameters.VelocityCalculationForceBoundaries = ForceBoundaries;
                    Data(ind).Parameters.MinimumContourSpan                 = MinContSpan;
                    Data(ind).Parameters.MinimumNumberPoints                = MinNumPts;
                    Data(ind).Parameters.MinimumPauseDuration               = MinPauseDur;
                    Data(ind).Parameters.MinimumSlipSize                    = MinSlipSize;
                    Data(ind).Parameters.MinimumFeedbackCycleDuration       = FeedbackCycleTmin;
                    
                    Data(ind).ProcessingTimeStamp = now;  %so we know when data was processed
                    Data(ind).ProcessingDate      = date;
                end
            end
            
            %save the diagnostics plot
            DiagPlotFilePath = [Data(1).FilePath filesep 'VelocityCalculation'];
            DiagPlotFileName = ['VelocityDiagnostics_' Data(1).FileName(1:end-4) '.png'];
            CalculateVelocity_MoleculeDiagnosticPlot(Data,DiagPlotFilePath,DiagPlotFileName);
            
            %save the results in a velocity calculation file
            SavePath = [Data(ind).FilePath filesep 'VelocityCalculation'];
            SaveFile = ['VelocityResults_' Data(ind).FileName(1:end-4) '.mat'];
            fprintf(['   Saving data to ' SaveFile ' ...' ]);
            save([SavePath filesep SaveFile],'Data');
            fprintf(' done :) \n');
            disp('---------------------------------------');
            clear Data;
            
        end
    end
end 