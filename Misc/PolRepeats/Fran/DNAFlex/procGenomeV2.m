function out = procGenomeV2(infp, inOpts)
%Loads a genomic FASTA + RefSeq annotation (GFF format)

%OH this doesn't separate the other genomic scaffolds from the main genome. Fix or just skip those genes

%Formatting info:
%{
Genome is in the format e.g.:
>NC_001133.9 Saccharomyces cerevisiae S288C chromosome I, complete sequence
ccacaccacacccacacacccacacaccacaccacacaccacaccacacccacacacacacatCCTAACACTACCCTAAC
ACAGCCCTAATCTAACCCTGGCCAACCTGTCTCTCAACTTACCCTCCATTACCCTGCCTCCACTCGTTACCCTGTCCCAT
TCAACCATACCACTCCGAACCACCATCCATCCCTCTACTTACTACCACTCACCCACCGTTACCCTCCAATTACCCATATC
CAACCCACTGCCACTTACCCTACCATTACCCTACCATCCACCATGACCTACTCACCATACTGTTCTTCTACCCACCATAT
TGAAACGCTAACAAATGATCGTAAATAACACACACGTGCTTACCCTACCACTTTATACCACCACCACATGCCATACTCAC
...
A header line (one per chromosome), then the sequence
There might be non-chromosomal sequences, which are skipped on import

And the genome annotation in gff format, renamed to be the same filename as the genome but .gff:
{some comments, prepended by #'s}
NC_001133.9	RefSeq	region	1	230218	.	+	.	ID=NC_001133.9:1..230218;Dbxref=taxon:559292;Name=I;chromosome=I;gbkey=Src;genome=chromosome;mol_type=genomic DNA;strain=S288C
NC_001133.9	RefSeq	telomere	1	801	.	-	.	ID=id-NC_001133.9:1..801;Dbxref=SGD:S000028862;Note=TEL01L%3B Telomeric region on the left arm of Chromosome I%3B composed of an X element core sequence%2C X element combinatorial repeats%2C and a short terminal stretch of telomeric repeats;gbkey=telomere
NC_001133.9	RefSeq	origin_of_replication	707	776	.	+	.	ID=id-NC_001133.9:707..776;Dbxref=SGD:S000121252;Note=ARS102%3B Autonomously Replicating Sequence;gbkey=rep_origin
NC_001133.9	RefSeq	gene	1807	2169	.	-	.	ID=gene-YAL068C;Dbxref=GeneID:851229;Name=PAU8;end_range=2169,.;gbkey=Gene;gene=PAU8;gene_biotype=protein_coding;locus_tag=YAL068C;partial=true;start_range=.,1807
NC_001133.9	RefSeq	mRNA	1807	2169	.	-	.	

Only cares about rows with 'region' (which defines which chromosome it is' and 'gene' rows (which define genes)
See below code for details
%}


opts.hdrmeth = 2; %Method for converting the header line into chromosome name (see code)
opts.annot = 'gff'; %Annotation format

if nargin < 1
    [f, p] = uigetfile('*.fna');
    if ~p
        return
    end
    infp = fullfile(p, f);
end

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Load file
fid = fopen(infp);
if fid == -1
    [p, f, e] = fileparts(infp);
    warning('File %s not found, quitting', f);
    return
end

%Load file as lines
tmp = textscan(fid, '%s', 'Delimiter', '\n');
tmp = tmp{1};
fclose(fid);

%Look for chromosome delimiters (first char is '>')
chrst = find( cellfun(@(x) x(1) == '>', tmp));
nchr = length(chrst);

%And process chromosomes
chrsttmp = [chrst; length(tmp)];
for i = nchr:-1:1
    %Get the name line
    namln = tmp{chrsttmp(i)};
    %Process into a fieldname
    switch opts.hdrmeth
        case 1
            %Short circuit the mitochondral dna to 'chrM'
            if strfind(namln, 'mitochondrion')
                fn = 'chrM';
            else
                % Changes "... chromosome I, complete sequence" to chrI
                %Just crop from last comma...
                namln = namln(1:strfind( namln, ', complete sequence')-1);
                % to the previous space?
                st = find(namln == ' ', 1, 'last');
                fn = ['chr' namln(st+1:end)];
            end
        case 2
            %Search for "chromosome \w+,'
            [re1, re2] = regexp(namln, 'chromosome \w+,');
            if re1
                fn = ['chr' namln( re1+11 : re2-1 ) ];
            else %Handle some odd cases
                if regexp(namln, 'mitochondri')
                    fn = 'chrM';
                else %Miscellaneous DNA scaffold, ignore
                    fprintf('Skipping %s\n', namln)
                    continue
                end
            end
        otherwise
            error('Invalid hdrmeth')
    end
    
    %Merge the rest of the lines into the sequence
    tmpseq = [ tmp{ chrsttmp(i)+1 : chrsttmp(i+1)-1 } ];
    
    %Add to output
    out(i).chr = fn;
    out(i).seq = tmpseq;
end

switch opts.annot
    case 'gff'
        
        %File is a tsv with # comments, so load as such
        [p f e] = fileparts(infp);
        gbfp = fullfile(p, [f '.gff']);
        
        %Load
        fid2 = fopen(gbfp);
        tmp2 = textscan(fid, '%s %s %s %d %d %s %s %s %s', 'Delimiter', {'\t' '\n'}, 'CommentStyle', '#');
        fclose(fid2);
        %Columns are: seqname, source, feature_type, start, end, score, strand (+/- = fwd/rev), frame, attributes
        
        %Extract the gene refs (tmp{3} -- 'gene')
        chrtype = tmp2{1};
        gfftype = tmp2{3};
        
        %Prealloc. Just assume an upper limit of 2e5? (human has ~2e4?)
        gendataraw = cell(2e5, 3);
        %Process gfftype 'gene' markers
%         chr = 'invalid';
        ngene = 0;
        for i = 1:length(gfftype)
            %Check for gene + we're in a normal chromosome (
            chrraw = chrtype{i};
            gffraw = gfftype{i};
            if strcmp(gffraw, 'gene') && strcmp(chrraw(1:3), 'NC_')
                %tmp2{1}{i} is e.g. NC_0000001.11, the _ to . is the chromosome number
                % 23 = X, 24 = Y ; let's rename them
                %First grab the number:
                chrnum = str2double( chrraw( 4: find(chrraw == '.', 1, 'first')-1 ) );
                
                %Format to chr1, chr2, ...chrX
                if chrnum ==23
                    chr = 'chrX';
                elseif chrnum == 24
                    chr = 'chrY';
                elseif chrnum <= 22
                    chr = sprintf('chr%d', chrnum);
                else
                    if strcmp(chrnum, 'NC_012920.1')
                        %Human mitochondrial DNA, just skip
                    else
                        fprintf('Skipping gene on %s\n', chrraw)
                    end
                    continue
                end
                
                %Get gene info
                attribs = tmp2{9}{i};
                
                %Strip gene name from attributes column, 'ID=gene-MIR1285-2;' -> gene-MIR1285-2
                [re1, re2] = regexp(attribs, 'ID=[^;]+;');
                
                if isempty(re1)
                    warning('Gene ID not found: check, string %s', attribs)
                end
                
                ngene = ngene + 1;
                gendataraw(ngene, :) = {chr [tmp2{4}(i) tmp2{5}(i) tmp2{7}{i} == '+'] tmp2{9}{i}(re1+3:re2-1) };
            end
        end
        
        %Strip empty
        gendataraw = gendataraw(1:ngene, :);
        
        %Group by chromosome ID
        [c, ia, ic] = unique(gendataraw(:,1));
        nchr = length(c);
        for i = nchr:-1:1
            %
            ki = ic == i;
            
            %Find corresponding index in genome data
            ii = find( strcmp( {out.chr}, c{i} ) );
            
            if isempty(ii)
                warning('Unknown chromosome %s', c{i})
                continue
            end
            
            %Save start, end, strand
            out(ii).gendat = cell2mat(gendataraw(ki, 2));
            out(ii).name = gendataraw(ki,3);
        end
        
        %Strip empty rows, if genome has weird entries
        ki = arrayfun(@(x)all(structfun(@isempty,x)), out);
        out = out(~ki);
        
    
end


