function Value = NormalizedGaussianRepresentation(Grid,Center,Sigma)
    % Compute the gaussian contribution, given a grid, the center of the
    % gaussian and it width. Work within N*Sigma (for example N=3, work
    % from -3Sigma to +3Sigma). The gaussian Value(Grid) is properly normalized to
    % 1.
    %
    % USE: y = NormalizedGaussianRepresentation(x,Center,Sigma)
    %
    % Gheorghe Chistol, 5 Dec 2011

    N=3;  %how many sigmas to work with
    n=20; %use 20 data points to define the gaussian

    A=1/(Sigma*sqrt(2*pi)); %amplitude for a gaussian normalized to 1

    xDelta = 2*N*Sigma/n;
    x      = Center-N*Sigma:xDelta:Center+N*Sigma;
    y      = A*exp(-(x-Center).^2/(2*Sigma^2));

    % Extend the range of the current x to cover the entire Grid
    x = [min(Grid) x max(Grid)]; %prepare for interpolation
    y = [0 y 0];     % add zeroes in y at the extremes
    if sum(isnan(x))+sum(isnan(y))>0
        Value=zeros(size(Grid)); %there is something funny here
        disp('Something Funny Over Here !');
        return;
    end
    
    Value = interp1(x,y,Grid,'pchip'); %interpolate the gaussian onto the KernelGrid, so we can add it to the existing KernelValue
end