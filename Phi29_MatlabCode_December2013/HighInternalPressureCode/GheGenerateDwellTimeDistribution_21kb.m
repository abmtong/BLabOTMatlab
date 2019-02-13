%%
DwellFile={ '21kb_030310N17.mat',
            '21kb_030310N26.mat',
            '21kb_030310N32.mat',
            '21kb_030310N35.mat',
            '21kb_030410N13.mat',
            '21kb_030410N19.mat',
            '21kb_030410N24.mat',
            '21kb_030810N08.mat',
            '21kb_030810N21.mat',
            '21kb_031010N13.mat',    
            '21kb_031010N16.mat',
            '21kb_031010N22.mat',
            '21kb_031010N24.mat',
            '21kb_031010N26.mat',
            '21kb_031110N19.mat',
            '21kb_031610N22.mat',
            '21kb_031610N27.mat',
            '21kb_031610N29.mat'};
%these files contain the dwell information
DwellFolder='C:\Documents and Settings\Phi29\Desktop\HIP_Analysis\21kb\'; %folder where the dwell files reside

Dwells=[];
for i=1:length(DwellFile)
    clear FinalDwells; %this is where the dwell info is stored
    load([DwellFolder DwellFile{i}]);
    Dwells=[Dwells FinalDwells];
end

%%
%all the dwell info is aggregated in the Dwells data structure (big and ugly)
%BinStart=[15 16 17 18 19 20]; in kb
%BinEnd=[16 17 18 19 20 21]; in kb
a=[6000 5000 4000 3000 2000 1000];;
b=[5000 4000 3000 2000 1000 0];
for i=1:length(a)
    Bin(i).Start = a(i);
    Bin(i).End = b(i);
end

%t stands for "trace"
%s stands for step
Step.Size=[];
Step.Location=[];
Dwell.Location=[];
Dwell.Time=[];

for t=1:length(Dwells)
        Dwell.Time     = [Dwell.Time        Dwells{t}.DwellTime];
        Dwell.Location = [Dwell.Location    Dwells{t}.mean];
        Step.Size      = [Step.Size         -Dwells{t}.StepSize]; %the positive steps make DNA shorter
        Step.Location  = [Step.Location     Dwells{t}.StepLocation];
end
clear Ind;
[Step.Location Ind]=sort(Step.Location); %sort in ascending order
Step.Size=Step.Size(Ind);
clear Ind;
[Dwell.Location Ind] = sort(Dwell.Location); %sort in ascending order
Dwell.Time = Dwell.Time(Ind); 

%% Look into the neighboring dwells
ConsStep.Sum=[]; %consecutive short step sum
ConsStep.Loc=[]; %consecutive short step location
for i=1:length(Dwells)
    DwMean = Dwells{i}.mean;
    L=length(DwMean);
    for j=1:L
        if j~=1 && j~=L %neither the first or the last dwell
            NextStep=DwMean(j)-DwMean(j+1); %forward step is positive by default
            PrevStep=DwMean(j-1)-DwMean(j); 
            if abs(PrevStep)<8 && abs(NextStep)<8 %small steps both before and after the dwell
                ConsStep.Sum = [ConsStep.Sum PrevStep+NextStep];
                ConsStep.Loc = [ConsStep.Loc DwMean(j)]; %location of this dwell
            end
        end
    end
end
clear Ind;
[ConsStep.Loc Ind]=sort(ConsStep.Loc); %sort in ascending order
ConsStep.Sum = ConsStep.Sum(Ind);

%%
clear SmallerThanStart LargerThanEnd;
Ind=[];
for i=1:length(Bin)
   % Bin(i).Start
   % Bin(i).End
    clear SmallerThanStart LargerThanEnd;
    SmallerThanStart    = find(Step.Location < Bin(i).Start);
    LargerThanEnd       = find(Step.Location > Bin(i).End);
    Bin(i).StepSize     = Step.Size(LargerThanEnd(1):SmallerThanStart(end));
    Bin(i).StepLocation = Step.Location(LargerThanEnd(1):SmallerThanStart(end));
    
    clear SmallerThanStart LargerThanEnd;
    SmallerThanStart     = find(Dwell.Location < Bin(i).Start);
    LargerThanEnd        = find(Dwell.Location > Bin(i).End);
    Bin(i).DwellTime     = Dwell.Time(LargerThanEnd(1):SmallerThanStart(end));
    Bin(i).DwellLocation = Dwell.Location(LargerThanEnd(1):SmallerThanStart(end));
    
    clear SmallerThanStart LargerThanEnd;
    SmallerThanStart     = find(ConsStep.Loc < Bin(i).Start);
    LargerThanEnd        = find(ConsStep.Loc > Bin(i).End);
    Bin(i).ConsStepSum  = ConsStep.Sum(LargerThanEnd(1):SmallerThanStart(end));
    Bin(i).ConsStepLoc  = ConsStep.Loc(LargerThanEnd(1):SmallerThanStart(end));
    
end

AllDwells=Dwells;
save('StepsAndDwells_21kb.mat','Step','Dwell','Bin','AllDwells');