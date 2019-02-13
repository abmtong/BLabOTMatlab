function MeanDwell = CalculateMeanDwellConfInt(DwellTimes, Nsim, DesiredConfidenceInterval)
% This functions calculates the average dwell time given a pool of DwellTimes
% Nsim  - number of simulation rounds using our data
% given a sample of DwellTimes with N points, draw a point at random N
% times from this DwellTimes data pool and calculate MeanDwell. 
% It's okay if the same value gets drawn twice
%
% DesiredConfidenceInterval - for example 0.68 or 0.95 etc
% MeanDwell = [LowerBound MostLikelyValue UpperBound] - our results
%
% USE: MeanDwell = CalculateMeanDwellConfInt(DwellTimes, Nsim, DesiredConfidenceInterval)
% 
% Gheorghe Chistol, 9 August 2011

MeanDwellList = [];
for i=1:Nsim
    CurrSample = randsample(DwellTimes,length(DwellTimes),1); %draw, drawing the same value twice is ok
    MeanDwellList(end+1) = mean(CurrSample);
end

%% Now compute the confidence Intervals
[F X] = ksdensity(MeanDwellList);

PeakInd = find(F==max(F),1,'first');
PeakX   = X(PeakInd);
PeakF   = F(PeakInd);

Nslice      = 20; %number of horizontal slices to use for confidence interval analysis
SliceDelta  = PeakF/Nslice;
SliceHeight = SliceDelta:SliceDelta:PeakF-SliceDelta;

LeftPartInd  = 1:PeakInd; %look for lower bound 
RightPartInd = PeakInd:length(F); %look for upper bound

ConfInt = []; %for every SliceHeight we have a confidence interval value
for i=1:length(SliceHeight);
    Xleft  = interp1(F(LeftPartInd), X(LeftPartInd), SliceHeight(i));
    Xright = interp1(F(RightPartInd),X(RightPartInd),SliceHeight(i));
    %plot([Xleft Xright],SliceHeight(i)*[1 1],'b');
    
    %refined grid for integrating under the curve
    GridDelta  = range([Xleft Xright]/100);
    Xgrid      = Xleft:GridDelta:Xright;
    Ygrid      = interp1(X,F,Xgrid);
    AreaUnder  = sum(Ygrid);
    XgridTotal = X(1):GridDelta:X(end);
    YgridTotal = interp1(X,F,XgridTotal);
    AreaTotal  = sum(YgridTotal);
    ConfInt(i) = AreaUnder/AreaTotal;
end

%find the desired slice height for 95% confidence interval
DesiredSliceHeight = interp1(ConfInt,SliceHeight,DesiredConfidenceInterval);
Xleft              = interp1(F(LeftPartInd),  X(LeftPartInd),  DesiredSliceHeight);
Fleft              = interp1(X(LeftPartInd),  F(LeftPartInd),  Xleft);
Xright             = interp1(F(RightPartInd), X(RightPartInd), DesiredSliceHeight);
Fright             = interp1(X(RightPartInd), F(RightPartInd), Xright);

MeanDwell = [Xleft PeakX Xright]; %the confidence interval and the peak value


%cut horizontal slices into the kernel density plot to determine confidence intervals
% close all;
% figure; hold on;
% plot(NminX,NminF,'k','LineWidth',2);
% xlabel('Nmin Value');
% ylabel('Probability Density');
%find the peak
%plot(NminPeakX, NminPeakF,'bo','MarkerFaceColor','b');
%plot(NminPeakX*[1 1],[0 NminPeakF],':k','LineWidth',1);
%plot([Xleft Xright],DesiredSliceHeight*[1 1],'b','LineWidth',1);
%plot(Xleft,Fleft,'.b',Xright,Fright,'.b','MarkerSize',20);