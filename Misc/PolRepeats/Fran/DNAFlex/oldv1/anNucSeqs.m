function anNucSeqs(nucseqs, inOpts)
%Analyzes the output of getNucSeqs

% opts.tfflip = 0; %Flip based on gene direction?
opts.filwid = 3; %Filter data. Might not be necessary if N seqs is large enough
opts.name = ''; %Name for plotNucSeqs
opts.flexmeth = 1; %Flexibility estimation method, see @calcflex

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if iscell(nucseqs)
    cellfun(@(x,y)anNucSeqs(x, setfield(opts, 'name', sprintf('%s_%d', opts.name, y) )),nucseqs, num2cell(1:length(nucseqs)))
    return
end

%It is thought that, so should 'average' smaller than that

%Encode AT=0 GC=1

%Ignore mitochondrial DNA ? There shouldn't be histones in it (though there are some hits there)
indmit = find(strcmp( {nucseqs.chr}, 'chrM' ));
if indmit
    nucseqs(indmit) = [];
end

%Get seqs
seqs = [nucseqs.nucseq];
nfos = [nucseqs.nucnfo];
%Crop empty
ki = ~cellfun(@isempty,seqs);
seqs = seqs(ki);
nfos = nfos(ki);

plotNucSeqsFlipV2(seqs, nfos, opts)
% 
% %Seqs not flipped
% seqsraw = seqs;
% 
% %Seqs flipped
% for i = 1:length(seqs)
%     if nfos(i) == -1
%         seqs{i} = seqrcomplement(seqs{i});
%     end
% end

% %Plot all data
% plotNucSeqs(seqs, setfield(opts, 'name', 'AllData %s, With Flipping'))
% plotNucSeqs(seqsraw, setfield(opts, 'name', 'AllData %s, With Flipping'))

%Just in genes
% plotNucSeqs(seqs( nfos ~= 0 ), setfield(opts, 'name', 'GeneData %s, With Flipping'))
% plotNucSeqs(seqsraw( nfos ~= 0 ), setfield(opts, 'name', 'GeneData %s, No Flipping'))

% plotNucSeqsFlip(seqsraw, seqs, setfield(opts, 'name', 'NucSeqs vs Flip'))
% plotNucSeqsFlip(seqsraw( nfos ~= 0 ), seqs( nfos ~= 0 ), setfield(opts, 'name', 'NucSeqs vs Flip'))
% plotNucSeqsFlip(seqs( nfos ~= 0 ), seqsraw( nfos ~= 0 ), setfield(opts, 'name', 'NucSeqs vs Flip'))


% %Just out of genes
% plotNucSeqs(seqs( nfos == 0 ), setfield(opts, 'name', sprintf('NonGenesOnly %s', flipstr)))

























