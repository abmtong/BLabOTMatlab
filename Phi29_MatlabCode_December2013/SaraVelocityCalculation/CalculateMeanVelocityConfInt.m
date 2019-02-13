function MeanVelocity = CalculateMeanVelocityConfInt(Velocity, Nsim, DesiredConfidenceInterval)
% This functions calculates the average velocity time given a pool of
% Velocity
% Nsim  - number of simulation rounds using our data
% given a sample of velocities with N points, draw a point at random N
% times from this Velocities data pool and calculate MeanVelocity. 
% It's okay if the same value gets drawn twice
%
% DesiredConfidenceInterval - for example 0.68 or 0.95 etc
% MeanVelocity = [LowerBound MostLikelyValue UpperBound] - our results
%
% USE: MeanVelocity = CalculateMeanVelocityConfInt(VelSummary, Nsim, DesiredConfidenceInterval)
% 
% Gheorghe Chistol, 9 August 2011

MeanVelocityList = [];

if length(Velocity)>1
    %disp('Velocity has one element')
    for i=1:Nsim
        CurrSample = randsample(Velocity,length(Velocity),1); %draw, drawing the same value twice is ok
        MeanVelocityList(end+1) = mean(CurrSample);
    end


%% Now compute the confidence Intervals
[F X] = ksdensity(MeanVelocityList);
%plot(X,F)
PeakInd = find(F==max(F),1,'first');
PeakX   = X(PeakInd);
PeakF   = F(PeakInd);

Nslice      = 50; %number of horizontal slices to use for confidence interval analysis
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

MeanVelocity = [Xleft PeakX Xright]; %the confidence interval and the peak value
else
    %disp('Velocity has no element')
    MeanVelocity = [NaN NaN NaN];
end

%cut horizontal slices into the kernel density plot to determine confidence intervals
%close all;
%figure; hold on;
%plot(X,F,'k','LineWidth',2);
%xlabel('Nmin Value');
%ylabel('Probability Density');
%find the peak
%plot(PeakX, PeakF,'bo','MarkerFaceColor','b');
%plot(PeakX*[1 1],[0 PeakF],':k','LineWidth',1);
%plot([Xleft Xright],DesiredSliceHeight*[1 1],'b','LineWidth',1);
%plot(Xleft,Fleft,'.b',Xright,Fright,'.b','MarkerSize',20);