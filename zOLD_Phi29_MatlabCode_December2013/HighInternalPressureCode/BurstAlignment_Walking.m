function [FinalPenalty FinalPenaltyPerBurst NumberOfBursts FinalDwellCandidate]=BurstAlignment_Walking(TrialBurstSize,DwellStaircase,DwellStErr,StepSize,DwellTime)
% This function looks for bursts by walking forward and calculating
% penalties. At the end, the best dwell candidates are plotted and fitted
% to a straight line whose slope equals the optimal burst size. The linear
% fit is also used to generate the best burst distribution
%
% Gheorghe Chistol, 28 Dec 2010

% --- Searching for a penalty minimum
% Start the penalty walk anywhere within the first 2*TestBurstSize 
% If the penalty increases for NoProgressStepsMax consecutive steps, 
% then further exploration is abandoned
NoProgressRoundsMax=5; %if the penalty increases for 5 consecutive steps, further exploration is abandoned

%cycle through the Trial Burst Sizes
for tbs=1:length(TrialBurstSize)
    %Find all the dwells that are within a burst size from the end of the
    %trace. These dwells won't be allowed as a starting dwell because those bursts might be incomplete
    ForbiddenStartDwells = find( (DwellStaircase-min(DwellStaircase))<TrialBurstSize(tbs) );

    StartDwellPool = find(abs(DwellStaircase)<TrialBurstSize(tbs)); %the pool of dwells where we can start our penalty search/exploration
    TotalPenalty   = zeros(1,length(StartDwellPool)); %initialize the penalty of all bursts for a given member of the StartDwellPool
    clear ReconstructedDwellCandidate;

    for i=1:length(StartDwellPool) %cycle through the StartDwellPool
        sd=StartDwellPool(i); %initialize the StartingDwellIndex
        b=1;  %initialize the BurstIndex
        ReconstructedDwellCandidate{i}(1)=DwellStaircase(sd); %the list of all the reconstructed dwell candidates (where burst candidates end/start) 

        while sd<min(ForbiddenStartDwells) %as long as we're not too close to the end of the trace
        %while sd<length(DwellStaircase)-1 %sd is the Starting Dwell index
            %calculate the penalty forward
            PenaltyMinimumSearchStatus=1;
            d=sd+1; %calculate the penalty for the dwell immediately following the Start Dwell
            NoProgressRounds   = 0;  %the number of rounds in which penalty increases continuously 
            %BurstStartIndex(b) = sd; %this is where the current burst candidate starts
            Penalty=[]; %reset the penalty, this keeps track of all rounds of the current search

            %Continue the search, as long as the search is allowed and you haven't
            %reached the end of the DwellStaircase. The search is allowed if the
            %penalty increases in NoProgressStepsMax consecutive steps
            while PenaltyMinimumSearchStatus==1 && d<=length(DwellStaircase)
                %compute the penalty for the d-th dwell
                Penalty(d-sd)=BurstAlignment_ComputePenalty(DwellStaircase(sd), DwellStaircase(d),...
                                                            DwellStErr(sd),     DwellStErr(d),...
                                                            TrialBurstSize(tbs));
                if (d-sd)>1 %we are more than one step away from the start, we have at least two penalties to compare
                    if Penalty(end)<Penalty(end-1) %if the current penalty is smaller than the previous penalty
                        NoProgressRounds=0; %we've made progress in our burst search, explore further
                    else
                        NoProgressRounds=NoProgressRounds+1; %another round where we made no progress
                        if NoProgressRounds>NoProgressRoundsMax || d==length(DwellStaircase)
                            %second condition avoids referencing non-existent data after the trace is finished
                            PenaltyMinimumSearchStatus=0; %stop the search
                        end
                    end
                end
                d=d+1; %increment the dwell counter
            end

            %we now found a local penalty minimum
            MinInd = find(Penalty==min(Penalty));
            MinInd = MinInd(1);%just in case Penalty=0 and there are more than one minima
            TotalPenalty(i) = TotalPenalty(i)+Penalty(MinInd); %add the penalty of the most recently found burst to the total penalty of the current configuration
            ReconstructedDwellCandidate{i}(end+1)=DwellStaircase(sd+MinInd);

            % DwellBefore = DwellStaircase(sd);
            % DwellAfter  = DwellStaircase(sd+MinInd);
            % if logical(rem(b,2)) %if it's an odd-numbered burst, plot shading
            %     BurstAlignment_DrawShading(DwellBefore,DwellAfter,gca);%shade the burst (or not depending on whether the previous burst was shaded)
            % end
            % BurstStopIndex(b)   = sd+MinInd;

            sd=sd+MinInd; %the next StartDwell will start where the current burst ended
        end
    end

    %compute the penalty per burst
    for i=1:length(TotalPenalty)
        NumberOfBursts(i)  = length(ReconstructedDwellCandidate{i})-1; %there are one less bursts than dwells
        PenaltyPerBurst(i) = TotalPenalty(i)/NumberOfBursts(i);
    end
    BestSolution = find(PenaltyPerBurst==min(PenaltyPerBurst));
    BestSolution = BestSolution(1); %just in case there are two equally good solutions
    
    FinalPenalty(tbs)=TotalPenalty(BestSolution);
    FinalDwellCandidate{tbs}=ReconstructedDwellCandidate{BestSolution};
    FinalPenaltyPerBurst(tbs)=PenaltyPerBurst(BestSolution);
    
    for i=1:length(FinalPenalty)
        NumberOfBursts(i)  = length(FinalDwellCandidate{i})-1; %there are one less bursts than dwells
    end
    %  figure; bar(PenaltyPerBurst);
    %  title(['Trial Burst Size: ' num2str(TrialBurstSize(tbs)) 'bp']);
    %  ylabel('Penalty Per Burst');
    %  xlabel('Starting Dwell Index');
    
%    BurstAlignment_PlotStepping(StepSize, DwellTime, DwellStErr); hold on;
%    for k=1:length(FinalDwellCandidate{tbs})-1
%        DwellBefore = FinalDwellCandidate{tbs}(k);
%        DwellAfter  = FinalDwellCandidate{tbs}(k+1);
%        if logical(rem(k,2))
%            BurstAlignment_DrawShading(DwellBefore,DwellAfter,gca,'m');
%        else
%            BurstAlignment_DrawShading(DwellBefore,DwellAfter,gca,'g');
%        end
%    end
%    title(['Trial Burst Size: ' num2str(TrialBurstSize(tbs)) 'bp']);
end