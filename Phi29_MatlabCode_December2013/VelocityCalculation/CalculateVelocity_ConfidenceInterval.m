function Result = CalculateVelocity_ConfidenceInterval(VelMean,TimeSpan,BootstrapN,DesiredConfidenceInterval,PlotOption)
% This function estimates the confidence interval for velocity given several VelMean and the
% corresponding TimeSpan values. Estimation is done after BootstrapN bootstrapping cycles.
%
% VelMean - the mean velocity for a particular translocation segment
% TimeSpan - the time span (s) of that particular translocation segment
% Velocity values are weigthed by their time span (longer time spans result in more accurate vel)
% DesiredConfidenceInterval - for example 0.68 or 0.95 etc
% Result = [LowerBound MostLikelyValue UpperBound] - our results
%
% USE: Result = CalculateVelocity_ConfidenceInterval(VelMean,TimeSpan,BootstrapN,DesiredConfidenceInterval) 
%  or  Result = CalculateVelocity_ConfidenceInterval(VelMean,TimeSpan,BootstrapN,DesiredConfidenceInterval,PlotOption)
% 
% Gheorghe Chistol, 23 Feb 2011

    if nargin<5
        PlotOption = 'NoPlot';
    end
    
    VelList = nan(1,BootstrapN); %initialize the velocity list containing the mean vel from each boostrapping round, make everything NaN

    Indexes = 1:1:length(VelMean); %we can use this for random sampling
    for i=1:BootstrapN
        CurrInd = randsample(Indexes,length(Indexes),1); %draw with replacement, drawing the same value twice is ok
        v = VelMean(CurrInd);
        t = TimeSpan(CurrInd);
        VelList(i) = sum(v.*t)/sum(t); %average velocity from this bootstrapping round, weighting is done by the timespan
    end

    %% Now compute the confidence Intervals

    [VelF VelX] = ksdensity(VelList);
    

    VelPeakInd = find(VelF==max(VelF),1,'first');
    VelPeakX   = VelX(VelPeakInd);
    VelPeakF   = VelF(VelPeakInd);

    Nslice      = 20; %number of horizontal slices to use for confidence interval analysis
    SliceDelta  = VelPeakF/Nslice;
    SliceHeight = SliceDelta:SliceDelta:VelPeakF-SliceDelta;

    LeftPartInd  = 1:VelPeakInd; %look for lower bound for Vel here
    RightPartInd = VelPeakInd:length(VelF); %look for upper bound of Vel here

    ConfInt = []; %for every SliceHeight we have a confidence interval value
    for i=1:length(SliceHeight);
        Xleft  = interp1(VelF(LeftPartInd), VelX(LeftPartInd), SliceHeight(i));
        Xright = interp1(VelF(RightPartInd),VelX(RightPartInd),SliceHeight(i));

%         if strcmp(PlotOption,'Plot');
%             plot([Xleft Xright],SliceHeight(i)*[1 1],'b');
%         end

        %refined grid for integrating under the curve
        GridDelta  = range([Xleft Xright]/100);
        Xgrid      = Xleft:GridDelta:Xright;
        Ygrid      = interp1(VelX,VelF,Xgrid);
        AreaUnder  = sum(Ygrid);
        XgridTotal = VelX(1):GridDelta:VelX(end);
        YgridTotal = interp1(VelX,VelF,XgridTotal);
        AreaTotal  = sum(YgridTotal);
        ConfInt(i) = AreaUnder/AreaTotal;
    end

    %find the desired slice height for the desired confidence interval
    DesiredSliceHeight = interp1(ConfInt,SliceHeight,DesiredConfidenceInterval);
    Xleft              = interp1(VelF(LeftPartInd),  VelX(LeftPartInd),  DesiredSliceHeight);
    Fleft              = interp1(VelX(LeftPartInd),  VelF(LeftPartInd),  Xleft);
    Xright             = interp1(VelF(RightPartInd), VelX(RightPartInd), DesiredSliceHeight);
    Fright             = interp1(VelX(RightPartInd), VelF(RightPartInd), Xright);

    Result = [Xleft VelPeakX Xright]; %the confidence interval and the peak value

    if strcmp(PlotOption,'Plot');
        %cut horizontal slices into the kernel density plot to determine confidence intervals
        % close all;
        figure; hold on;
        plot(VelX,VelF,'k','LineWidth',2);
        xlabel('Velocity (bp/s)');
        ylabel('Probability Density');
        %find the peak
        plot(VelPeakX, VelPeakF,'bo','MarkerFaceColor','b');
        plot(VelPeakX*[1 1],[0 VelPeakF],':k','LineWidth',1);
        plot([Xleft Xright],DesiredSliceHeight*[1 1],'b','LineWidth',1);
        plot(Xleft,Fleft,'.b',Xright,Fright,'.b','MarkerSize',20);
    end
end