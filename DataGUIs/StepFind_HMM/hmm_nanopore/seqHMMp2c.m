function [out, outres] = seqHMMp2c(tr, res, trueseq, inOpts)
%Get the section aligned in seqHMM, then go through the sequence to try to 'force' the fit into the real values' fit
%Using regions of NANCHpts+ as 'anchors', find poorly-sequenced regions of NGAP or less in length
%Fit the requisite number of steps to that region, and then  ... hmm

%Maybe need to do/take inspiration from some of Laszlo's methods here
%
%Hmm not sure how to handle backtracks here. Only use (for now) with no btprb


opts.verbose = 0;
opts.nc = 4;
opts.sig = 1;
opts.trnsprb = 1e-10;
opts.ntmin = [6 10];%Nucleotide window, for 1 vs 2 gap size

if nargin > 4
    opts = handleOpts(opts, inOpts);
end

nc = opts.nc;

%Align sequences
la = localalign(trueseq, res.seqn, 'Alphabet', 'nt', 'GapOpen', 8); %Should consider increasing GapOpenValue since we dont want gaps
aln = la.Alignment{1};

% %We want at least the edge codons to be 'correct', meaning 4-length alignment.
% 
% %Find runs of 4. Use strfind
% bars = aln(2,:);
% sf = strfind(bars, '||||');
% %If fewer than 2 runs exist, can't continue
% if length(sf)<2
%     out = [];
% end
% 
% %Adjust indicies to match the sequence by removing '-'s and adding Start index
% sf1 = la.Start(1)-1+ [ sf(1) - sum( aln(1,1:sf(1)) == '-' ), sf(end) - sum( aln( 1,1:sf(end) ) == '-'  ) ];
% sf2 = la.Start(2)-1+ [ sf(1) - sum( aln(3,1:sf(1)) == '-' ), sf(end) - sum( aln( 3,1:sf(end) ) == '-'  ) ];
% 
% %Get aligned sequence
% tseqcrp = trueseq(sf1(1):sf1(2));
% 
% %Get data in tr of the kept nucleotides
% [in, ~] = tra2ind(res.fiti);
% trcrp = tr( in(nc -1 + (sf2(1))):in(sf2(2)) );

%Get trace indexes in tr of the kept nucleotides
[in, ~] = tra2ind(res.fiti);
%Pad in on the left to put in sync with seq
in = [zeros(1,nc-1) in];
seq = res.seqn;

%Find misalignments
ki = aln(2,:) == ' ';
df = diff([0 ki 0]);
stI = find(df == 1);
enI = find(df == -1)-1;
nnI = enI-stI+1;
ok = [];

debugmsg = 0;

