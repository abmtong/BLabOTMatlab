function [FiltData StErr] = FilterAndDecimate_StErr(RawData,FilterFactor)
    % Filter and decimate the data by FilterFact and output the
    % filtered/decimated data, as well as the Standard Error for each point.
    % This is all done in the brute force way, so it may be a bit slow for
    % very large data sets
    %
    % USE: [FiltData StErr] = FilterAndDecimate_StErr(RawData,FilterFactor)
    %
    % Gheorghe Chistol, 18 July 2011

    FiltData = [];
    StErr    = [];
    
    N = floor(length(RawData)/FilterFactor);
    
    if N>0
        FiltData = NaN*ones(1,N);
        StErr    = NaN*ones(1,N);
    else 
        return;
    end
    
    for i=1:N
        StartInd  = 1+(i-1)*FilterFactor;
        FinishInd = i*FilterFactor;
        temp = RawData(StartInd:FinishInd);
        FiltData(i) = mean(temp);
        StErr(i)    = std(temp)/sqrt(FilterFactor);
    end
end