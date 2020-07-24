function Fragmentation = WordWrap_PartitionBurst(BurstSize)
% this function is given a burst size (normally 10bp) and it breaks it up
% into 4 substeps, then merges some of these substeps to simulate burst
% fragmentation in phi29. The burst can consist of the following
% fragmentation patterns:
% 
% 2.5bp + 2.5bp + 2.5bp + 2.5bp
% 2.5bp + 2.5bp + 5bp
% 2.5bp + 7.5bp
% 2.5bp + 5bp + 2.5bp
% 5bp + 2.5bp + 2.5bp
% 5bp + 5bp
% 7.5bp + 2.5bp
% 10bp
%
% USE: Fragmentation = WordWrap_PartitionBurst(BurstSize)
%
% Gheorghe Chistol, 15 Feb 2013


    FragmentationPattern{1} = [1 1 1 1]/4;
    FragmentationPattern{2} = [1 1 2]/4;
    FragmentationPattern{3} = [1 2 1]/4;
    FragmentationPattern{4} = [2 1 1]/4;
    FragmentationPattern{5} = [1 3]/4;
    FragmentationPattern{6} = [2 2]/4;
    FragmentationPattern{7} = [3 1]/4;
    FragmentationPattern{8} = [4]/4;

    i = randi(length(FragmentationPattern),1);
    Fragmentation = FragmentationPattern{i}*BurstSize;
end





