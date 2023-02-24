function out = readFasta(infp)

if nargin < 1
    [f, p] = uigetfile('*.fasta', 'Mu', 'on');
    if ~p
        return
    end
    
    if iscell(f)
        %Read them
        out = cellfun(@(x) readFasta(fullfile(p, x)), f);
        %Strip suffix from f
        [~, fr, ~] = cellfun(@fileparts, f, 'Un', 0);
        [out.name] = deal( fr{:} );
        %Reorder fieldnames
        out = orderfields(out, [3 1 2]); %Hardcode num fields for now

        return
    end
    infp = fullfile(p, f);
end

%Load file

%FASTA file is alternating lines of read IDs and the read sequences, e.g.:
%{
>0	476;4549;5781;40833;42275;51638;53633;56030;76545; ... %One number per read ID?
CTGGGCTTCGGTGACTACTAAACTGAATTGCCGGACAATCTGTAGAGAGGATGTTAGCCGGGAGGATGTTATGGTTCAGTGTGTTCGACATTTTGTCTTACCGCGTCTGAAAAAAGACGCTGGCCTGCCGTTTTTCTTCCCGTTGATCACC
%}

fid = fopen(infp);
%Prealloc storage -- is there a better way to do this?
rids = cell(1,1e5);
seqs = cell(1,1e5);
nseq = 0;
while true
    %Read two lines (read IDs, seq)
    id = fgetl(fid);
    sq = fgetl(fid);
    
    %Check for end of file
    if isequal(id, -1) || isequal(sq, -1)
        break
    end
    
    %Increment sequences
    nseq = nseq + 1;
    
    %The whitespace after the '>#' is a tab? (char(9)), so trim from that char(9) to the end
    id = id( find (id == char(9), 1, 'first') + 1 : end);
    %This is a semicolon-separated list, convert to array with str2num
    rids{nseq} = str2num(id)'; %#ok<ST2NM>
    %And save sequence
    seqs{nseq} = sq;
end
fclose(fid);
seqs = seqs(1:nseq);
rids = rids(1:nseq);

out.seqs = seqs;
out.rids = rids;

