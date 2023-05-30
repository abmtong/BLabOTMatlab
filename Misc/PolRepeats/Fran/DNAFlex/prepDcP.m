function out = prepDcP(nucseqs, maxn, seqperchunk)
%Prep for input for DNAcycP, an ML tool that predicts DNA cyclizibility
% Converts NPSes from @getNucSeqs to DNAcycP input .fasta
% See paper: https://doi.org/10.1093/nar/gkac162 and code: https://github.com/jipingw/DNAcycP

%Process nucseqs: remove chrM (mitochondrial DNA)
ki = find(strcmp({nucseqs.chr},'chrM'));
if ki
    nucseqs(ki) = [];
end

%Maximum number of 'chunks' (NPSes / seqperchunk, integer) per strandedness (-/0/+/b), for limiting runtime
% e.g., if 25 is 'enough' then don't bother running the whole 200+ chunks the entire NPS set would be
if nargin < 2
    maxn = 25;
end

%Maximum number of NPSes per 'chunk' fed to DNAcycP. Too high and you can run out of RAM? And gives you incremental outputs
if nargin < 3
seqperchunk = 1e4; %So 1e4*300 = 3e6 bp
end
%Max number of chunks per file is dictated by maxn

stT = tic;

%Concatenate nucseqs
seqs = [nucseqs.nucseq];
nfos = [nucseqs.nucnfo];

%Sort into gene type
out = { seqs(nfos == -1) seqs(nfos == 0) seqs(nfos == 1) seqs(nfos == 2) };

%Write to FASTA
fid = fopen('DcPin.fasta','w');
chrlabel = 'mzpb'; %Minus, Zero, Plus, Both for gene strandedness
for i = 1:4
    %Remove seqs with non-standard nucleotides
    tmp = upper( out{i} );
    ki = cellfun(@(x) all( x == 'A' | x == 'G' | x == 'C' | x == 'T' ), tmp);
    tmp = tmp(ki);
    fprintf('Rejected %d of %d (%0.2f%%) NPSes for group %d\n', sum(~ki), length(ki), sum(~ki)/length(ki), i-2)
    %Randomize tmp, but in a replicable way [set rng seed to 0]
    sd = rng;
    rng(0);
    rng(sd);
    tmp = tmp(randperm(numel(tmp)));
    %Calculate how many chunks to chop to
    nwrite = ceil(length(tmp) / seqperchunk);
    %Limit nwrite to maxn
    nwrite = min( nwrite, maxn );
    for j = 1:nwrite
        %Write >Name line
        fprintf(fid, '>Genes_%s%d\n', chrlabel(i) , j); %Name must be without spaces; underscore before %s%d is used later to group files
        %Write sequence
        fprintf(fid, '%s\n', [tmp{(j-1)*seqperchunk+1: min(j*seqperchunk, end)}]);
    end
end
fclose(fid);
fprintf('prepDcP finished in %0.2fs\n', toc(stT))

%Then run DNAcycP on this fasta (outside Matlab)
%Install instructions (Windows 10 + Anaconda, Nvidia GPU):
% Install Nvidia CUDA 11.2 (this is the specific ver. for Tensorflow, https://developer.nvidia.com/cuda-toolkit-archive, I used 11.2.0)
% Download DNAcycP files from github (https://github.com/jipingw/DNAcycP)
% Make a new env in Anaconda
% Open Anaconda cmd in this env, nav to DNAcycP folder, run >>pip install .
% I ran with the TF_FORCE_GPU_ALLOW_GROWTH env variable set to true to limit VRAM usage to only what's needed (~5GB)
%  (>>conda env config vars set TF_FORCE_GPU_ALLOW_GROWTH=true)
% (Can theoretically run in WSL2, but I didn't manage to get it to work with CUDA)
%Run instructions:
% Move DcPin.fasta to the DNAcycP folder
% Nav to DNAcycP folder in the DNAcycP env, run >>dnacycp-cli -f DcPin.fasta dcpout
% This will output txt files named e.g. dcpout_cycle_Genes_1m.txt, each ~143MB in size (at default 3e6bp per chunk)
%  These texts can be imported to Matlab with @prepDcPp2
% On a 12700F/4070Ti, each 3e6bp sequence takes ~5 minutes

