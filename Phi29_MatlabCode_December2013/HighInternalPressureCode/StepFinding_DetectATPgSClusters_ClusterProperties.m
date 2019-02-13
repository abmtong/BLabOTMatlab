function [ClusterSpan ClusterDuration] = StepFinding_DetectATPgSClusters_ClusterProperties()
    % Tabulate the ATPgS pause Cluster properties (span and duration) using
    % only the validated clusters. Data is saved in files named
    % "*ResultsKV_DetectATPgSClusters_Main_ValidatedClusters.mat"
    % This function can handle several results files at once.
    %
    % USE: [ClusterSpan ClusterDuration] = StepFinding_DetectATPgSClusters_ClusterProperties()
    %
    % Gheorghe Chistol, 26 July 2011
    
    global analysisPath;
    [DataFile DataPath] = uigetfile([ analysisPath filesep '*_ValidatedClusters.mat'], 'Please select the Validated Cluster Results file','MultiSelect', 'on');
    if ~iscell(DataFile)
        temp=DataFile; clear DataFile; DataFile{1} = temp;
    end
    ClusterSpan     = [];
    ClusterDuration = [];
    
    %load one file at a time
    for df=1:length(DataFile)
        clear PauseClusters;
        load([DataPath filesep DataFile{df}],'PauseClusters');
        for ph=1:length(PauseClusters) %ph is the PhageFile index
            for fc=1:length(PauseClusters{ph}) %fc is the FeedbackCycle index
                if ~isempty(PauseClusters{ph}{fc})
                    for c=1:length(PauseClusters{ph}{fc}) %c is the Cluster index
                        if PauseClusters{ph}{fc}(c).IsValid == 1;
                            ClusterSpan(end+1)     = PauseClusters{ph}{fc}(c).ClusterSpan;
                            ClusterDuration(end+1) = PauseClusters{ph}{fc}(c).ClusterDuration;
                        end
                    end
                end
            end
        end
    end
end