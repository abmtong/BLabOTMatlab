function ValidatedFragDwellInd = KV_ValidateDwells_FragDwellInd(RawT, RawY, FiltT, FiltY, FragDwellInd, ContrastThr, MaxSeparation)
    % FragDwellInd{f}(d).Start
    % FragDwellInd{f}(d).Finish
    % FragDwellInd{f}(d).Mean  
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
    %
    % Gheorghe Chistol, 6 July 2011

    KernelFiltFact    = 15;  %filter down to 250Hz
    

    if isempty(FragDwellInd)
        ValidatedFragDwellInd{1}(1).Start         = NaN;
        ValidatedFragDwellInd{1}(1).Finish        = NaN;
        ValidatedFragDwellInd{1}(1).StartTime     = NaN;
        ValidatedFragDwellInd{1}(1).FinishTime    = NaN;
        ValidatedFragDwellInd{1}(1).DwellLocation = NaN;
        ValidatedFragDwellInd{1}(1).DwellTime     = NaN;
        
        return;
    end
    
    for f=1:length(FragDwellInd)
        for d=1:length(FragDwellInd{f})
            FragDwellInd{f}(d).StartTime     = FiltT(FragDwellInd{f}(d).Start);
            FragDwellInd{f}(d).FinishTime    = FiltT(FragDwellInd{f}(d).Finish);
            FragDwellInd{f}(d).DwellTime     = FragDwellInd{f}(d).FinishTime-FragDwellInd{f}(d).StartTime;
            FragDwellInd{f}(d).DwellLocation = FragDwellInd{f}(d).Mean;
        end
    end
    
    for f=1:length(FragDwellInd)
        %Now we treat each fragment of the trace in FragDwellInd as an
        %independent trace and proceed with the usual validation scheme
        tempDwellInd = FragDwellInd{f};

        tempFiltT    = FiltT(tempDwellInd(1).Start:tempDwellInd(end).Finish);
        tempFiltY    = FiltY(tempDwellInd(1).Start:tempDwellInd(end).Finish);
        RawKeepInd   = RawT>=tempFiltT(1) & RawT<tempFiltT(end);
        %tempRawT    = RawT(RawKeepInd); we don't use it anywhere, yet
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
        [KernelGrid KernelValue] = KV_CalculateCustomKernelDensity(tempRawY,KernelFiltFact);

        %Identify the Valid Local Maxima/Peaks in the Kernel Density
        LocalMaxima = KV_IdentifyLocalMaxima(KernelGrid, KernelValue, ContrastThr);

        %Validated Dwells based on the Local Maxima
        ValidatedFragDwellInd{f} = KV_ValidateDwells(tempFiltT, tempFiltY, tempDwellInd, LocalMaxima, MaxSeparation); %#ok<AGROW>
        
        %Add back the offset that we removed earlier
        if tempIndexOffset>0
            for d=1:length(ValidatedFragDwellInd{f})
                ValidatedFragDwellInd{f}(d).Start  = ValidatedFragDwellInd{f}(d).Start  + tempIndexOffset;
                ValidatedFragDwellInd{f}(d).Finish = ValidatedFragDwellInd{f}(d).Finish + tempIndexOffset;
            end
        end
        
    end
end