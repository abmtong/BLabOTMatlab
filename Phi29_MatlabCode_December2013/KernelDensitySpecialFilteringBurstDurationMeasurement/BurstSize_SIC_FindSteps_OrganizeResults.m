function Dwells=BurstSize_SIC_FindSteps_OrganizeResults(T,Y,F,DwellInd)
% Once you know the DwellInd, organize the results in a more structured way
% for later calculations
% DwellInd(d).Start
% DwellInd(d).Finish
% DwellInd(d).Mean - not being used here
%
%
% USE: Dwells=BurstSize_SIC_FindSteps_OrganizeResults(T,Y,F,DwellInd)
%
% Gheorghe chistol, 22 Feb 2013

    %% now organize everything is a more convenient fashion
    for d = 1:length(DwellInd)
        Dwells.StartInd(d)   = DwellInd(d).Start;
        Dwells.FinishInd(d)  = DwellInd(d).Finish;
        Dwells.StartTime(d)  = T(Dwells.StartInd(d));
        Dwells.FinishTime(d) = T(Dwells.FinishInd(d));
        IndKeep = T>=Dwells.StartTime(d) & T<=Dwells.FinishTime(d);
        Dwells.DwellDuration(d) = double(range(T(IndKeep)));
        Dwells.DwellLocation(d) = double(mean(Y(IndKeep)));
        Dwells.DwellLocationErr(d) = 2*std(Y(IndKeep))/(sqrt(sum(IndKeep)-1));
        Dwells.DwellForce(d)    = mean(F(IndKeep));
    end
    %calculate Step size Before and After the dwell
    for d = 1:length(Dwells.DwellLocation)
       if d==1 
          Dwells.SizeStepBefore(d)=NaN;
       else
          Dwells.SizeStepBefore(d)=Dwells.DwellLocation(d-1)-Dwells.DwellLocation(d);
       end
       
       if d==length(Dwells.DwellLocation)
          Dwells.SizeStepAfter(d)=NaN;
       else
          Dwells.SizeStepAfter(d)=Dwells.DwellLocation(d)-Dwells.DwellLocation(d+1); 
       end
    end
    
    %% Now construct the staircase
    Dwells.StaircaseTime    = [];
    Dwells.StaircaseContour = [];
    for d=1:length(Dwells.DwellLocation)
        Dwells.StaircaseTime((end+1):(end+2))    = [Dwells.StartTime(d) Dwells.FinishTime(d)];
        Dwells.StaircaseContour((end+1):(end+2)) = Dwells.DwellLocation(d)*[1 1];
    end
end