for i = length(stI):-1:1 %Work backwards so we can update in on the fly without changing indicies
    %For each mismatch, see if the aligned bases before/after are long enough
    if i == 1
        if length(stI) == 1
            win = [1 length(ki)]; %Special case, only one gap mismatch.
        else
            win = [1 stI(i+1)-1];
        end
    elseif i == length(stI)
        win = [enI(i-1)+1 length(ki)];
    else
        win = [enI(i-1)+1 stI(i+1)-1];
    end
    
    %Get length of the ok bases
    nb = diff(win)+1-nnI(i);
    %If this is long enough, try to fix snp
    switch nnI(i)
        case {1 2}
            if nb < opts.ntmin(nnI(i));
                continue
            end
        otherwise
            continue
    end

    %There is a max difference of two spaces, so there's only 3 options: insertion, deletion, or snp
    dels = sum(aln(:,stI(i):enI(i)) == '-',2);

    %Extract trace snippet by finding which nt we're on [the position of the flanking nts]
    inS = la.Start(2)-1 + stI(i)-1 - sum(aln(3,1:stI(i)-1)=='-');
    enS = la.Start(2)-1 + enI(i)+1 - sum(aln(3,1:enI(i)+1)=='-');
    
    %Specially handle bases in the first nc-1 bp (only allow SNPs here)
    if inS < 4 %Only if the gap in question is at posiiton 5 or earlier [i.e. there would not be a preceding cdn], meaning inS (the bp prev) needs to be >=4
        %If Snp
        if all(~dels)
            seq(inS+1:enS-1) = aln(1,stI(i):enI(i));
            newwin = [la.Start(2)-1 + win(1) - sum(aln(3,1:win(1))=='-')...
                      la.Start(2)-1 + win(2) - sum(aln(3,1:win(2))=='-')];
            ok = [newwin ok]; %#ok<AGROW>
        end
        continue
    end
        
        %Extract
    trcrp = tr( in(inS):in(enS+1)-1 );
    if debugmsg
        fprintf('Len Pre/Post: %d,',length(in))
    end
    if any(dels) %INDEL: there's a '-'. Use KV to rectify step sizes. Technically just looking for dels([1 3]) here
        %Make sure there's enough points...
        if length(trcrp) > (1+nnI(i)-dels(1))*3;
            %Stepfind, update in
            kv = AFindStepsV5(trcrp, 0, 1+nnI(i)-dels(1), 0);
            in = [in(1:inS) in(inS)-1+kv(2:end-1) in(enS+1:end)];
        else
            continue
        end
    else %SNP: Keep the steps, just replace the sequence
    end
    %Update seq by pasting in the top trueseq
    dl = length(seq);
    snp = aln(1,stI(i):enI(i));
    snp(snp=='-')=[];
    if debugmsg
        fprintf('%d. ',length(in))
        fprintf('SLen Pre/Post: %d,',length(seq))
    end
    seq = [seq(1:inS) snp seq(enS:end)];
    if debugmsg
        fprintf('%d\n',length(seq))
    end
    dl = length(seq) - dl; %How much seq grew this cycle
    %Mark these nucleotides as ok; update prevs if nts were added/removed
    newwin = [la.Start(2)-1 + win(1) - sum(aln(3,1:win(1))=='-')...
              la.Start(2)-1 + win(2) - sum(aln(3,1:win(2))=='-')+dl];
    ok = [newwin ok+dl];
end

%Strip the prepended values in in
in = in(nc:end);
me = seq2st(seq, 1:256);

%Make sure in, me were correctly done
%% EMBRACE CHAOS nah there's errors I need to fix
assert(issorted(in), 'Error: in/me updated incorrectly in seqHMMp2c')
assert(length(in) == length(me)+1, 'Error: in/me updated incorrectly in seqHMMp2c')
assert(length(unique(in(1:end-1))) == length(in(1:end-1)), 'Error: in/me updated incorrectly in seqHMMp2c')

% assert(all(diff(me)), 'Error: in/me updated incorrectly in seqHMMp2c') 
%^ Actually ok, finding 5-mers is unavoidable (but, they should not be able to be passed as good sequence, as they're not in seqi)

%Hm this sometimes introduces 5-in-a-rows which messes up some things (fiti <-> in,me conversion fails)
%Do all of p2 here [output [cdn, val] matrix]

%Update values using new seq
outres = res;
outres.fiti = ind2tra(in, me);
outres.seqn = seq;
%Convert seq (letters) to seq (numbers)
[~, ia, ic] = unique(['ATGC' seq]);
outres.seq = ia(ic(5:end))';
outres.fit = []; %Dont know mu, so just don't bother
outres.kept = true(1,length(me));

%Get 'ok' things
%Convert 'ok' sequence space to codon space
ok = ok - nc +1;
ok(ok<1) = 1;
%And assign ok codons then
ki = false(1,length(me));
ok = reshape(ok, 2, [])';
for i = 1:size(ok,1)
    ki(ok(i,1)+nc-1:ok(i,2))=true;
end

%Covert ok to 
newme = ind2mea(in, tr);
out = [me' newme'];
out = out(ki, :);

%Sanity check: For Alan's current sequence, these codons should never be detected, error if they are [= bug found]
nt = 'ATGC';
forbid = [25    28    39    41    44    48    51    55    62    70    71    74    75    83    85    90    94    98   101   102   103   114   121   127   136   138   139   141   154   155   159   160   163   164   175   176   177   187   188   191   199   209   218   226   227   233   239   245   249   251];
for i = 1:length(forbid)
    if numel(out)>0 && any(out(:,1) == forbid(i))
        fprintf('Found state %s in Alan''s data, which is forbidden; data removed', nt(num2cdn (forbid(i))))
        error('MultiBTs found probably ?')
        out = [];
    end
end



