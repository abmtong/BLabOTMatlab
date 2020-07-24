function [NewDwells,i,k,status] = GheDealWithCompleteOverlap(phageData,NewDwells,OldDwells,OverlapInd,BinThr,i,k,status,NptsAbove,Npts)
% revised Gheorghe Chistol, 10 June, 2010

%if we have a complete overlap on our hands
Verdict = GheBinomialVerdict(NptsAbove(k), Npts(k), BinThr); 
%the verdict can either be "diff" or "same"

if k==1 && strcmp(Verdict,'diff') %if the very first old dwell is different , keep the old dwell, split the new dwell
    status='split'; %we split the new dwell
    disp('    GheDealWithCompleteOverlap: Splitting the new dwell at the start');
    %shift everything by one dwell to the right
    NewDwells.start(i+1:end+1) = NewDwells.start(i:end);
    NewDwells.end(i+1:end+1)   = NewDwells.end(i:end);
    NewDwells.Npts(i+1:end+1)  = NewDwells.Npts(i:end);
    NewDwells.mean(i+1:end+1)  = NewDwells.mean(i:end);
    NewDwells.std(i+1:end+1)   = NewDwells.std(i:end);

    %record the old dwell in the NewDwells structure
    %NewDwells.start(i) = OldDwells.start(OverlapInd(1)); %the start remains the same
    NewDwells.end(i)   = OldDwells.end(OverlapInd(k));
    NewDwells.Npts(i)  = OldDwells.Npts(OverlapInd(k));
    NewDwells.mean(i)  = OldDwells.mean(OverlapInd(k));
    NewDwells.std(i)   = OldDwells.std(OverlapInd(k));
    %there is no need to update the (i-1)th new dwell, as it wasn't affected
    
    %update the (i+1)th New Dwell to reflect the new changes 
    %the end remains the same, the start was altered
    NewDwells.start(i+1) = NewDwells.end(i)+1; %this one starts where the other one ended
    data = phageData.contour(NewDwells.start(i+1):NewDwells.end(i+1));
    NewDwells.Npts(i+1)  = length(data);
    NewDwells.mean(i+1)  = mean(data);
    NewDwells.std(i+1)   = std(data);

    i=i+1; %increment i by one
elseif k~=length(OverlapInd) && strcmp(Verdict,'diff') %k~=1 and the old dwell is statistically distinct from the current new dwell
    %keep the first part of the new dwell that is good; replace
    %the middle part of the new dwell with the old dwell that
    %fits the data better; and keep the last part of the new dwell
    status='split'; %we split the new dwell
    disp('    GheDealWithCompleteOverlap: Splitting the new dwell in the middle');
    %shift everything by two dwells to the right
    NewDwells.start(i+2:end+2) = NewDwells.start(i:end);
    NewDwells.end(i+2:end+2)   = NewDwells.end(i:end);
    NewDwells.Npts(i+2:end+2)  = NewDwells.Npts(i:end);
    NewDwells.mean(i+2:end+2)  = NewDwells.mean(i:end);
    NewDwells.std(i+2:end+2)   = NewDwells.std(i:end);

    %the first portion of the new dwell becomes an independent dwell,
    %update the end only
    NewDwells.end(i)   = OldDwells.start(OverlapInd(k))-1; %ends right before the 'diff' old dwell starts
    data = phageData.contour(NewDwells.start(i):NewDwells.end(i)); %contour length data corresponding to the new dwell
    NewDwells.Npts(i)  = length(data);
    NewDwells.mean(i)  = mean(data);
    NewDwells.std(i)   = std(data);

    %update the (i+1)th New Dwell to reflect the changes
    NewDwells.start(i+1) = OldDwells.start(OverlapInd(k)); %starts where the old dwell started
    NewDwells.end(i+1)   = OldDwells.end(OverlapInd(k)); %ends where the old dwell ended
    %update the Npts, mean, and std accordingly, they remain the same as the old dwell
    NewDwells.Npts(i+1)  = OldDwells.Npts(OverlapInd(k));
    NewDwells.mean(i+1)  = OldDwells.mean(OverlapInd(k));
    NewDwells.std(i+1)   = OldDwells.std(OverlapInd(k));

    %the last portion of what used to be the i-th new dwell
    %becomes an independent dwell, update the start, Npts,
    %mean, and std, the end remains unchanged
    NewDwells.start(i+2)   = NewDwells.end(i+1)+1; %starts right after the previous one ended
    data = phageData.contour(NewDwells.start(i+2):NewDwells.end(i+2)); %contour length data corresponding to the new dwell
    NewDwells.Npts(i+2)  = length(data);
    NewDwells.mean(i+2)  = mean(data);
    NewDwells.std(i+2)   = std(data);
    i=i+2; %increment i by two since (i)th and (i+1)th dwells are all set
