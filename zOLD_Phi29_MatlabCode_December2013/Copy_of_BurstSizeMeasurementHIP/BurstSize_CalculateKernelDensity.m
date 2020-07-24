function [KernelGrid, KernelValue] = BurstSize_CalculateKernelDensity(RawY,KernelFiltFact)
    % Calculate the custom kernel density. The original raw data is
    % filtered and decimated by some KernelFiltFact. Each decimated point
    % will contribute a gaussian to the final kernel density. The gaussian
    % will be normalized to one, and will have a sigma of StErr for the
    % respective filtered&decimated point
    %
    % USE: [KernelGrid KernelValue] = BurstSize_CalculateKernelDensity(RawY,KernelFiltFact)
    %
    % Gheorghe Chistol, 29 Dec 2012

    % Filter and Decimate the data (FaD) one point at a time
    FaD.Y     = zeros(1,length(RawY)-KernelFiltFact+1); %FaD = "Filtered and Decimated"
    FaD.StErr = zeros(1,length(RawY)-KernelFiltFact+1); % Y is the mean, StErr is the Standard Error
    
    for i = 1:length(RawY)-KernelFiltFact+1;%floor(length(RawY)/KernelFiltFact)
        temp = RawY(i:i+KernelFiltFact-1);
        FaD.Y(i)     = mean(temp);
        FaD.StErr(i) = std(temp)/sqrt(KernelFiltFact);
    end

    KernelGridDelta = median(FaD.StErr)/5;
    KernelGrid      = min(RawY):KernelGridDelta:max(RawY); %the grid on which we will build the kernel
    KernelValue     = 0*KernelGrid; %the values at each point in the grid, start with zero

    %add the kernel contribution for each filtered point
    for i=1:length(FaD.Y)
        %built it up one point at a time, updating the KernelValue for each FaD point
        KernelValue = BurstSize_CalculateKernelDensity_AddGausian(KernelGrid, KernelValue, FaD.Y(i), FaD.StErr(i)); 
    end
    KernelValue = KernelValue/max(KernelValue); %rescale everything to 1
end