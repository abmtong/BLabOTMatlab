function Dwells = GheReviewAbnormalDwells(phageData, Dwells, SlopeThr, StdThr, BinThr)
% This function looks at the slope and std of the dwells and flags the ones
% that are abnormal (very large std and/or slope). Then the function
% attempts to break up the abnormal dwell into two smaller dwells, if
% possible. Those two dwells should pass all the tests we used before (the
% binomial analysis; the minimum step size analysis; the minimum dwell
% duration);
%
% Gheorghe Chistol, May 26, 2010
%

Flag = []; %this is the flag index, the index of all the abnormal dwells
Sgn  = phageData.sgn; %this is the significance value from the t-test analysis
Time = phageData.time;

for i=1:length(Dwells.mean) %go and flag the abnormal dwells
    %if either the slope or the st-dev are too large, flag the dwell
    if (Dwells.std(i)>=StdThr) || (Dwells.slope(i)>=SlopeThr)
        Flag = [Flag i];
    end
end

%% Review the flagged dwells, try to split them into two smaller dwells (for now)
for i=1:length(Flag);
    %search for a local minimum in the sgn value
    time = Time(Dwells.start(Flag(i)):Dwells.end(Flag(i))); %this is the sgn data corresponding to this dwell
    sgn = Sgn(Dwells.start(Flag(i)):Dwells.end(Flag(i))); %this is the sgn data corresponding to this dwell
    %clip the sides of the sgn data set until sgn stops decreasing (this is to make sure that we find the proper local minimum later)
    %clip from the end first
    
    %plot the results, for diagnostic purposes
    %figure;
    %semilogy(time,sgn,'-k');
    %hold on;
    %semilogy(time(Ind),sgn(Ind),'ob');
    
    
    k=length(sgn)-3; %starting point for clipping: at the end
    while (sgn(k)>=sgn(k+1))
        k=k-1; %move back, sgn still decreasing 
    end
    finish=k;
    
    %now clip from the beginning
    k=3; %starting point at the beginning
    while sgn(k)>=sgn(k-1)
        k=k+1; %move forward, sgn still decreasing
    end
    start=k;
    
    LocalMin = min(sgn(start:finish)); %find the local minimum
    Ind = find(sgn(start:finish)==LocalMin); %get the index of the local minimum
    if ~isempty(Ind)
        Ind = Ind(1); %in case there are more than one local minima found
        Ind=Ind+start-1; %account for the offset
    
    %plot the results, for diagnostic purposes
    figure;
    semilogy(time,sgn,'-k');
    hold on;
    semilogy(time(Ind),sgn(Ind),'ob');
    
    %semilogy(Time,Sgn,'-k');
    %hold on;
    %semilogy(Time(Ind-1+Dwells.start(Flag(i))),Sgn(Ind-1+Dwells.start(Flag(i))),'ob');
   
    %We found the tentative division of the dwell into two dwells
    start(1)  = Dwells.start(Flag(i)); %The beginning of the 1st dwell, in terms of the index of the whole trace
    finish(1) = Ind-1+Dwells.start(Flag(i)); %the end of the 1st dwell
    start(2)  = finish(1)+1; %the beginning of the 2nd dwell
    finish(2) = Dwells.end(Flag(i)); %the end of the 2nd dwell
    
    %Check using the binomial analysis, the rest of the tests (min-step and
    %min-dwell) will be done later
    %dwells.Npts(cd) = total number of points in this current dwell
    data{1} = phageData.contour(start(1):finish(1)); %contour data for 1st tentative dwell
    data{2} = phageData.contour(start(2):finish(2)); %contour data for 2nd tentative dwell
    Npts(1) = length(data{1}); %number of points in dwell 1
    Npts(2) = length(data{2}); %number of points in dwell 2
    NptsAbove(1) = length(find(data{1}>=mean([data{1} data{2}]))); %# of points above the common mean from Dwell 1
    NptsAbove(2) = length(find(data{2}>=mean([data{1} data{2}]))); %# of points above the common mean from Dwell 2
    Verdict{1} = GheBinomialVerdict(NptsAbove(1),Npts(1),BinThr); %Calculate the binomial verdict for dwell 1
    Verdict{2} = GheBinomialVerdict(NptsAbove(2),Npts(2),BinThr); %Calculate the binomial verdict for dwell 2
    %if verdict=='diff'; %this dwell is independent
    %if verdict=='same'; %this dwell is no different from the inital pd dwell
    
    %If either of the tentative dwells passes the binomial test (i.e.
    %Verdict=='diff') then we approve the division, || means OR
    if strcmp(Verdict{1},'diff') || strcmp(Verdict{2},'diff')
        disp('PassedBinomialSeparationTest');
        %go ahead and split this dwell into two
        %shift everything by one dwell to the right
        Dwells.start(Flag(i)+1:end+1)=Dwells.start(Flag(i):end); 
        Dwells.end(Flag(i)+1:end+1)=Dwells.end(Flag(i):end); 
        Dwells.mean(Flag(i)+1:end+1)=Dwells.mean(Flag(i):end); 
        Dwells.std(Flag(i)+1:end+1)=Dwells.std(Flag(i):end); 
        Dwells.Npts(Flag(i)+1:end+1)=Dwells.Npts(Flag(i):end); 
        
        %now update the values 
        Dwells.start(Flag(i))   = start(1); 
        Dwells.start(Flag(i)+1) = start(2); 
        Dwells.end(Flag(i))     = finish(1);
        Dwells.end(Flag(i)+1)   = finish(2);
        Dwells.mean(Flag(i))    = mean(data{1});
        Dwells.mean(Flag(i)+1)  = mean(data{2});
        Dwells.std(Flag(i))     = std(data{1});
        Dwells.std(Flag(i)+1)   = std(data{2});
        Dwells.Npts(Flag(i))    = Npts(1);
        Dwells.Npts(Flag(i)+1)  = Npts(2);
    end
    end
end
