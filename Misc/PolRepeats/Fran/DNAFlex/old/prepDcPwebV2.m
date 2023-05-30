function out = prepDcPwebV2(nucseqs)
%Prep for input for DNAcycP webserver (https://cyclizability.stats.northwestern.edu/)
% DNAcycP predicts DNA cyclizibility, usually used as a proxy for flexibility

%Get a sample of -, 0, and + genes
out = arrayfun(@(x) prepDcPwebV2_helper(nucseqs, x), -1:1, 'Un', 0);