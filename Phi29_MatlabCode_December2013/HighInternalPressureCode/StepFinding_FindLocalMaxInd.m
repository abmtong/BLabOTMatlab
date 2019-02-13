function LocalMaxInd = StepFinding_FindLocalMaxInd(Y)
    % Given some smooth data Y identify local maxima and their index
    %
    % USE: LocalMaxInd = StepFinding_FindLocalMaxInd(Y)
    %
    % Gheorghe Chistol, 14 July 2011
    
    if isempty(Y)
        LocalMaxInd = [];
        return;
    end
    
    LocalMaxInd = [];
    i=2;
    while i<length(Y)
        if Y(i)>Y(i+1) && Y(i)>Y(i-1)
            %we have a local maximum
            LocalMaxInd(end+1)=i;
        end
        i=i+1;
    end
    
end