%%
DwellFile={ 'Straight_030310N37.mat'};
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

%t stands for "trace"
%s stands for step
Step.Size=[];
Step.Location=[];
Dwell.Location=[];
Dwell.Time=[];

for t=1:length(Dwells)
        Dwell.Time     = [Dwell.Time        Dwells{t}.DwellTime];
        Dwell.Location = [Dwell.Location    Dwells{t}.mean];
        Step.Size      = [Step.Size         -Dwells{t}.StepSize];
        Step.Location  = [Step.Location     Dwells{t}.StepLocation];
end
clear Ind;
[Step.Location Ind]=sort(Step.Location); %sort in ascending order
Step.Size=Step.Size(Ind);
clear Ind;
[Dwell.Location Ind] = sort(Dwell.Location); %sort in ascending order
Dwell.Time = Dwell.Time(Ind); 


save('StepsAndDwells_EmptyCapsid.mat','Step','Dwell');