function [NewDwells,i] = GheDealWithOnlyOneOverlap(PhageData,NewDwells,OldDwells,OverlapInd,BinThr,Nmin,i)
% This is a script which is part of the GheCompareNewVersusOldDwells.m
% function, but I had to take it out separately for readability reasons.
% Revised June 10
%
% Gheorghe Chistol, May 31, 2010

%If there is only one old dwell overlapping with the current new dwell
%There are two possible cases: Perfect-Match or the Old Dwell is larger than the new dwell
if OldDwells.Npts(OverlapInd)==NewDwells.Npts(i)
    %We have a perfect match, keep the new dwell, increment counter
    i=i+1;
    %disp('    GheDealWithOnlyOneOverlap: We have a perfect dwell match');
else
    %The Old Dwell is larger than the New Dwell
    data      = PhageData.contour(NewDwells.start(i):NewDwells.end(i)); %the extent of the current New Dwell
    NptsAbove = length(find(data>OldDwells.mean(OverlapInd))); %# of points in the new dwell that are above the mean of the old dwell
    Npts      = NewDwells.Npts(i); %# of pts in the current new dwell
    %Calculate the Binomial Verdict
    Verdict   = GheBinomialVerdict(NptsAbove, Npts, BinThr); %the verdict can either be "diff" or "same"            

    if strcmp(Verdict,'diff')
        %If the new dwell is statistically different from the old one, keep the new dwell                
        i=i+1; %increment counter, keeping new dwell
        %disp('    GheDealWithOnlyOneOverlap: New Dwell is distinct from the old dwell');
    else
        %if the new dwell is not statistically distinct
        %We could a portion of the old dwell span the previous new dwell
        %and/or the next new dwell. We need to check whether those overlaps
        %belong to those neighboring dwells or to the current new dwell.
        
        %% If the OldDwell overlaps with the Previous NewDwell deal with it
        if i~=1 %i==1 doesn't work since there is no previous dwell
            % If the overlap of the OldDwell with the previous NewDwell is
            % fairly small we can try to cut off the Previous NewDwell where the OldDwell Starts
            % TempCurrNewDwell is the new dwell starting where the OldDwell started
            % TempPrevNewDwell is the previous new dwell terminated right before the OldDwell started
            % Compare the Std of the TempCurrNewDwell with that of the current NewDwell
            % Compare the Std of the TempPrevNewDwell with that of the prev NewDwell
            % if the Std goes down in both cases adopt TempCurrNewDwell and
            % TempPrevNewDwell as valid dwells, otherwise keep the current
            % dwell intact.
            
            % calculate how much the OldDwell overlaps with the previous New Dwell
            if NewDwells.end(i-1)>=OldDwells.start(OverlapInd);
                OverlapWithPrevDwell = OldDwells.start(OverlapInd)-NewDwells.end(i-1)+1;
            else
                OverlapWithPrevDwell = []; %empty
            end
            
            %if the overlap is less than half the Npts of the PrevNewDwell
            %proceed with the Std comparison
            if ~isempty(OverlapWithPrevDwell) && OverlapWithPrevDwell<NewDwells.Npts(i-1)/2
                TempCurrNewDwell.start = OldDwells.start(OverlapInd);
                TempCurrNewDwell.end   = NewDwells.end(i);
                TempCurrNewDwell.mean  = mean(PhageData.contour(TempCurrNewDwell.start:TempCurrNewDwell.end));
                TempCurrNewDwell.std   = std(PhageData.contour(TempCurrNewDwell.start:TempCurrNewDwell.end));
                TempCurrNewDwell.Npts  = length(PhageData.contour(TempCurrNewDwell.start:TempCurrNewDwell.end));

                TempPrevNewDwell.start = NewDwells.start(i-1);
                TempPrevNewDwell.end   = OldDwells.start(OverlapInd)-1; %ends before the other one starts
                TempPrevNewDwell.mean  = mean(PhageData.contour(TempPrevNewDwell.start:TempPrevNewDwell.end));
                TempPrevNewDwell.std   = std(PhageData.contour(TempPrevNewDwell.start:TempPrevNewDwell.end));
                TempPrevNewDwell.Npts  = length(PhageData.contour(TempPrevNewDwell.start:TempPrevNewDwell.end));
                
                %compare the Standard Deviations
                if TempCurrNewDwell.std<NewDwells.std(i) && TempPrevNewDwell.std<NewDwells.std(i-1)
                    %it is more advantageous to split the next dwell where
                    %the OldDwell ends and merge that with the new dwell
                    NewDwells.start(i) = TempCurrNewDwell.start; %the end doesn't change in this case
                    NewDwells.mean(i)  = TempCurrNewDwell.mean;
                    NewDwells.std(i)   = TempCurrNewDwell.std;
                    NewDwells.Npts(i)  = TempCurrNewDwell.Npts;
                    %Make the necessary changes to the previous dwell
                    NewDwells.end(i-1)   = TempPrevNewDwell.end; %the start doesn't change in this case
                    NewDwells.mean(i-1)  = TempPrevNewDwell.mean;
                    NewDwells.std(i-1)   = TempPrevNewDwell.std;
                    NewDwells.Npts(i-1)  = TempPrevNewDwell.Npts;
                    %don't increment i, we need to inspect the end of the
                    %OldDwell too
                %else
                    %we're keeping the Current NewDwell as is
                    %until we can find something better
                end
            end
        end
        %% If the OldDwell overlaps with the Next NewDwell deal with it
        if i~=length(NewDwells.mean) %anything by the very last dwell
            % If the overlap of the OldDwell with the Next NewDwell is
            % fairly small we can try to cut off the Next NewDwell where
            % the OldDwell ends
