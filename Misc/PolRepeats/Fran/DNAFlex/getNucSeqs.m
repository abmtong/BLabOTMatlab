function out = getNucSeqs(chrseq, nucpos, inOpts)
%Returns the nucleosome sequences as defined by nucpos

%Inputs: chrseq as a struct: chrseq.(<chr_name>) = <chr_sequence>
%        nucpos as the output of procNucMap: nucpos.(<chr_name>).nucpos(1) and nucpos.(<chr_name>).nucpos(2) are arrays of start/end positions

opts.method = 3; %Method choice
opts.pad = 30;  %Method 1: Pad N bps on each side. Requires each NPS to be the same length
opts.nbp = 201; %Method 2/3: Put the scored nuc position in the center, and grab this many bps
                %Use Method 2 for even nbp, 3 for odd (could check this but whatever)
               %   The centering algorithm for this method still seems wrong: x and fliplr(x) are off by 1bp ish
               %   Is the positioning code 0-indexed? Just add 1?
               %   Or, since the true NPS is 'odd' (147), we should be dealing with odd no.s?
if nargin > 2
    opts = handleOpts(opts, inOpts);
end

%Handle batch
if iscell(nucpos)
    out = cellfun(@(x) getNucSeqs(chrseq, x, opts), nucpos, 'Un', 0);
    return
end

wid = floor(opts.nbp/2);
nchr = length(chrseq);
nskip = 0; %Count number of skipped nucleosomes. Should be at most nchr *2
for i = nchr:-1:1
    %Sequence
    seq = chrseq(i).seq;
    
    %Find corresponding index in nucpos, since they might not be the same
    ii = find( strcmp( chrseq(i).chr, {nucpos.chr} ) );
    if isempty(ii)
        continue
    end
    nnuc = size(nucpos(ii).nucpos,1);
    %Location of genes: 1 if it is in a + gene, -1 if in a rev gene
    ngene = size( chrseq(i).gendat, 1);
    genmap = zeros(size(seq));
    for j = 1:ngene
        genmap( chrseq(i).gendat(j,1) : chrseq(i).gendat(j,2) ) = chrseq(i).gendat(j,3)*2-1;
    end
    
    outnuc = cell(1,nnuc);
    nucnfo = zeros(1,nnuc); %Returns if this gene is in a fwd or rev gene
    for j = 1:nnuc
        switch opts.method
            case 1 %Pad on both sides of a fixed NPS length
                try
                    outnuc{j} = seq( nucpos(ii).nucpos(j,1) - opts.pad : nucpos(ii).nucpos(j,2) + opts.pad );
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
                outnuc{j} = seq(st:en);
            otherwise
        end

        
        %Check if this is inside a gene
        genmapsnip = genmap( nucpos(ii).nucpos(j,1) : nucpos(ii).nucpos(j,2) );
        nucnfo(j) =  max([0 genmapsnip]) + min([0 genmapsnip]); %1 if in fwd gene, -1 if rev, 0 if neither/both
    end
    out(i).chr = chrseq(i).chr;
    out(i).nucseq = outnuc;
    out(i).nucnfo = nucnfo;
end

if nskip > 2*nchr
    warning('Many nucleosome positions were skipped, check for e.g. chromosome name matching')
end
