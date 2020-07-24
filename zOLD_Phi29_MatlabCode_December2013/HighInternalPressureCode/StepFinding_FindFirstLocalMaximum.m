function OffsetInd = StepFinding_FindFirstLocalMaximum(KernelY)
    %
    % USE: OffsetInd = StepFinding_FindFirstLocalMaximum(KernelY)
    %
    % Gheorghe Chistol, 14 July 2011
    
    if isempty(KernelY)
        OffsetInd = [];
        return;
    end
    
    OffsetInd = []; i=2;
    while i<length(KernelY)
        if KernelY(i+1)<KernelY(i) && KernelY(i-1)<KernelY(i)
            %we got the first local maxima
            OffsetInd = i; i=NaN;
        end
        i=i+1;
    end
end