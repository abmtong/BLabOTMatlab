function out = getNucSeqs_RnaSeqv2(chrseq, nucpos, inOpts)
%Returns the nucleosome sequences as defined by nucpos

%Inputs: chrseq is output of procGenome, contains sequence and annotation info
%        nucpos as the output of procNucMap: nucpos.(<chr_name>).nucpos(1) and nucpos.(<chr_name>).nucpos(2) are arrays of start/end positions

opts.method = 3; %Method choice
opts.pad = 30;  %Method 1: Pad N bps on each side. Requires each NPS to be the same length
opts.nbp = 301; %Method 2/3: Put the scored nuc position in the center, and grab this many bps
                %Use Method 2 for even nbp, 3 for odd (could check this but whatever)
               %   The centering algorithm for this method still seems wrong: x and fliplr(x) are off by 1bp ish
               %   Is the positioning code 0-indexed? Just add 1?
               %   Or, since the true NPS is 'odd' (147), we should be dealing with odd no.s?
               %   Choose a length so it also contains the (average) linker length
if nargin > 2
    opts = handleOpts(opts, inOpts);
end

%Handle batch
if iscell(nucpos)
    out = cellfun(@(x) getNucSeqs_RnaSeqv2(chrseq, x, opts), nucpos, 'Un', 0);
    return
end

stT = tic;