% TempCurrNewDwell: the current new dwell ending where the OldDwell ended
% TempNextNewDwell: the next new dwell starting after OldDwell ended
            % Compare the Std of the TempCurrNewDwell with that of the current NewDwell
            % Compare the Std of the TempNextNewDwell with that of the next NewDwell
            % if the Std goes down in both cases adopt TempCurrNewDwell and
            % TempNextNewDwell as valid dwells, otherwise keep the current
            % dwell intact.
            
            % calculate how much the OldDwell overlaps with the next New Dwell
            if NewDwells.start(i+1)<=OldDwells.end(OverlapInd);
                OverlapWithNextDwell = NewDwells.start(i+1)-OldDwells.end(OverlapInd)+1;
            else
                OverlapWithNextDwell = []; %empty
            end
            
            %if the overlap is less than half the Npts of the NextNewDwell
            %proceed with the Std comparison
            clear TempCurrNewDwell; %just in case I mess something up
            if ~isempty(OverlapWithNextDwell) && OverlapWithNextDwell<NewDwells.Npts(i+1)/2
                TempCurrNewDwell.end   = OldDwells.end(OverlapInd);
                TempCurrNewDwell.start = NewDwells.start(i);
                TempCurrNewDwell.mean  = mean(PhageData.contour(TempCurrNewDwell.start:TempCurrNewDwell.end));
                TempCurrNewDwell.std   = std(PhageData.contour(TempCurrNewDwell.start:TempCurrNewDwell.end));
                TempCurrNewDwell.Npts  = length(PhageData.contour(TempCurrNewDwell.start:TempCurrNewDwell.end));

                TempNextNewDwell.start = OldDwells.end(OverlapInd)+1;
                TempNextNewDwell.end   = NewDwells.start(i+1);
                TempNextNewDwell.mean  = mean(PhageData.contour(TempNextNewDwell.start:TempNextNewDwell.end));
                TempNextNewDwell.std   = std(PhageData.contour(TempNextNewDwell.start:TempNextNewDwell.end));
                TempNextNewDwell.Npts  = length(PhageData.contour(TempNextNewDwell.start:TempNextNewDwell.end));
                
                %compare the Standard Deviations
                if TempCurrNewDwell.std<NewDwells.std(i) && TempNextNewDwell.std<NewDwells.std(i+1)
                    %it is more advantageous to split the next dwell where
                    %the OldDwell ends and merge that with the new dwell
                    NewDwells.end(i)  = TempCurrNewDwell.end; %the start doesn't change in this case
                    NewDwells.mean(i) = TempCurrNewDwell.mean;
                    NewDwells.std(i)  = TempCurrNewDwell.std;
                    NewDwells.Npts(i) = TempCurrNewDwell.Npts;
                    %Make the necessary changes to the previous dwell
                    NewDwells.start(i+1) = TempNextNewDwell.start; %the end doesn't change in this case
                    NewDwells.mean(i+1)  = TempNextNewDwell.mean;
                    NewDwells.std(i+1)   = TempNextNewDwell.std;
                    NewDwells.Npts(i+1)  = TempNextNewDwell.Npts;
                end
            end
        end
        i=i+1; %increment the Current New Dwell counter, we're done with the current new dwell
    end
end