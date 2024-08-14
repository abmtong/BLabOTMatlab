function out = prepDcP_RnaSeq(nucseqs, maxn, seqperchunk)
%Prep for input for DNAcycP, an ML tool that predicts DNA cyclizibility
% Converts NPSes from @getNucSeqs to DNAcycP input .fasta
% See paper: https://doi.org/10.1093/nar/gkac162 and code: https://github.com/jipingw/DNAcycP

%Process nucseqs: remove chrM (mitochondrial DNA)
ki = find(strcmp({nucseqs.chr},'chrM'));
if ki
    nucseqs(ki) = [];
end

% onlygene = 1; %Only do genes, so skip 0 genes. ...?

%Maximum number of 'chunks' (NPSes / seqperchunk, integer) per strandedness (-/0/+/b), for limiting runtime
% e.g., if 25 is 'enough' then don't bother running the whole 200+ chunks the entire NPS set would be
if nargin < 2
    maxn = 100;
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
tpms = [nucseqs.tpm];

%Sort into gene type
out = { seqs(nfos == -1) seqs(nfos == 0) seqs(nfos == 1) seqs(nfos == 2); tpms(nfos == -1) tpms(nfos == 0) tpms(nfos == 1) tpms(nfos == 2) };

%Write to FASTA
fid = fopen('DcPin.fasta','w');
chrlabel = 'mzpb'; %Minus, Zero, Plus, Both for gene strandedness
for i = [1 3 4 2] ; %Process in order - + b 0, since we don't care about 0 as much
    %Remove seqs with non-standard nucleotides
    tmp = upper( out{1,i} );
    ki = cellfun(@(x) all( x == 'A' | x == 'G' | x == 'C' | x == 'T' ), tmp);
    tmp = tmp(ki);
    fprintf('Rejected %d of %d (%0.2f%%) NPSes for group %d\n', sum(~ki), length(ki), sum(~ki)/length(ki), i-2)
    %Need to also save the truncation, and apply it to out2
    out{1,i} = tmp;
    out{2,i} = out{2,i}(ki);
    %Randomize tmp, but in a replicable way [set rng seed to 0, then call randperm]
    sd = rng;
    rng(0);
    rp = randperm(length(tmp));
    out{1,i} = out{1,i}(rp);
    out{2,i} = out{2,i}(rp);
    rng(sd); %Revert RNG seed
    %Calculate how many chunks to chop to
    nwrite = ceil(length(tmp) / seqperchunk);
    %Limit nwrite to maxn
    nwrite = min( nwrite, maxn );
    %Make sure nwrite < 999, so 03d doesnt overflow
    if nwrite > 999
        warning('Too many data, truncating. Change files to have more digits to fix')
        nwrite = 999;
    end
    
    for j = 1:nwrite
        %Write >Name line
        fprintf(fid, '>Genes_%s%03d\n', chrlabel(i) , j); %Name must be without spaces; underscore before %s%d is used later to group files
        %Write sequence
        fprintf(fid, '%s\n', [tmp{(j-1)*seqperchunk+1: min(j*seqperchunk, end)}]);
    end
end
fclose(fid);
fprintf('prepDcP finished in %0.2fs\n', toc(stT))

%Save TPM info
tpmdat = out(2,:); %#ok<NASGU>
save('DcPin_TPM.mat', 'tpmdat')

%Then run DNAcycP on this fasta (outside Matlab)
%Install instructions (Windows 10 + Anaconda, Nvidia GPU):
% Install Nvidia CUDA 11.2 (this is the specific ver. for Tensorflow, https://developer.nvidia.com/cuda-toolkit-archive, I used 11.2.0)
% Download DNAcycP files (https://github.com/jipingw/DNAcycP)
% If installing Anaconda from scratch, install Anaconda , then update (>>conda update --all)
%  Make a new env in Anaconda (e.g. >>conda create -n dnacycp)% Open Anaconda cmd in this env, nav to DNAcycP folder, run >>pip install .
%   Okay, reinstalling it on another PC, there's more things to do (eg installing CUDNN), but you'll get it. Maybe https://www.tensorflow.org/install/pip#windows-native_1 will help.
% I ran with the TF_FORCE_GPU_ALLOW_GROWTH env variable set to true to limit VRAM usage to only what's needed (~5GB)
%  (>>conda env config vars set TF_FORCE_GPU_ALLOW_GROWTH=true)
% (Can theoretically run in WSL2, but I didn't manage to get it to work with CUDA)
%Run instructions:
% Move DcPin.fasta to the DNAcycP folder
% Nav to DNAcycP folder in the DNAcycP env, run >>dnacycp-cli -f DcPin.fasta dcpout
% This will output txt files named e.g. dcpout_cycle_Genes_1m.txt, each ~143MB in size (at default 3e6bp per chunk)
%  These texts can be imported to Matlab with @prepDcPp2
% On a 12700F/4070Ti, each 3e6bp sequence takes ~5 minutes

