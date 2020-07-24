function Burst = BurstDuration_BetweenTwoDwells(Time,Contour,FirstDwellP,SecondDwellP,TimeBoundary)
%given two dwells, the corresponding Time and Contour vectors (both
%filtered already), identify the burst duration between the two dwells
%FirstDwellP - the line fit to the first dwell
%SecondDwellP - the line fit to the second dwell
%
% it helps to have to line fit, when dealing with slanted dwells

    % first start right between the two Dwells
    StartInd=find(Time==TimeBoundary,1,'first'); %starting point
    FirstDwell = polyval(FirstDwellP,TimeBoundary);
    % Now scan up and down until you hit the location of the dwell 
    %first scan back
    b=StartInd;
    while Contour(b)<FirstDwell && b>1 %can't move beyond the index of the existing data
        b=b-1; %move back by one point
    end
    %b=b+1;
    
    SecondDwell = polyval(SecondDwellP,TimeBoundary);
    %now scan forward
    f=StartInd;
    while Contour(f)>SecondDwell && f<length(Time) %can't move beyond the index of the existing data
        f=f+1; %move forward by one point
    end
    %f=f-1;
    
    Burst.StartTime  = Time(b);
    Burst.FinishTime = Time(f);
    Burst.BurstDuration = Burst.FinishTime-Burst.StartTime;
    
    Ind = (Time>= Burst.StartTime & Time<=Burst.FinishTime);
    x=Time(Ind);
    y=Contour(Ind);
    p=polyfit(x,y,1);
    
    Burst.FitStartTime  = (FirstDwell -p(2))/p(1);
    Burst.FitFinishTime = (SecondDwell-p(2))/p(1);
    Burst.FitBurstDuration = Burst.FitFinishTime-Burst.FitStartTime;
    
end