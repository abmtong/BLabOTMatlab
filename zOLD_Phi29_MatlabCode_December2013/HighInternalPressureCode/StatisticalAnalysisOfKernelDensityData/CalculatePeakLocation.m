function [Center Sigma Sum] = CalculatePeakLocation(KernelCurve)
% for each kernel density (x,y) calculate the error-bar in peak
% determination by taking the left and the right sides at an arbitrary
% height, say 0.95 (the peak is at 1). This will give us error-bars.
%
% Gheorghe Chistol, 6 December 2011

    Thr = 0.9; %the level used to calculate the error-bars for the peak location
    Sigma  = [];
    Center = [];

    for i = 1:length(KernelCurve)
        x = KernelCurve(i).x;
        y = KernelCurve(i).y;
        x = -x-10; %we make the peak be between 0 and 10bp for convenience
        [x SortInd] = sort(x);
        y           = y(SortInd);

        MaxInd = find(y == max(y));

        if length(MaxInd)==1 %if we find only one max
            Center(i) = x(MaxInd);
            LeftInd  = 1:MaxInd;
            RightInd = MaxInd:length(x);

            LeftEdge  = interp1(y(LeftInd),x(LeftInd),Thr,'pchip');
            RightEdge = interp1(y(RightInd),x(RightInd),Thr,'pchip');
            %plot(x,y,'b',LeftEdge,Thr,'.k',RightEdge,Thr,'.r');
            %keyboard;

            Sigma(i) = (RightEdge-LeftEdge)/2;
        end
    end

    %return;
    % now that we know the Center value and Sigma, we can represent each peak
    % by a Gaussian, located at Center, with a width Sigma. This allows us to
    % account for the uncertainty in the exact location of the peak
    
    Rejects = [11 ]; %these Kernels are not quite ok
    Center(Rejects) = [];
    Sigma(Rejects)  = [];
    
    Grid = -10:0.1:25;
    Value = zeros(size(Grid));


    for i=1:length(Center)
        temp  = NormalizedGaussianRepresentation(Grid,Center(i),Sigma(i)); %the gaussian contribution of the current peak
        Value = Value + temp;
    end
    close all;
    
    Grid = Grid*10/9;
    plot(Grid,Value);
    set(gca,'XTick',-1.25:2.5:12);
    set(gca,'XGrid','on');
    set(gca,'XLim',[-5 15]);

    Limits{1}=[-1.25 1.25];
    Limits{2}=[1.25 3.75];
    Limits{3}=[3.75 6.25];
    Limits{4}=[6.25 8.75];
    Limits{5}=[8.25 15];
    for i = 1:length(Limits)
        Min = Limits{i}(1);
        Max = Limits{i}(2);
        Ind = Grid>Min & Grid<Max;
        Sum(i) = sum(Value(Ind));
    end
    Sum(5) = Sum(5)+Sum(1);
    Sum(1) = [];
    Total = sum(Sum);
    Sum = 100*Sum./Total; %this will be in percent
end