elseif k==length(OverlapInd) && strcmp(Verdict,'diff') 
    %if the last old dwell is different, split the new dwell in
    %two: first part remains the same, the second part is
    %replaced by the old dwell which fits the data better
    status='split'; %we split the new dwell
    disp('    GheDealWithCompleteOverlap: Splitting the new dwell at the end');
    %shift everything by one dwell to the right
    NewDwells.start(i+1:end+1) = NewDwells.start(i:end);
    NewDwells.end(i+1:end+1)   = NewDwells.end(i:end);
    NewDwells.Npts(i+1:end+1)  = NewDwells.Npts(i:end);
    NewDwells.mean(i+1:end+1)  = NewDwells.mean(i:end);
    NewDwells.std(i+1:end+1)   = NewDwells.std(i:end);

    %Update the (i)th New Dwell to reflect the fact that
    %we're keeping the old dwell. Basically we're breaking up
    %what used to be i-th New Dwell into two, and keeping only
    %the first half (the second half was replaced by the old
    %dwell that fits the data better)
    NewDwells.end(i) = OldDwells.start(OverlapInd(k))-1;
    data = phageData.contour(NewDwells.start(i):NewDwells.end(i));
    NewDwells.Npts(i)  = length(data);
    NewDwells.mean(i)  = mean(data);
    NewDwells.std(i)   = std(data);

    %Incorporate the old dwell that fits the data better in the NewDwells structure
    NewDwells.start(i+1) = OldDwells.start(OverlapInd(k));
    NewDwells.end(i+1)   = OldDwells.end(OverlapInd(k));
    NewDwells.Npts(i+1)  = OldDwells.Npts(OverlapInd(k));
    NewDwells.mean(i+1)  = OldDwells.mean(OverlapInd(k));
    NewDwells.std(i+1)   = OldDwells.std(OverlapInd(k));

    %the (i)th new dwell is now set
    %the (i+1)th new dwell is also set (i.e. the old dwell that fit the data better)
    %the (i+2)th new dwell is now what used to be the (i+1)th dwell due to having introduced an extra dwell in there
    %no need to update the (i+2)th new dwell
    i=i+2; %increment i by two, (i)th and (i+1)th dwells are all set
elseif k==length(OverlapInd) && strcmp(Verdict,'same')
    %reached the end of the overlapping old dwells, end of the current new
    %dwell
    disp('    GheDealWithCompleteOverlap: Reached the end of the overlapping old dwells');
    i=i+1;
    k=k+1; %k will be larger than length(OverlapInd) and the loop will end
    
elseif k<=length(OverlapInd)
    disp('    GheDealWithCompleteOverlap: Satisfied with this dwell as is');
    %haven't reached the end of the overlapping old dwells, and Verdict=='same'
    %not much to do, satisfied with the current new dwell as is
    k=k+1; %increment k, which refers to the index of the Overlapping old dwells
    %we want to make k larger than length(OverlapInd) to end the loop
    
end

