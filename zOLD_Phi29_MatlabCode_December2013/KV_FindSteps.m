function DwellInd = KV_FindSteps(Y,PenaltyFactor)
    % This script and applies the Kalafut Visscher method for step detection. I
    % have now added some more code to make it faster. Every time the SIC is
    % calculated, the Variance for each step is stored in the DwellInd
    % structure, so it's available for later use when the current dwell is not
    % affected.
    %
    % At the output DwellInd contains the following fields
    %    DwellInd(d).Start
    %    DwellInd(d).Finish
    %    DwellInd(d).Mean
    %
    % USE: DwellInd = KV_FindSteps(Y,PenaltyFactor)
    %
    % Gheorghe Chistol, 30 June 2011

    Tstart = tic; %time the duration

    %% Find More and More Steps Until no More Are Found, Use WHILE Loop
    Status  = 'NotFinished';
    StepInd = [];
    DwellInd(1).Start  = 1;
    DwellInd(1).Finish = length(Y); %there is only one dwell at the moment
    DwellInd(1).Mean   = mean(Y);
    DwellInd(1).Var    = sum((Y-DwellInd(1).Mean).^2); 
    
    %at the beginning there are no steps and all data belongs to the same dwell
    %Y is the vertical axis data, DNA contour length for example
    fprintf('Steps detected: ');
    while strcmp(Status,'NotFinished')
        [currSIC DwellInd]= KV_ComputeSIC(Y,StepInd,DwellInd,PenaltyFactor);

        %for each point compute the Schwartz Information Criterion score
        %the SIC score corresponding to a putative step at each individual
        %data point. The lowest SIC score becomes a candidate, then the
        %candidate is compared to the SIC score of the configuration with
        %no additional step
        tempSIC = NaN*ones(1,length(Y)-1); %this will store all the SIC scores

        for i=1:length(Y)-1 %to avoid problems when reaching the last point
            %i is where the previous dwell stops
            %i+1 is where the next dwell starts
            if sum(StepInd==i)==0 %don't consider points which already correspond to steps
                [tempDwellInd tempStepInd] = KV_UpdateDwellCoordinate(Y,StepInd,DwellInd,i); %try the current point as a putative step location
                [tempSIC(i) tempDwellInd]  = KV_ComputeSIC(Y,tempStepInd,tempDwellInd,PenaltyFactor);
                %compute the SIC for a hypothetical configuration in which a step is placed at the current point
            end
        end

        minSIC = min(tempSIC);
        if minSIC<currSIC %if the SIC with a step is lower than the SIC witout a step, the step is approved
            LastStepDetectedInd = find(tempSIC==minSIC,1,'Last'); %sometimes there can be more than one points with the same min value
            [DwellInd StepInd]  = KV_UpdateDwellCoordinate(Y,StepInd,DwellInd,LastStepDetectedInd);
            fprintf('|'); %display one bar for each new step detected
        else
            Status = 'Finished'; %we're done here
            fprintf(' = %d steps \n',length(StepInd)); %finished finding steps
        end
    end
    
    [SIC DwellInd] = KV_ComputeSIC(Y,StepInd,DwellInd); %do this to update the DwellInd for the last time
    DwellInd     = rmfield(DwellInd, 'Var');          %remove the 'Var' field  because we don't care about it later
    
    disp([ round(num2str(toc(Tstart))) 'sec computation time']); %display how many seconds were spent on this computation
end