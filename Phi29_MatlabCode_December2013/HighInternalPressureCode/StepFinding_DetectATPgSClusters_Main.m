function StepFinding_DetectATPgSClusters_Main
    % Load one or more stepfinding Results file(s) and analyze them to
    % detect and quantify ATPgS clusters. It will plot each individual
    % feedback trace and save it as a PNG or a FIG file.
    %
    % Gheorghe Chistol, 26 July 2011
    
    global analysisPath;
    
    % Set the parameters
    MinPause      = 0.5; %minimum pause to be part of a GammaS cluster
    MaxSeparation = 20;  %maximum separation between two long pauses that belong to the same GammaS cluste    
    
    clear PauseClusters;
    % select the step-finding-results file manually
    [ResultsFiles ResultsFilesPath] = uigetfile([ [analysisPath filesep] '*ResultsKV.mat'], ...
                                    'Please select the Step-Finding Results File(s)','MultiSelect', 'on');
    if ~iscell(ResultsFiles)
        temp = ResultsFiles; clear ResultsFiles; 
        ResultsFiles{1} = temp; %make the ResultsFile into a cell for consistency
    end
    
    for rf = 1:length(ResultsFiles)
        clear FinalDwells; %clear to avoid any conflict
        load([ResultsFilesPath filesep ResultsFiles{rf}],'FinalDwells'); %load only the FinalDwells data structure
        
        SaveFolder = [ResultsFilesPath filesep 'DetectATPgSClusters_Main'];
        if ~exist(SaveFolder,'dir')
            mkdir(SaveFolder);
        end
        
        for ph = 1:length(FinalDwells) %ph is the index for each phage trace
            PauseClusters{ph} = StepFinding_DetectATPgSClusters_ByTrace(FinalDwells{ph},SaveFolder,MinPause,MaxSeparation);
            StepFinding_DetectATPgSClusters_PlotEntirePhageTrace(FinalDwells{ph},SaveFolder,PauseClusters{ph},MinPause);
        end
        save([ResultsFilesPath filesep ResultsFiles{rf}(1:end-4) '_DetectATPgSClusters_Main.mat'],'FinalDwells','PauseClusters');
        
        % Plot the entire trace with identified pause clusters on a seprate
        % plot for a "global view". Use only filtered data, the stepping
        % ladder and the highlighted patches. Using raw data on this scale
        % is very memory intensive
        
    end
end