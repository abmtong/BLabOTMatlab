function ValidatedDwells = KV_MergeDwellsWhenPossible(t,y,CandidateDwells,ValidatedDwells,SideHistProp)
% So far we have been finding dwell candidates using the KV method then
% validating the "good" dwells using the side-view histogram method.
% However, even after those procedures, we are not satisfied with the
% step-finding. There are three main problems, in order of significance:
% 1. dwell candidates that should be merged to a nearby validated dwell
% 2. dwell candidates that should be split between nearby validated dwells
% 3. validated dwells surrounded by invalidated dwells, in which case the
%    lone validated dwell should be invalidated
%
% This function will tackle dwell merging, which should fix the majority of
% issues. This will give us a more realistic dwell-time distribution, as
% well as step-size distribution.
%
% t - raw time data filtered&decimated to ~500Hz, working bandwidth for the KV method
% y - raw contour data filtered&decimated to the working bandwidth for the KV method
% CandidateDwells - complete index/characterization of the dwell candidates identified by the initial KV step-finding
% ValidatedDwells - complete index of the dwells validated by the side-view histogram method, but which still require fine-tuning
% SideHistProp    - properties of the side-view histogram
%
% USE: ValidatedDwells = KV_MergeDwellsWhenPossible(t,y,CandidateDwells,ValidatedDwells,SideHistProp)
%
% Gheorghe Chistol, 17 June 2011

MaxDwellDwellSeparation = 4; %in bp, the maximum allowed separation between a valid dwell and a candidate dwell that can be merged into one
MaxDwellPeakSeparation  = 2; %in bp, max allowed separation between a validated peak in the side-hist and a validated dwell

% go through all ValidatedDwells and see if they can be merged with unvalidated CandidateDwells
vd = 1;
while vd <=length(ValidatedDwells)
    %find the nearest consecutive candidate dwell
    cdPrev = []; %index of the previous Candidate Dwell
    cdNext = []; %index of the next Candidate Dwell
    cdPrevLoc = []; %location of the prev Candidate Dwell
    cdNextLoc = []; %location of the next Candidate Dwell
    cdPrevSeparation = []; %separation between prev cand-dwell and curr valid-dwell
    cdNextSeparation = []; %separation between next cand-dwell and curr valid-dwell
    
    for cd = 1:length(CandidateDwells)
        if CandidateDwells(cd).Finish+1 == ValidatedDwells(vd).Start
            %the current candidate dwell is right before the current validated dwell
            cdPrev = cd; 
            
            if range([ValidatedDwells(vd).DwellLocation CandidateDwells(cd).DwellLocation])<MaxDwellDwellSeparation
                % the Previous candidate dwell is close enough to the Current validated dwell
                cdPrevSeparation = range([ValidatedDwells(vd).DwellLocation CandidateDwells(cd).DwellLocation]);
            end
        end
        if CandidateDwells(cd).Start == ValidatedDwells(vd).Finish+1
            %the current candidate dwell is right after the current validated dwell
            cdNext = cd; %index
            
            if range([ValidatedDwells(vd).DwellLocation CandidateDwells(cd).DwellLocation])<MaxDwellDwellSeparation
                % the Next candidate dwell is close enough to the Current validated dwell
                cdNextSeparation = range([ValidatedDwells(vd).DwellLocation CandidateDwells(cd).DwellLocation]);
            end            
        end
    end
    
    if cdPrevSeparation<cdNextSeparation
        if ~isempty(cdPrevSeparation)
            %merge prev cand-dwell with current valid-dwell    
            %cdPrev from CandidateDwells with vd from ValidatedDwells            
            ValidatedDwells(vd).Start         = CandidateDwells(cdPrev).Start;
            %ValidatedDwells.Finish remains unmodified
            ValidatedDwells(vd).Mean          = mean(y(ValidatedDwells(vd).Start:ValidatedDwells(vd).Finish));
            ValidatedDwells(vd).Var           = NaN;
            ValidatedDwells(vd).StartTime     = t(ValidatedDwells(vd).Start); 
            ValidatedDwells(vd).FinishTime    = t(ValidatedDwells(vd).Finish);
            ValidatedDwells(vd).DwellTime     = range([ValidatedDwells(vd).StartTime ValidatedDwells(vd).FinishTime]);
            ValidatedDwells(vd).DwellLocation = ValidatedDwells(vd).Mean;
        end
    else
        if ~isempty(cdNextSeparation)
            %merge next cand-dwell with current valid-dwell
            %cdNext from CandidateDwells with vd from ValidatedDwells
            %ValidatedDwells(vd).Start          remains unmodified 
            ValidatedDwells(vd).Finish        = CandidateDwells(cdNext).Finish;
            ValidatedDwells(vd).Mean          = mean(y(ValidatedDwells(vd).Start:ValidatedDwells(vd).Finish));
            ValidatedDwells(vd).Var           = NaN;
            ValidatedDwells(vd).StartTime     = t(ValidatedDwells(vd).Start); 
            ValidatedDwells(vd).FinishTime    = t(ValidatedDwells(vd).Finish);
            ValidatedDwells(vd).DwellTime     = range([ValidatedDwells(vd).StartTime ValidatedDwells(vd).FinishTime]);
            ValidatedDwells(vd).DwellLocation = ValidatedDwells(vd).Mean;
        end
    end
    
    vd = vd+1; %move on to the next validated dwell
end

% SideHistProp.X - these are various properties of the side-view-histogram computed from the kernel density
% SideHistProp.F 
% SideHistProp.ContrastThr
% SideHistProp.LocalPeakInd     
% SideHistProp.LocalPeakBaseline 
% SideHistProp.LocalPeakHeight 
% SideHistProp.ValidPeakInd  
% SideHistProp.ValidPeakBaseline 
% SideHistProp.ValidPeakHeight 
end