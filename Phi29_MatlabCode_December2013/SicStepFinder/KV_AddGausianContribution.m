function UpdatedKernelValue = KV_AddGausianContribution(KernelGrid, KernelValue, Center, Sigma)
    % Add the gaussian contribution to the kernel density for the current
    % point centered at Center with a sigma of Sigma. Work within N*Sigma
    % (for example N=3, work from -3Sigma to +3Sigma)
    %
    % USE: UpdatedKernelValue = KV_AddGausianContribution(KernelGrid, KernelValue, Center, Sigma)
    %
    % Gheorghe Chistol, 30 June 2011

    N=3;  %how many sigmas to work with
    n=20; %use 30 data points to define the gaussian

    A=1/(Sigma*sqrt(2*pi)); %amplitude for a gaussian normalized to 1

    xDelta = 2*N*Sigma/n;
    x      = Center-N*Sigma:xDelta:Center+N*Sigma;
    y      = A*exp(-(x-Center).^2/(2*Sigma^2));

    % Extend the range of the current x to cover the entire KernelGrid
    % add zeroes in y at the extremes
    x = [min(KernelGrid) x max(KernelGrid)]; %prepare for interpolation
    y = [0 y 0];
    if sum(isnan(x))+sum(isnan(y))>0
        UpdatedKernelValue = KernelValue;
        return;
    end
    CurrentContribution = interp1(x,y,KernelGrid); %interpolate the gaussian onto the KernelGrid, so we can add it to the existing KernelValue
    CurrentContribution = CurrentContribution/sum(CurrentContribution); %make sure it's normalized to one in it's discrete version
    UpdatedKernelValue  = KernelValue+CurrentContribution;

end