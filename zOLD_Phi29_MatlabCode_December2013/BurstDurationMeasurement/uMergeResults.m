function MergedData = uMergeResults(DNA,Results)
% vargin(1) - dna length
%               BurstSize: [1x163 double]
%            BurstSizeErr: [1x163 double]
%           BurstLocation: [1x163 double]
%     DurationDwellBefore: [1x163 double]
%      DurationDwellAfter: [1x163 double]
%
% USE: MergedData = uMergeResults(DNA,Results)
%
% Gheorghe Chistol, 03 Jan 2012
%
% DNA = [6000 18000 21000] %the lengths of DNA tethers
% Results = [Results_6kb Results_18kb Results_21kb]

    CapsidFilling = [];
    BurstSize     = [];
    for i=1:length(DNA)
        CapsidFilling = [CapsidFilling DNA(i)-Results(i).BurstLocation];
        BurstSize     = [BurstSize     Results(i).BurstSize];
    end
    
    MergedData.BurstLocation = CapsidFilling;
    MergedData.BurstSize = BurstSize;
end