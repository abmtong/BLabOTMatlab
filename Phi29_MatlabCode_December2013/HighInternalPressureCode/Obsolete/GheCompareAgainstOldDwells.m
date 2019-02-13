function NewDwells=GheCompareAgainstOldDwells(phageData, OldDwells, NewDwells, BinThr)
% OUTDATED/OBSOLETE
% Compare every single "new" dwell against the "old: dwells, keep the old
% dwells if they are better.
%
% USE: NewDwells=GheCompareAgainstOldDwells(phageData, OldDwells, NewDwells, BinThr)
%
% Gheorghe Chistol, May 28t, 2010

%The data structure NewDwells will not stay constant in size, since we may
%delete or add new dwells, so use the "while" loop instead of a regular
%"for" loop. Go through each new dwell and check it against old dwells that
%have significant overlap with the new dwell (say 70% overlap or more)
i=1; %starting point - at the beginning
while i<=length(NewDwells.mean)
    %go through the old dwells and find the ones that have any overlap with
    %the current "new" dwell.
    NewVector = zeros(1,length(phageData.contour)); %create zero vector
    NewVector(NewDwells.start(i):NewDwells.end(i))=1; %put ones where the new dwell exists
        
    clear Overlap Npts NptsAbove OldDwellInd data start finish; %clear the temporary data structure that contains information about the overlap of the previous "New" Dwell
    
    for j=1:length(OldDwells.mean) %find the old dwells with significant overlap
        %make a vector the length of the entire phageData.contour data
        %have ones where the OldDwells(j) exists, and zeros everywhere else.
        %Dot this vector with the corresponding vector for the
        %NewDwells(i). The non-zero entries of this dotted product should
        %give you the overlap between the two.
        OldVector = zeros(1,length(phageData.contour)); %create zero vector
        OldVector(OldDwells.start(j):OldDwells.end(j))=1; %put ones where the old dwell exists
        temp = NewVector.*OldVector; %the non-zero entries correspond to the points where the old and the new dwells overlap
        
        %if we have a more than 70% overlap, we're can investigate further,
        %save the overlap data in the Overlap data structure
        if sum(temp)>=0.7*sum(OldVector)
            if ~exist('Overlap','var') %if Overlap data structure is non-existent, create it
                OldDwellInd(1) = j; %the index of the old dwell
                Overlap{1} = temp; %# of points of overlap
                Npts(1) = length(OldVector);
                start  = OldDwells.start(j);
                finish = OldDwells.end(j);
                data = phageData.contour(start:finish);
                NptsAbove(1) = length(find(data>NewDwells.mean(i))); %# of pts from the old dwell that are above the mean of the new dwell
            else
                OldDwellInd(end+1)=j;
                Overlap{end+1}=temp; %append at the end of the existing data structure
                Npts(end+1) = length(OldVector);
                start  = OldDwells.start(j);
                finish = OldDwells.end(j);
                data = phageData.contour(start:finish);
                NptsAbove(end+1) = length(find(data>NewDwells.mean(i))); %# of pts from the old dwell that are above the mean of the new dwell
            end
        end
    end
    %if exist('Overlap','var')
    %    disp(num2str(length(Overlap)));
    %else
    %    disp('0');
    %end
    %Look at all Old Dwells with significant overlap with the current New
    %Dwell and do a Binomial Analysis verification (if there are more than
    %one, if there's just one, then we're looking at esentially the same
    %dwell, so just keep the new one). More precisely: find NptsAbove for
    %every Old Dwell (with overlap) with respect to the mean of the New
    %Dwell. Given NptsAbove, check if the old dwell passes the binomial
    %test.
    
    status='whole'; %the new dwell hasn't been split yet
    %status tells the script whether the new dwell has been split or not.
    %If the new dwell has been split because an old dwell fit the data
    %better, end the refinement process, increase the counter i, and move
    %on, the next cycle of analysis will deal with the rest
    
    if exist('Overlap','var')
        if length(Overlap)>1 %if there are more than one overlap
            k=1; %start looking through the old dwells that overlap with the current dwell
            while k<=length(Overlap) && ~strcmp(status,'split') 
                %as long as we have overlapping old dwells to look at and the
                %new dwell hasn't been split

                %Calculate the Binomial Verdict
                Verdict{k} = GheBinomialVerdict(NptsAbove(k), Npts(k),BinThr); 
                %the verdict can either be "diff" or "same"
                if k==1 && strcmp(Verdict{k},'diff') %if the very first old dwell is different , keep the old dwell, 
                    %Right now we're at the i-th New Dwell and at the
                    %OldDwellInd(k)-th Old Dwell
                    status='split'; %we split the new dwell
                    
                    %shift everything by one dwell to the right
                    NewDwells.start(i+1:end+1) = NewDwells.start(i:end);
                    NewDwells.end(i+1:end+1)   = NewDwells.end(i:end);
                    NewDwells.Npts(i+1:end+1)  = NewDwells.Npts(i:end);
                    NewDwells.mean(i+1:end+1)  = NewDwells.mean(i:end);
                    NewDwells.std(i+1:end+1)   = NewDwells.std(i:end);

                    %record the old dwell in the NewDwells structure
                    NewDwells.start(i) = OldDwells.start(OldDwellInd(k));
                    NewDwells.end(i)   = OldDwells.end(OldDwellInd(k));
                    NewDwells.Npts(i)  = OldDwells.Npts(OldDwellInd(k));
                    NewDwells.mean(i)  = OldDwells.mean(OldDwellInd(k));
                    NewDwells.std(i)   = OldDwells.std(OldDwellInd(k));
                    
                    if i~=1 %if this is not the first new dwell
                        %update the (i-1)th dwell to reflect the new changes
                        NewDwells.end(i-1)   = NewDwells.start(i)-1;
                        data = phageData.contour(NewDwells.start(i-1):NewDwells.end(i-1));
                        NewDwells.Npts(i-1)  = length(data);
                        NewDwells.mean(i-1)  = mean(data);
                        NewDwells.std(i-1)   = std(data);
                    end
                    
                    %update the (i+1)th New Dwell to reflect the new changes 
                    %the end remains the same, the start was altered
                    NewDwells.start(i+1) = NewDwells.end(i)+1; %this one starts where the other one ended
                    data = phageData.contour(NewDwells.start(i+1):NewDwells.end(i+1));
                    NewDwells.Npts(i+1)  = length(data);
                    NewDwells.mean(i+1)  = mean(data);
                    NewDwells.std(i+1)   = std(data);
                    
                    i=i+1; %increment i by one
                    %k=k+1;
                elseif k~=1 && k~=length(Overlap) && strcmp(Verdict{k},'diff') %if an old dwell other than the first or last one is different
                    %keep the first part of the new dwell that is good; replace
                    %the middle part of the new dwell with the old dwell that
                    %fits the data better; and keep the last part of the new
                    %dwell
                    status='split'; %we split the new dwell
                    %Right now we're at the i-th New Dwell and at the
                    %OldDwellInd(k)-th Old Dwell

                    %shift everything by two dwells to the right
                    NewDwells.start(i+2:end+2) = NewDwells.start(i:end);
                    NewDwells.end(i+2:end+2)   = NewDwells.end(i:end);
                    NewDwells.Npts(i+2:end+2)  = NewDwells.Npts(i:end);
                    NewDwells.mean(i+2:end+2)  = NewDwells.mean(i:end);
                    NewDwells.std(i+2:end+2)   = NewDwells.std(i:end);

                    %the first portion of the new dwell becomes an independend
                    %dwell, update the end, Npts, mean, and std, the start
                    %remains unchanged
                    NewDwells.end(i)   = OldDwells.start(OldDwellInd(k))-1; %ends right before the 'diff' old dwell starts
                    data = phageData.contour(NewDwells.start(i):NewDwells.end(i)); %contour length data corresponding to the new dwell
                    NewDwells.Npts(i)  = length(data);
                    NewDwells.mean(i)  = mean(data);
                    NewDwells.std(i)   = std(data);

                    %update the (i+1)th New Dwell to reflect the fact that
                    %we're keeping the old dwell. 
                    NewDwells.start(i+1) = OldDwells.start(OldDwellInd(k)); %starts where the old dwell started
                    NewDwells.end(i+1)   = OldDwells.end(OldDwellInd(k)); %ends where the old dwell ended
                    %update the Npts, mean, and std accordingly, they remain the same as the old dwell
                    NewDwells.Npts(i+1)  = OldDwells.Npts(OldDwellInd(k));
                    NewDwells.mean(i+1)  = OldDwells.mean(OldDwellInd(k));
                    NewDwells.std(i+1)   = OldDwells.std(OldDwellInd(k));

                    %the last portion of what used to be the i-th new dwell
                    %becomes an independent dwell, update the start, Npts,
                    %mean, and std, the end remains unchanged
                    NewDwells.start(i+2)   = NewDwells.end(i+1)+1; %starts right after the previous one ended
                    data = phageData.contour(NewDwells.start(i+2):NewDwells.end(i+2)); %contour length data corresponding to the new dwell
                    NewDwells.Npts(i+2)  = length(data);
                    NewDwells.mean(i+2)  = mean(data);
                    NewDwells.std(i+2)   = std(data);
                    i=i+2; %increment i by two since (i)th and (i+1)th dwells are all set
                    %k=k+1;
                elseif k==length(Overlap) && strcmp(Verdict{k},'diff') 
                    %if the last old dwell is different, split the new dwell in
                    %two: first part remains the same, the second part is
                    %replaced by the old dwell which fits the data better
                    status='split'; %we split the new dwell
                    %Right now we're at the i-th New Dwell and at the
                    %OldDwellInd(k)-th Old Dwell
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
                    NewDwells.end(i) = OldDwells.start(OldDwellInd(k))-1; %this one ends where the next one starts
                    data = phageData.contour(NewDwells.start(i):NewDwells.end(i));
                    NewDwells.Npts(i)  = length(data);
                    NewDwells.mean(i)  = mean(data);
                    NewDwells.std(i)   = std(data);

                    %Incorporate the old dwell that fits the data better in the NewDwells structure
                    NewDwells.start(i+1) = OldDwells.start(OldDwellInd(k));
                    NewDwells.end(i+1)   = OldDwells.end(OldDwellInd(k));
                    NewDwells.Npts(i+1)  = OldDwells.Npts(OldDwellInd(k));
                    NewDwells.mean(i+1)  = OldDwells.mean(OldDwellInd(k));
                    NewDwells.std(i+1)   = OldDwells.std(OldDwellInd(k));
                    
                    %the (i)th new dwell is now set
                    %the (i+1)th new dwell is also set (i.e. the old dwell that fit the data better)
                    %the (i+2)th new dwell is now what used to be the (i+1)th dwell due to having introduced an extra dwell in there
                    if i~=length(NewData.mean) %if this wasn't the last new dwell
                        %update the (i+2)th New Dwell to reflect the new changes 
                        NewDwells.start(i+2) = NewDwells.end(i+1)+1;
                        data = phageData.contour(NewDwells.start(i+2):NewDwells.end(i+2));
                        NewDwells.Npts(i+2)  = length(data);
                        NewDwells.mean(i+2)  = mean(data);
                        NewDwells.std(i+2)   = std(data);
                    end
                    i=i+2; %increment i by two, (i)th and (i+1)th dwells are all set
                else 
                    i=i+1; %nothing changes
                    k=k+1; %increment k, which refers to the index of the Overlapping old dwells
                end
            end
        
        else%there is only one overlapping old dwell
            %if the std is lower on the old dwell, keep that one,
            %otherwise keep the new dwell
            k=1; %there is only one old dwell overlapping with the new dwell
            if OldDwells.std(OldDwellInd(k)) < NewDwells.std(i)
                %the old dwell fits the data better, incorporate the old dwell in the NewDwells structure
                NewDwells.start(i) = OldDwells.start(OldDwellInd(k));
                NewDwells.end(i)   = OldDwells.end(OldDwellInd(k));
                NewDwells.Npts(i)  = OldDwells.Npts(OldDwellInd(k));
                NewDwells.mean(i)  = OldDwells.mean(OldDwellInd(k));
                NewDwells.std(i)   = OldDwells.std(OldDwellInd(k));
                
                if i~=1 %if this is not the first NewDwell 
                    %correct the prev NewDwell, if there is a previous dwell
                    NewDwells.end(i-1) = NewDwells.start(i)-1;
                    data = phageData.contour(NewDwells.start(i-1):NewDwells.end(i-1));
                    NewDwells.Npts(i-1)  = length(data);
                    NewDwells.mean(i-1)  = mean(data);
                    NewDwells.std(i-1)   = std(data);
                end
                
                if i~=length(NewDwells.mean) %if this is not the last NewDwell
                    %correct the next NewDwell if there is a next dwell
                    NewDwells.start(i+1) = NewDwells.end(i)+1;
                    data = phageData.contour(NewDwells.start(i+1):NewDwells.end(i+1));
                    NewDwells.Npts(i+1)  = length(data);
                    NewDwells.mean(i+1)  = mean(data);
                    NewDwells.std(i+1)   = std(data);                
                end
            end
            i=i+1; %increment the new dwell counter i
        end
    else
        i=i+1; %there is no significant overlap with any of the old dwells, move on
    end
    
end
    
