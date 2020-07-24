function [RecordOfValidatedDwells ProposedDwells ValidatedFragDwellInd KernelDensity] = Adaptive_ValidateDwells_FragDwellInd(RawT,RawY,FiltT,FiltY,FiltF,FragDwellInd,ContrastThr,MaxSeparation,KernelFiltFact)
    % FragDwellInd{f}(d).Start
    % FragDwellInd{f}(d).Finish
    % FragDwellInd{f}(d).Mean  
    %
    % KernelDensity{f}.KernelGrid
    % KernelDensity{f}.KernelValue
    %
    % RawT  - time    vector at 2500Hz
    % RawY  - contour vector at 2500Hz
    % FiltT - time vector at the bandwidth used for KV stepfinding
    % FiltY - contour vector at the bandwidth used for KV stepfinding
    %
    % Uses custom Kernel Density Function to generate the side-histogram
    % Validates peaks in kernel density distribution using ContrastThr(eshold)
    %
    % MaxSeparation - the peak shouldn't be any further than that from a candidate dwell location
    % ContrastThr   - contrast threshold for ksdensity peak validation
    %
    % [ValidatedFragDwellInd KernelDensity] = KV_ValidateDwells_FragDwellInd_KernelDensity(RawT, RawY, FiltT, FiltY, FragDwellInd, ContrastThr, MaxSeparation)
    %
    % Gheorghe Chistol, 6 July 2011

    %KernelFiltFact    = 15;  %filter down to 250Hz
    

    if isempty(FragDwellInd)
        ValidatedFragDwellInd{1}(1).Start         = NaN;
        ValidatedFragDwellInd{1}(1).Finish        = NaN;
        ValidatedFragDwellInd{1}(1).StartTime     = NaN;
        ValidatedFragDwellInd{1}(1).FinishTime    = NaN;
        ValidatedFragDwellInd{1}(1).DwellTime     = NaN;
        ValidatedFragDwellInd{1}(1).DwellLocation = NaN;
        ValidatedFragDwellInd{1}(1).DwellForce    = NaN;
        ProposedDwells{1}(1).Start         = NaN;
        ProposedDwells{1}(1).Finish        = NaN;
        ProposedDwells{1}(1).StartTime     = NaN;
        ProposedDwells{1}(1).FinishTime    = NaN;
        ProposedDwells{1}(1).DwellTime     = NaN;
        ProposedDwells{1}(1).DwellLocation = NaN;
        ProposedDwells{1}(1).DwellForce    = NaN;
        RecordOfValidatedDwells{1}(1).Start         = NaN;
        RecordOfValidatedDwells{1}(1).Finish        = NaN;
        RecordOfValidatedDwells{1}(1).StartTime     = NaN;
        RecordOfValidatedDwells{1}(1).FinishTime    = NaN;
        RecordOfValidatedDwells{1}(1).DwellTime     = NaN;
        RecordOfValidatedDwells{1}(1).DwellLocation = NaN;
        RecordOfValidatedDwells{1}(1).DwellForce    = NaN;
        KernelDensity{1}.KernelGrid  = NaN;
        KernelDensity{1}.KernelValue = NaN;
        return;
    end
    
    for f=1:length(FragDwellInd)
        for d=1:length(FragDwellInd{f})
            FragDwellInd{f}(d).StartTime     = FiltT(FragDwellInd{f}(d).Start);
            FragDwellInd{f}(d).FinishTime    = FiltT(FragDwellInd{f}(d).Finish);
            FragDwellInd{f}(d).DwellTime     = FragDwellInd{f}(d).FinishTime-FragDwellInd{f}(d).StartTime;
            FragDwellInd{f}(d).DwellLocation = FragDwellInd{f}(d).Mean;
            FragDwellInd{f}(d).DwellForce    = mean(FiltF(FragDwellInd{f}(d).Start:FragDwellInd{f}(d).Finish));
        end
    end
    
    for f=1:length(FragDwellInd)
        %Now we treat each fragment of the trace in FragDwellInd as an
        %independent trace and proceed with the usual validation scheme
        tempDwellInd = FragDwellInd{f};

        tempFiltT    = FiltT(tempDwellInd(1).Start:tempDwellInd(end).Finish);
        %tempFiltY    = FiltY(tempDwellInd(1).Start:tempDwellInd(end).Finish);
        %tempFiltF    = FiltF(tempDwellInd(1).Start:tempDwellInd(end).Finish);
        RawKeepInd   = RawT>=tempFiltT(1) & RawT<tempFiltT(end);
        tempRawY     = RawY(RawKeepInd);
        
        %Each FragDwellInd is now offset by some number of points in terms
        %of index, i.e. tempDwellInd(2).Start is not 1
        tempIndexOffset = tempDwellInd(1).Start-1;
        if tempIndexOffset>0
            for d=1:length(tempDwellInd)
                tempDwellInd(d).Start  = tempDwellInd(d).Start  - tempIndexOffset;
                tempDwellInd(d).Finish = tempDwellInd(d).Finish - tempIndexOffset;
            end
        end
        
        %Calculate the Adaptive Custom Kernel Density
        [KernelGrid KernelValue] = Adaptive_CalculateKernelDensity(tempRawY,KernelFiltFact);
        KernelDensity{f}.KernelGrid  = KernelGrid;
        KernelDensity{f}.KernelValue = KernelValue;
        
        %Identify the Valid Local Maxima/Peaks in the Kernel Density
        LocalMaxima = Adaptive_IdentifyLocalMaxima(KernelGrid, KernelValue, ContrastThr);

        %Validated Dwells based on the Local Maxima
        [RecordOfValidatedDwells{f} ProposedDwells{f} ValidatedFragDwellInd{f} KernelDensity{f}.LocalMaxima] = Adaptive_ValidateDwells_FragDwellInd_Validate(tempDwellInd,LocalMaxima,MaxSeparation); %#ok<AGROW>
        
        %Add back the offset that we removed earlier
        if tempIndexOffset>0
            for d=1:length(ValidatedFragDwellInd{f})
                ValidatedFragDwellInd{f}(d).Start  = ValidatedFragDwellInd{f}(d).Start  + tempIndexOffset; %#ok<*AGROW>
                ValidatedFragDwellInd{f}(d).Finish = ValidatedFragDwellInd{f}(d).Finish + tempIndexOffset;
            end
        end
    end
end