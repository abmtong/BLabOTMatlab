function [PauseThreshold PenaltyFactor] = CalculatePauseThresholdBasedOnVelocity(Trace,Tstart,Tstop)
%This function makes a rough estimation of the velocity by binning the data
%in 1 kb DNA. The initial velocity estimation is the maximun value
%estimated in any of these bins, and it is corrected with a 20% reduction
%to account for high filling conditions after 7.7 kb DNA.
%Use as PauseThreshold=CalculatePauseThresoldBasedOnVelocity(Trace)

clear Velocity;
clear BinnedVelocity;
%clear Contour;
%clear Time;


%% Define Parameters
Contour = []; %unified data - one vector for the entire trace
Time    = []; %unified time - one vector for the entire trace
Force   = []; %unified force - one vector for the entire trace

BurstDuration=0.01; % 10 ms fixed duration for the duration of the burst phase 

Bandwidth = 2500;
F=100; %set the filtering frequency to 100Hz by default
N=round(Bandwidth/F); %this is the filtering factor
%disp(['Filtering data to ' num2str(Bandwidth/N) ' Hz']);

%% Glue together into one single vector all the data from different feedback
%cycles

    for n=1:length(Trace.time)
        TempTime    = FilterAndDecimate(Trace.time{n}, N); %filter the time and the other important values
        TempContour = FilterAndDecimate(Trace.contour{n}, N);
        TempForce   = FilterAndDecimate(Trace.force{n}, N);
            
        Time    = [Time    TempTime];
        TempSize=size(TempContour);
        if TempSize(1)==1
            Contour = [Contour TempContour]; %#ok<*AGROW>
            Force   = [Force   TempForce];
        else
            Contour = [Contour TempContour']; %#ok<*AGROW>
            Force   = [Force   TempForce'];
        end
    end
    CropInd = Time>Tstart & Time<Tstop; %the points to be included in analysis
   % disp('Flag 1')        
    Contour=Contour(CropInd);
    Time=Time(CropInd);
    NoBins=floor((max(Contour)-min(Contour))/1000);
    %disp('Numero de Bins')
    %disp(NoBins)
    %disp('Where is the number')
    
    if NoBins>=1
        for j=1:NoBins
           upperInd=find(Contour <=min(Contour)+(j)*1000,1,'first');
           lowerInd=find(Contour <=min(Contour)+(j-1)*1000,1,'first');
           BinnedVelocity(j)=(Contour(upperInd)-Contour(lowerInd))/(Time(lowerInd)-Time(upperInd));
           disp(BinnedVelocity(j));
        end    
    
        j=0;
         kbEnd=floor(min(Contour)/1000);
         [TempVel,j]=max(BinnedVelocity);
         %disp(j);
         if kbEnd<5
             if ((j-1)+kbEnd)>5
              TempVel=TempVel*0.8;
             end  
         end
       Velocity=TempVel;
    else 
      %upperInd=find(max(Contour));
      %lowerInd=find(min(Contour));
      Velocity=(max(Contour)-min(Contour))/(max(Time)-min(Time));
      %disp(Velocity);
    end
    
    %disp('Flag 2')
    
    PenaltyFactor=3;
    %display(Velocity)
    if Velocity<=20
            PenaltyFactor=8;
    elseif Velocity>20 && Velocity<=50;
            PenaltyFactor=5;
            disp(PenaltyFactor);
    elseif Velocity>50 && Velocity<=80
            PenaltyFactor=4;
            disp(PenaltyFactor);
    elseif Velocity>80
            PenaltyFactor=3;
            disp(PenaltyFactor);
    end
   
    %disp(Velocity)
    %disp(PenaltyFactor)
    DwellDuration=10/Velocity-BurstDuration;
    PauseThreshold=DwellDuration*6;

end

