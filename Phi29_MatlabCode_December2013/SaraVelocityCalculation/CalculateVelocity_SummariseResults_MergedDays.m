function VelSummary = CalculateVelocity_SummariseResults_MergedDays()
% This function is used to look at data from different days that has been collected in the same
% folder.
%
% Gheorghe Chistol, 14 Oct 2012

    ForceBoundaries        = [7 12];
%    TetherLengthBoundaries = [0:1000:5000]; %for 6kb tethers
    TetherLengthBoundaries = [0:1000:9000]; %for 12kb tethers
    VelConfIntThr          = 30;  %if the uncertainty in Vel is more than VelConfIntThr, ignore this datapoint
    MinVelCutoff           = 0; %this one can still be NaN even if MaxVelCutoff is not
    MaxVelCutoff           = NaN; %this one can still be NaN even if MinVelCutoff is not
    MinTimeSpan            = NaN; %this one can be NaN even if MaxTimeSpan is not
    MaxTimeSpan            = NaN; %this one can be NaN even if MinTimeSpan is not
    BootstrapN             = 1000; %number of boostraps used to estimate the velocity confidence interval
    DesiredConfInt         = 0.95; %for boostrap analysis
    
    %normally there is no need to set limits on the TimeSpan, it is taken care by the VelConfIntThr
    
    %% Orgnize the output data structure
    % There will be Nf force ranges defined by the force boundaries. 
    % There will be Nt tether length ranges defined by the tether length boundaries
    % The results (VelocityMean +/- VelocityErr) will be organized in a matrix with Nf rows and Nt
    % columns. Matrix entries with no data will be filled with NaN. TotalTimeSpan is a separate matrix
    % of identical dimensions to VelocityMean that contains the total amt of time spent at a given force
    % range and a given tether length range. TotalContourSpan summarizes the amt of translocated DNA
    % that went into calculating the velocity for a given force range and a given tether length range.

    VelSummary.ForceRangeFmin         = ForceBoundaries(1:end-1);
    VelSummary.ForceRangeFmax         = ForceBoundaries(2:end);
    VelSummary.ForceRangeFmean        = (VelSummary.ForceRangeFmin+VelSummary.ForceRangeFmax)/2;
    VelSummary.TetherLengthRangeLmin  = TetherLengthBoundaries(1:end-1);
    VelSummary.TetherLengthRangeLmax  = TetherLengthBoundaries(2:end);
    VelSummary.TetherLengthRangeLmean = (VelSummary.TetherLengthRangeLmin+VelSummary.TetherLengthRangeLmax)/2;
    VelSummary.VelocityMean           = nan(length(VelSummary.ForceRangeFmean),length(VelSummary.TetherLengthRangeLmean)); %initialize the matrix 
    VelSummary.VelocityErr            = nan(length(VelSummary.ForceRangeFmean),length(VelSummary.TetherLengthRangeLmean));  
    VelSummary.TotalTimeSpan          = nan(length(VelSummary.ForceRangeFmean),length(VelSummary.TetherLengthRangeLmean));  
    VelSummary.TotalContourSpan       = nan(length(VelSummary.ForceRangeFmean),length(VelSummary.TetherLengthRangeLmean));  

    %% Let the user select files
    global analysisPath;
    [FileName, FilePath] = uigetfile([analysisPath filesep 'VelocityResults*.mat'],'MultiSelect','on');
    if ~iscell(FileName)
        temp = FileName; clear FileName;
        FileName{1} = temp; clear temp;
    end

    %% Check if all files have identical force ranges
    % load the first file and remember its force range
    temp = load([FilePath filesep FileName{1}]); Data = temp.Data; clear temp;
    InitialForceBoundaries = Data(1).Parameters.VelocityCalculationForceBoundaries;

    for f = 2:length(FileName)
        temp = load([FilePath filesep FileName{1}]); Data = temp.Data; clear temp;
        CurrentForceBoundaries = Data(1).Parameters.VelocityCalculationForceBoundaries;

        Status = 'Proceed'; %if we find problems, we abort
        if length(CurrentForceBoundaries) ~= length(InitialForceBoundaries)
            Status = 'Abort';
        else %the length of the force boundaries is the same
            if CurrentForceBoundaries ~= InitialForceBoundaries
                Status = 'Abort';
            end
        end

        if strcmp(Status,'Abort')
            disp([FileName{1} ' and ' FileName{f} ' have different force boundaries']);
            disp([FileName{1} ': ' InitialForceBoundaries]);
            disp([FileName{f} ': ' InitialForceBoundaries]);
            disp('Further analysis was aborted :(');
            return; %the function quits prematurely if there is a problem
        end
    end
    disp('All selected files have the same force boundaries');
    disp(InitialForceBoundaries);

    %% Create an aggregate data set with velocity data from all the files
    Aggregate.VelMean      = [];
    Aggregate.VelErr       = []; %basically the 95% confidence interval
    Aggregate.ForceMean    = [];
    Aggregate.TimeSpan     = [];
    Aggregate.ContourMean  = []; %i.e. where along the tether this measurement was made
    Aggregate.ContourSpan  = [];

    for f = 1:length(FileName)
        temp = load([FilePath filesep FileName{f}]); Data = temp.Data; clear temp;
        for fc = 1:length(Data);
            for v = 1:length(Data(fc).Velocity.VelocityValue)
                Aggregate.VelMean(end+1)     = Data(fc).Velocity.VelocityValue(v); %#ok<*AGROW>
                Aggregate.VelErr(end+1)      = range(Data(fc).Velocity.FitConfInt{v}(:,1))/2;
                Aggregate.ForceMean(end+1)   = Data(fc).Velocity.ForceMean(v);
                Aggregate.TimeSpan(end+1)    = Data(fc).Velocity.TimeSpan(v);
                Aggregate.ContourMean(end+1) = Data(fc).Velocity.ContourMean(v);
                Aggregate.ContourSpan(end+1) = Data(fc).Velocity.ContourSpan(v);
            end
        end
    end

    %% Throw away data with very large confidence intervals
    if ~isnan(VelConfIntThr)
        KeepInd = Aggregate.VelErr<VelConfIntThr;
    else
        KeepInd = ones(size(Aggregate.VelMean));
    end
    
    NumThrowAway = sum(~KeepInd); %number of points to throw away 
    if NumThrowAway > 0
        Aggregate.VelMean      = Aggregate.VelMean(KeepInd);
        Aggregate.VelErr       = Aggregate.VelErr(KeepInd);
        Aggregate.ForceMean    = Aggregate.ForceMean(KeepInd);
        Aggregate.TimeSpan     = Aggregate.TimeSpan(KeepInd);
        Aggregate.ContourMean  = Aggregate.ContourMean(KeepInd);
        Aggregate.ContourSpan  = Aggregate.ContourSpan(KeepInd);
        disp(['Threw away ' num2str(NumThrowAway) ' measurements with excessive velocity error']);
    end
    clear KeepInd; %just in case, to avoid confusion if it's used later in a diff context

    %% Throw away data beyond the Velocity range specified with MinVelCutoff & MaxVelCutoff
    if ~isnan(MinVelCutoff) && ~isnan(MaxVelCutoff)
        KeepInd = Aggregate.VelMean>MinVelCutoff & Aggregate.VelMean<MaxVelCutoff;
    elseif ~isnan(MinVelCutoff) && isnan(MaxVelCutoff)
        KeepInd = Aggregate.VelMean>MinVelCutoff;
    elseif  isnan(MinVelCutoff) && ~isnan(MaxVelCutoff)
        KeepInd = Aggregate.VelMean<MaxVelCutoff;
    else %both MinVelCutoff and MaxVelCutoff are NaN, keep all data
        KeepInd = ones(size(Aggregate.VelMean));
    end
    NumThrowAway = sum(~KeepInd); %number of points to throw away 
    if NumThrowAway > 0
        Aggregate.VelMean      = Aggregate.VelMean(KeepInd);
        Aggregate.VelErr       = Aggregate.VelErr(KeepInd);
        Aggregate.ForceMean    = Aggregate.ForceMean(KeepInd);
        Aggregate.TimeSpan     = Aggregate.TimeSpan(KeepInd);
        Aggregate.ContourMean  = Aggregate.ContourMean(KeepInd);
        Aggregate.ContourSpan  = Aggregate.ContourSpan(KeepInd);
        disp(['Threw away ' num2str(NumThrowAway) ' measurements outside velocity range']);
    end
    clear KeepInd; %just in case, to avoid confusion if it's used later in a diff context

    %% Throw away data beyond the TimeSpan range specified with MinTimeSpan & MaxTimeSpan
    if ~isnan(MinTimeSpan) && ~isnan(MaxTimeSpan)
        KeepInd = Aggregate.TimeSpan>MinTimeSpan & Aggregate.TimeSpan<MaxTimeSpan;
    elseif ~isnan(MinTimeSpan) && isnan(MaxTimeSpan)
        KeepInd = Aggregate.TimeSpan > MinTimeSpan;
    elseif  isnan(MinTimeSpan) && ~isnan(MaxTimeSpan)
        KeepInd = Aggregate.TimeSpan < MaxTimeSpan;
    else %both MinTimeSpan and MaxTimeSpan are NaN, keep all data
        KeepInd = ones(size(Aggregate.VelMean));
    end
    
    NumThrowAway = sum(~KeepInd); %number of points to throw away 
    if NumThrowAway > 0
        Aggregate.VelMean      = Aggregate.VelMean(KeepInd);
        Aggregate.VelErr       = Aggregate.VelErr(KeepInd);
        Aggregate.ForceMean    = Aggregate.ForceMean(KeepInd);
        Aggregate.TimeSpan     = Aggregate.TimeSpan(KeepInd);
        Aggregate.ContourMean  = Aggregate.ContourMean(KeepInd);
        Aggregate.ContourSpan  = Aggregate.ContourSpan(KeepInd);
        disp(['Threw away ' num2str(NumThrowAway) ' measurements outside time-span range']);
    end
    clear KeepInd; %just in case, to avoid confusion if it's used later in a diff context

    %% Now put together all data for a given ForceRange and a given TetherLengthRange
    for f = 1:length(VelSummary.ForceRangeFmean) %f is the index for the ForceRange
        Fmin = VelSummary.ForceRangeFmin(f);
        Fmax = VelSummary.ForceRangeFmax(f);
        for t = 1:length(VelSummary.TetherLengthRangeLmean) %t is the index for the TetherLengthRange
            Lmin = VelSummary.TetherLengthRangeLmin(t);
            Lmax = VelSummary.TetherLengthRangeLmax(t);
            KeepInd = Aggregate.ForceMean>Fmin   & Aggregate.ForceMean<Fmax   & ...
                      Aggregate.ContourMean>Lmin & Aggregate.ContourMean<Lmax;
            if sum(KeepInd)>2; %we need more than 1 data point
%                 [f t]
%                 if f==2 && t==6
%                     keyboard
%                 end
                CurrVelocity    = Aggregate.VelMean(KeepInd);
                CurrTimeSpan    = Aggregate.TimeSpan(KeepInd);
                CurrContourSpan = Aggregate.ContourSpan(KeepInd);
                CurrResult      = CalculateVelocity_ConfidenceInterval(CurrVelocity,CurrTimeSpan,BootstrapN,DesiredConfInt);
                VelSummary.VelocityMean(f,t)     = CurrResult(2); %CurrResult = [LowerLimit MostLikelyValue UpperLimit];
                VelSummary.VelocityErr(f,t)      = range(CurrResult)/2;
                VelSummary.TotalTimeSpan(f,t)    = sum(CurrTimeSpan);
                VelSummary.TotalContourSpan(f,t) = sum(CurrContourSpan);
            end
            clear KeepInd CurrResult; %to avoid confusion down the line
        end
    end
end