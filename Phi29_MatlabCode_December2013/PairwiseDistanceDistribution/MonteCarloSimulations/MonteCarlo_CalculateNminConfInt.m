function Nmin = CalculateNminConfInt(DwellTimes, Nsim, DesiredConfidenceInterval)
% This functions calculates Nmin given a pool of DwellTimes
% Nsim  - number of simulation rounds using our data
% given a sample of DwellTimes with N points, draw a point at random N
% times from this DwellTimes data pool and calculate Nmin. 
% It's okay if the same value gets drawn twice
%
% DesiredConfidenceInterval - for example 0.68 or 0.95 etc
% Nmin = [LowerBound MostLikelyValue UpperBound] - our results
%
% USE: Nmin = CalculateNminConfInt(DwellTimes, Nsim, DesiredConfidenceInterval)
% 
% Gheorghe Chistol, 23 June 2011

NminList = [];
for i=1:Nsim
    CurrSample = randsample(DwellTimes,length(DwellTimes),1); %draw, drawing the same value twice is ok
    NminList(end+1) = mean(CurrSample)^2/(mean(CurrSample.^2)-mean(CurrSample)^2);
end

%% Now compute the confidence Intervals
[NminF NminX] = ksdensity(NminList);

NminPeakInd = find(NminF==max(NminF),1,'first');
NminPeakX   = NminX(NminPeakInd);
NminPeakF   = NminF(NminPeakInd);

Nslice      = 20; %number of horizontal slices to use for confidence interval analysis
SliceDelta  = NminPeakF/Nslice;
SliceHeight = SliceDelta:SliceDelta:NminPeakF-SliceDelta;

LeftPartInd  = 1:NminPeakInd; %look for lower bound for Nmin here
RightPartInd = NminPeakInd:length(NminF); %look for upper bound of Nmin here

ConfInt = []; %for every SliceHeight we have a confidence interval value
for i=1:length(SliceHeight);
    Xleft  = interp1(NminF(LeftPartInd), NminX(LeftPartInd), SliceHeight(i));
    Xright = interp1(NminF(RightPartInd),NminX(RightPartInd),SliceHeight(i));
    %plot([Xleft Xright],SliceHeight(i)*[1 1],'b');
    
    %refined grid for integrating under the curve
    GridDelta  = range([Xleft Xright]/100);
    Xgrid      = Xleft:GridDelta:Xright;
    Ygrid      = interp1(NminX,NminF,Xgrid);
    AreaUnder  = sum(Ygrid);
    XgridTotal = NminX(1):GridDelta:NminX(end);
    YgridTotal = interp1(NminX,NminF,XgridTotal);
    AreaTotal  = sum(YgridTotal);
    ConfInt(i) = AreaUnder/AreaTotal;
end

%find the desired slice height for 95% confidence interval
DesiredSliceHeight = interp1(ConfInt,SliceHeight,DesiredConfidenceInterval);
Xleft              = interp1(NminF(LeftPartInd),  NminX(LeftPartInd),  DesiredSliceHeight);
Fleft              = interp1(NminX(LeftPartInd),  NminF(LeftPartInd),  Xleft);
Xright             = interp1(NminF(RightPartInd), NminX(RightPartInd), DesiredSliceHeight);
Fright             = interp1(NminX(RightPartInd), NminF(RightPartInd), Xright);

Nmin = [Xleft NminPeakX Xright]; %the confidence interval and the peak value


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