function ValidatedDwells = KV_ValidateDwells_ResolveValidUnvalidValid(CandidateDwells,ValidatedDwells,LocalMaxima,FiltT,FiltY)
    % Where an unvalidated dwell is sandwiched between two validated dwells.
    % Here we can split the unvalidated dwell between its neighbors.
    %
    % USE: ValidatedDwells = KV_ValidateDwells_ResolveValidUnvalidValid(CandidateDwells,ValidatedDwells,LocalMaxima,FiltT,FiltY)
    %
    % Gheorghe Chistol, 30 Jun 2011
    
    vd=1; %counter for ValidatedDwells, use "while" instead of "for" 
    
    while vd < length(ValidatedDwells)
        %work forward, i.e. the current ValidatedDwell and the next one
        CurrVD = vd;
        NextVD = vd+1;
        %The middle unvalidated dwell is sandwiched between MaxBoundary on top
        %and MinBoundary on the bottom. This is done because some
        %ValidatedDwells are the result of precursor merging, then Max/Min
        %Boundaries are based on the precursors
        MaxBoundaryY = NaN;
        MinBoundaryY = NaN;
        MaxBoundaryT = NaN;
        MinBoundaryT = NaN;

        %Determine MaxBoundaryY
        if isfield(ValidatedDwells,'MergeStatus')
            if ValidatedDwells(CurrVD).MergeStatus==1 %the curr validated dwell is the product of precursor merging
                MaxBoundaryY = ValidatedDwells(CurrVD).PrecursorDwell{2}.DwellLocation; %the bottom/lower precursor
            else
                MaxBoundaryY = ValidatedDwells(CurrVD).DwellLocation; %simply the location of the current validated dwell
            end
        else
            MaxBoundaryY = ValidatedDwells(CurrVD).DwellLocation; %simply the location of the current validated dwell
        end

        %Determine MinBoundaryY
        if isfield(ValidatedDwells,'MergeStatus')
            if ValidatedDwells(NextVD).MergeStatus==1 %the next validated dwell is the product of precursor merging
                MinBoundaryY = ValidatedDwells(NextVD).PrecursorDwell{1}.DwellLocation; %the top/upper precursor
            else
                MinBoundaryY = ValidatedDwells(NextVD).DwellLocation; %simply the location of the current validated dwell
            end
        else
            MinBoundaryY = ValidatedDwells(NextVD).DwellLocation; %simply the location of the current validated dwell
        end

        %Determine temporal boundaries
        MinBoundaryT = ValidatedDwells(CurrVD).FinishTime; %where the first validated dwell ends
        MaxBoundaryT = ValidatedDwells(NextVD).StartTime;  %where the second validated dwell starts

        %Find the unvalidated candidate dwell(s) sandwiched between
        %MaxBoundaryY and MinBoundaryY
        %Those candidate dwell(s) have to be also temporally sandwiched between
        %CurrVD and NextVD (the exceptions can sometimes be caused by slips
        SandwichedCandidateDwellInd = [];
        
        for cd=1:length(CandidateDwells) %cd is the counter for CandidateDwells
            temp = CandidateDwells(cd).DwellLocation;
            
            if temp<MaxBoundaryY && temp>MinBoundaryY
                %current candidate dwell is spatially sandwiched between CurrVD and NextVD
                %we need to check now that they are temporally sandwiched between CurrVD and NextVD
                TemporalCondition = CandidateDwells(cd).StartTime>MinBoundaryT & CandidateDwells(cd).FinishTime<MaxBoundaryT;
                
                if TemporalCondition
                    SandwichedCandidateDwellInd(end+1) = cd; %the current candidate dwell is temporally and spatially sandwiched between CurrVD and NextVD
                end
            end
        end

        % if we have only one sandwiched unvalid candidate dwell, and there
        % is no more than one local maxima between the two validated dwells
        % No more than one local max mean no more than two local minima
        % Easier to work with the local minima for whatever reason
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
        LocalMinLocation    = LocalMaxima.KernelGrid(LocalMaxima.LocalMinInd);
        temp                = [ValidatedDwells(NextVD).DwellLocation ValidatedDwells(CurrVD).DwellLocation];
        NrLocalMinInBetween = sum(LocalMinLocation>min(temp) & LocalMinLocation<max(temp));
        Condition1 = NrLocalMinInBetween <= 2; %we need two or fewer local minima in between
        Condition2 = length(SandwichedCandidateDwellInd)==1; %we only have one sandwiched candidate dwell , ok to split among CurrVD and NextVD
        
        if Condition1 && Condition2
            [ValidatedDwells(CurrVD) ValidatedDwells(NextVD)] = ...
            KV_ValidateDwells_SplitSandwich(ValidatedDwells(CurrVD), ValidatedDwells(NextVD), FiltT, FiltY);
        end
        
        vd=vd+1;
        
    end
end