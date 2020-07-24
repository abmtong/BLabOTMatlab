function dwellsUpdated=GheCheckAllCurrentDwells(phageData, dwellsPrev, dwells, BinThresh)
%   Take the tentative dwells and analyze them one by one, accepting and
% rejecting them based on the binomial probabilities. We compare the dwells
% identified in the previous round with the dwells identified in the
% current round of analysis. It's a refining algorythm, so we expect more
% dwells in the current round (or at least the same number as in the
% previous round). Some of the Previous Dwells (pd) will now be broken up
% into more than one Current Dwells (cd), while some will remain unchanged.
% We will go through each Previous Dwell (pd) and check home many Current
% Dwells it contains. If it contains more than one, we will verify whether
% each of the current dwells is a valid dwell on its own (i.e. most of the
% points are in fact above the mean of the previous dwell) or it is simply
% part of the Previous Dwell. Each of the Current Dwells is given a
% verdict: either "same" or "diff". "diff" means the current dwell is
% distinct from the previous dwell.
%
%Gheorghe Chistol, May 24, 2010

% Create an empty data structure that will contain the updated dwell info
dwellsUpdated.start = [];
dwellsUpdated.end = [];
dwellsUpdated.mean = [];
dwellsUpdated.std = [];
dwellsUpdated.Npts = [];
dwellsUpdated.NptsAbove = [];

for pd = 1:length(dwellsPrev.mean)
    % we are only working with the current trace phageData, dwellsPrev, and dwells
    % pd = previous dwell index
    % cd = current dwell index
    % the following are defined within a given previous dwell = pd
    % ctFirst = the first current transition
    % ctLast  = the last current transition
    
    %find the CurrentDwells (cd) that start in the PreviousDwell (pd)
    StartHere=[]; %the index of the cd that start in this particular pd
    for i=1:length(dwells.mean)
        if dwells.start(i)>=dwellsPrev.start(pd) && dwells.start(i)<=dwellsPrev.end(pd)
            StartHere=[StartHere i]; %add to the list of indices
        end
    end
    
    if isempty(StartHere) %none found
        cdFirst=[];
        cdLast=[];
    else
        cdFirst = StartHere(1);
        cdLast = StartHere(end);
    end

    %each pd has a subset of cd starting from cdFirst to cdLast
    %verify if a given cd in the [cdFirst ... cdLast] interval is consistent with being an independent dwell
    
    for cd=cdFirst:cdLast %calculate the # of pts above, give a verdict
        %dwells.Npts(cd) = total number of points in this current dwell
        %dwellsPrev.mean(pd) = mean of the larger, previous dwell (cd is subset of the pd)
        %NptsAbove = number of points above the mean in this current dwell cd
        temp = phageData.contour(dwells.start(cd):dwells.end(cd)); %contour data for this dwell
        dwells.NptsAbove(cd) = length(find(temp>=dwellsPrev.mean(pd))); %save to the data structure
        dwells.verdict{cd}=GheBinomialVerdict(dwells.NptsAbove(cd),dwells.Npts(cd),BinThresh); %Calculate the binomial verdict            
        %if verdict=='diff'; %this dwell is independent
        %if verdict=='same'; %this dwell is no different from the inital pd dwell
        %at this point all cd dwells within the pd dwell have been tagged
        %see if any adjacent dwells are actually compatible (having been separated by some noise fluke)
    end
    
    if isempty(cdFirst)
        %we got nothing, move on
        %disp('empty');
    elseif cdFirst==cdLast %only one subdwell detected
        dwellsUpdated.start = [dwellsUpdated.start dwells.start(cdFirst)];
        dwellsUpdated.end = [dwellsUpdated.end dwells.end(cdFirst)];
        dwellsUpdated.mean = [dwellsUpdated.mean dwells.mean(cdFirst)];
        dwellsUpdated.std = [dwellsUpdated.std dwells.std(cdFirst)];
        dwellsUpdated.Npts = [dwellsUpdated.Npts dwells.Npts(cdFirst)];
        dwellsUpdated.NptsAbove = [dwellsUpdated.NptsAbove dwells.NptsAbove(cdFirst)];
    else %multiple subdwells detected
        cd=cdFirst;
        while cd<=cdLast %work within the big dwell
            if strcmp(dwells.verdict{cd},'same') 
                start=cd; %stating point for this indexing
                finish=cd; %starting condition
                verdict='same';
                while (strcmp(verdict,'same') && (cd<=cdLast))
                    if cd<cdLast
                        finish=cd; %ending point for this indexing
                        cd=cd+1; %go to the next subdwell
                        verdict=dwells.verdict{cd};
                    else %this is the last one, verdict is different, exit loop
                        verdict='end';
                        finish=cd;
                        cd=cd+1;
                    end
                end
                dwellsUpdated.start = [dwellsUpdated.start dwells.start(start)];
                dwellsUpdated.end = [dwellsUpdated.end dwells.end(finish)];
                dwellsUpdated.mean = [dwellsUpdated.mean mean(phageData.contour(dwellsUpdated.start(end):dwellsUpdated.end(end)))];
                dwellsUpdated.std = [dwellsUpdated.std std(phageData.contour(dwellsUpdated.start(end):dwellsUpdated.end(end)))];
                dwellsUpdated.Npts = [dwellsUpdated.Npts dwells.start(finish)-dwells.start(start)+1];
                dwellsUpdated.NptsAbove = [dwellsUpdated.NptsAbove length(find(phageData.contour(dwellsUpdated.start(end):dwellsUpdated.end(end))>dwellsUpdated.mean(end)))];
                %disp('same');
            else %if it's a distinct subdwell
                start=cd; %stating point for this indexing
                finish=cd; %starting condition
                verdict='diff';
                while (strcmp(verdict,'diff') && (cd<=cdLast))
                    if cd<cdLast;
                        finish=cd; %ending point for this indexing
                        cd=cd+1; %go to the next subdwell
                        verdict=dwells.verdict{cd};
                    else %this is the last one
                        verdict='end'; %the verdict is neither "same" or "diff", exit loop
                        finish=cd;
                        cd=cd+1;
                    end
                end
                
                dwellsUpdated.start = [dwellsUpdated.start dwells.start(start)];
                dwellsUpdated.end = [dwellsUpdated.end dwells.end(finish)];
                dwellsUpdated.mean = [dwellsUpdated.mean mean(phageData.contour(dwellsUpdated.start(end):dwellsUpdated.end(end)))];
                dwellsUpdated.std = [dwellsUpdated.std std(phageData.contour(dwellsUpdated.start(end):dwellsUpdated.end(end)))];
                dwellsUpdated.Npts = [dwellsUpdated.Npts dwells.start(finish)-dwells.start(start)+1];
                dwellsUpdated.NptsAbove = [dwellsUpdated.NptsAbove length(find(phageData.contour(dwellsUpdated.start(end):dwellsUpdated.end(end))>dwellsUpdated.mean(end)))];
                %disp('diff');
            end
        end
    end
end
