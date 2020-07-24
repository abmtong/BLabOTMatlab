function CandidateDwells = Adaptive_ValidateDwells_FragDwellInd_Consolidate(CandidateDwells, LocalMaxima, MaxSeparation,History)
% Consolidate tempDwellInd using the valid peaks as reference
% In Particular: 1. Merge two consecutive dwells associated with the same peak
%                2. If there are two dwells associated with two peaks and one dwell in between, partition the middle dwell between the two valid dwells
%                   the liquidate the middle dwell
% CandidateDwells(cd).Start
% CandidateDwells(cd).Finish
% CandidateDwells(cd).Mean  
% CandidateDwells(cd).StartTime
% CandidateDwells(cd).FinishTime
% CandidateDwells(cd).DwellTime
% CandidateDwells(cd).DwellLocation
% CandidateDwells(cd).DwellForce
%
% LocalMaxima.KernelGrid
% LocalMaxima.KernelValue
% LocalMaxima.LocalMaxInd(m)
% LocalMaxima.LeftLocalMinInd(m)
% LocalMaxima.RightLocalMinInd(m)
% LocalMaxima.Baseline(m)
% LocalMaxima.PeakContrast(m)
% LocalMaxima.IsValid(m)
% LocalMaxima.LocalMinInd
%
% History(r).DwellInd = DwellInd;
% History(r).StepInd  = StepInd;
% History(r).DwellInd
% 1x4 struct array with fields:
%    Start
%    Finish
%    Mean
%    Var
%
% CandidateDwells - contains all the info about the dwell/step candidated
% MaxSeparation   - the peak shouldn't be any further than that from a candidate dwell location
%
% USE: tempDwellInd = Adaptive_ValidateDwells_FragDwellInd_Consolidate(CandidateDwells,LocalMaxima,MaxSeparation);
%
% Gheorghe Chistol, 14 November 2012

    %get the location of all the dwells
    for cd = 1:length(CandidateDwells)
        DwellLocations(cd) = CandidateDwells(cd).Mean;  
    end
    
    %go through all LocalMaxima, and find the nearest dwell candidates that are closer than
    %MaxSeparation. If one valid peak has two dwells associated with it, the two
    %have to be merged. This should be done iteratively until no more merging can be done
    m=1; %start with the first peak
    while m<=length(LocalMaxima.IsValid)    %continue merging until you run out of Kernel Density Local Maxima
        if LocalMaxima.IsValid(m)
            CurrPeakLocation = LocalMaxima.KernelGrid(LocalMaxima.LocalMaxInd(m));
            Separation       = abs(CurrPeakLocation-DwellLocations);
            NearDwellInd     = find(Separation<MaxSeparation); %index of the dwells that are close enough to the current peak
            if length(NearDwellInd)>1
                NearDwellInd = NearDwellInd(1:2); %work with the first two dwells for now
                disp(['-> -> ->  Merging two consecutive dwells next to a valid peak']);
                [CandidateDwells DwellLocations] = Adaptive_ValidateDwells_FragDwellInd_Consolidate_Merge2Dwells(CandidateDwells,NearDwellInd);
            else
                m=m+1; %increment the peak
            end
        else
            m=m+1; %move on to the next peak
        end
    end
    
    %% Now proceed to merging v-i-v situations
    ValidPeakInd = LocalMaxima.LocalMaxInd(logical(LocalMaxima.IsValid));
    vp=1; %we are going to look at vp and vp+1 
    while vp<length(ValidPeakInd) %vp stands for "ValidPeak"
        %we're working between peaks vp and vp+1
        %validated dwell associated with peak vp
        PeakLocation1 = LocalMaxima.KernelGrid(ValidPeakInd(vp));
        Separation1   = abs(PeakLocation1-DwellLocations);
        DwellInd1     = find(Separation1==min(Separation1)); %index of the dwell closest to this peak
        if length(DwellInd1)~=1
            DwellInd1=[];
        end
        
        PeakLocation2 = LocalMaxima.KernelGrid(ValidPeakInd(vp+1));
        Separation2   = abs(PeakLocation2-DwellLocations);
        DwellInd2     = find(Separation2==min(Separation2)); %index of the dwell closest to this peak
        if length(DwellInd2)~=1
            DwellInd2=[];
        end
        DwellInd = sort([DwellInd1 DwellInd2]);
        
        if range(DwellInd)==2 %i.e. there is exactly one dwell in between the two
            %Merge the intermediate dwell into the closest of the two valid dwells
            MiddleDwellInd = mean(DwellInd); %the dwell destined for destruction is in between the two
            
            if range([CandidateDwells(DwellInd1).Mean CandidateDwells(MiddleDwellInd).Mean])< ...
               range([CandidateDwells(DwellInd2).Mean CandidateDwells(MiddleDwellInd).Mean])
               MergeDwellInd = [DwellInd1 MiddleDwellInd]; %merge the intermediate dwell into DwellInd1
            else
               MergeDwellInd = [MiddleDwellInd DwellInd2];%merge the intermediate dwell into DwellInd2
            end
            
            disp(['>> Merging two dwells in the v-i-v scenario']);
            [CandidateDwells DwellLocations] = Adaptive_ValidateDwells_FragDwellInd_Consolidate_Merge2Dwells(CandidateDwells,MergeDwellInd);
        else
            vp = vp+1;
        end
    end
end
% CandidateDwells(cd).Start
% CandidateDwells(cd).Finish
% CandidateDwells(cd).Mean  
% CandidateDwells(cd).StartTime
% CandidateDwells(cd).FinishTime
% CandidateDwells(cd).DwellTime
% CandidateDwells(cd).DwellLocation
% CandidateDwells(cd).DwellForce