wid = floor(opts.nbp/2);
nchr = length(chrseq);
nskip = 0; %Count number of skipped nucleosomes. Should be at most nchr *2
for i = nchr:-1:1
    %Skip Mito DNA
    if strcmp('chrM', chrseq(i).chr)
        warning('Skipping Mitochondrial DNA')
        continue
    end
    
    %Sequence
    seq = chrseq(i).seq;
    
    %Find corresponding index in nucpos, since they might not be the same
    ii = find( strcmp( chrseq(i).chr, {nucpos.chr} ) );
    if isempty(ii)
        continue
    end
    nnuc = size(nucpos(ii).nucpos,1);
    %Location of genes: = gene# if in a gene (separated by - and +)
    ngene = size( chrseq(i).gendat, 1);
    genmapp = zeros(size(seq)); %'gene map plus'
    genmapm = zeros(size(seq)); %'gene map minus'NA-Seq 
    genmaptpm = nan(size(seq)); %'gene map TPM' [Rchannel]
    for j = 1:ngene
        if chrseq(i).gendat(j,3) %+ gene
            genmapp( chrseq(i).gendat(j,1) : chrseq(i).gendat(j,2) ) = j;
        else %- gene
            genmapm( chrseq(i).gendat(j,1) : chrseq(i).gendat(j,2) ) = j;
        end
        %And RNA-seq data. Use max TPM if there's overlapping genes
        genmaptpm( chrseq(i).gendat(j,1) : chrseq(i).gendat(j,2) ) = max( chrseq(i).tpm(j), genmaptpm( chrseq(i).gendat(j,1) : chrseq(i).gendat(j,2) ), 'omitnan');
    end

    outnuc = cell(1,nnuc);
    outgenidp = zeros(1,nnuc); %Gene ID, plus strand
    outgenidm = zeros(1,nnuc); %Gene ID, minus strand
    nucnfo = zeros(1,nnuc); %Returns if this gene is in a fwd or rev gene
    nucloc = zeros(1,nnuc); %Dyad location, bp
    gentpm = nan(1,nnuc); %TPM score
    for j = 1:nnuc
        switch opts.method
            case 1 %Pad on both sides of a fixed NPS length
                try
                    outnuc{j} = seq( nucpos(ii).nucpos(j,1) - opts.pad : nucpos(ii).nucpos(j,2) + opts.pad );
                    nucloc(j) = round( (nucpos(ii).nucpos(j,1)+nucpos(ii).nucpos(j,2)) /2);
                catch %Instead of checking for boundaries, just skip ones near the edges
                    fprintf('Skipped nuc on %s on %d-%d\n', nucpos(ii).chr, nucpos(ii).nucpos(j,1), nucpos(ii).nucpos(j,2))
                    nskip = nskip + 1;
                    continue
                end
            case 2 %Pad to a fixed even length
                %Get the center of the sequence, use floor() for halves
                ctr = floor( mean( nucpos(ii).nucpos(j,:) )+0.5 ); %e.g. [1, 2] gives 2, [1, 3] gives 2
                %Get the left and right edges
                st = ctr - wid;
                en = ctr + wid-1;
                %Let's just skip ones close to the sequence edges...
                if st < 1 || en > length(seq)
                    fprintf('Skipped nuc on %s on %d-%d\n', nucpos(ii).chr, nucpos(ii).nucpos(j,1), nucpos(ii).nucpos(j,2))
                    continue
                end
                nucloc(j) = ctr;
                outnuc{j} = seq(st:en);
            case 3 %Pad to a fixed odd length
                %Get the center of the sequence, use floor() for even-length seqs: works better for DANPOS?
                ctr = floor( mean( nucpos(ii).nucpos(j,:) ) ); %e.g. [1, 1] gives 2, [1, 3] gives 2
                %Get the left and right edges
                st = ctr - wid;
                en = ctr + wid;
                %Let's just skip ones close to the sequence edges...
                if st < 1 || en > length(seq)
                    fprintf('Skipped nuc on %s on %d-%d\n', nucpos(ii).chr, nucpos(ii).nucpos(j,1), nucpos(ii).nucpos(j,2))
                    continue
                end
                nucloc(j) = ctr;
                outnuc{j} = seq(st:en);
            otherwise
        end
        %Check if this is inside a gene
        isp = max( genmapp( nucpos(ii).nucpos(j,1) : nucpos(ii).nucpos(j,2) ) );
        ism = max( genmapm( nucpos(ii).nucpos(j,1) : nucpos(ii).nucpos(j,2) ) );
        %1 if in fwd gene, -1 if rev, 0 if neither, 2 if both
        if isp && ism
            nucnfo(j) = 2;
            outgenidp(j) = isp;
            outgenidm(j) = ism;
            %No gene name has '+', just [A-Z][gene][-]
        elseif isp
            nucnfo(j) = 1;
            outgenidp(j) = isp;
        elseif ism
            nucnfo(j) = -1;
            outgenidm(j) = ism;
        end
        
        %Get RNA seq. Use value at dyad.
        try
            gentpm(j) = genmaptpm( round( (nucpos(ii).nucpos(j,1) + nucpos(ii).nucpos(j,2))/2 ) );
        catch
            %Failed, just skip
            % Maybe warn here
        end
    end
    
    %Assign nucleosome %s
    nucnump = nan(1,nnuc);
    nucnumm = nan(1,nnuc);
    for j = 1:ngene
        %Gather indicies of nucs in this gene
        tfkeep = (outgenidp==j) | (outgenidm==j);
        nucids = find(tfkeep);
        
        if ~isempty(nucids)
            %Sort by pos, either ascend or descend based on name
            if chrseq(i).gendat(j,3) %+ gene
                [~, si] = sort( nucloc(nucids), 'ascend' );
                nucnump(nucids) = si;
            else %- genee
                [~, si] = sort( nucloc(nucids), 'descend' );
                nucnumm(nucids) = si;
            end
        end
    end
    
    %Remove empty cells = failed extractions
    ki = ~cellfun(@isempty,outnuc);
    %And save to output
    out(i).chr = chrseq(i).chr;
    out(i).nucpos = nucloc(ki);
    out(i).nucseq = outnuc(ki);
    out(i).nucnfo = nucnfo(ki);
    out(i).tpm = gentpm(ki);
    out(i).genep = outgenidp(ki);
    out(i).genem = outgenidm(ki);
    out(i).nump = nucnump(ki);
    out(i).numm = nucnumm(ki);
end



fprintf('getNucSeqs finished in %0.2fs\n', toc(stT))

if nskip > 2*nchr
    warning('Many nucleosome positions were skipped, check for e.g. chromosome name matching')
end
