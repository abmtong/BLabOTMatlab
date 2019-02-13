function[RawBurstsMatrix CompletedBurstsMatrix]=SortingStepSizes(ThisStep,CompletedCycle)

RawBurstsMatrix=[];
CompletedBurstsMatrix=[];


    for i=1:6; % it will separate the data in 6 bins
        LowLimit=((i-1)*2.5)+1.25;
        TopLimit=(i*2.5+1.25);
        ind=(ThisStep> LowLimit & ThisStep<TopLimit);
        RawBurstsMatrix(i,:)=ThisStep(ind);   
        CompletedBurstsMatrix(i,:)=CompletedCycle(ind);
    end
end