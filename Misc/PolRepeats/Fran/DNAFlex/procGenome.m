function out = procGenome(infp, inOpts)
%Loads a genomic FASTA + RefSeq annotation (GFF format)
% GeneBank annotation has additional stuffs, ignore
%Genome is in the format e.g.:
%{
>NC_001133.9 Saccharomyces cerevisiae S288C chromosome I, complete sequence
ccacaccacacccacacacccacacaccacaccacacaccacaccacacccacacacacacatCCTAACACTACCCTAAC
ACAGCCCTAATCTAACCCTGGCCAACCTGTCTCTCAACTTACCCTCCATTACCCTGCCTCCACTCGTTACCCTGTCCCAT
TCAACCATACCACTCCGAACCACCATCCATCCCTCTACTTACTACCACTCACCCACCGTTACCCTCCAATTACCCATATC
CAACCCACTGCCACTTACCCTACCATTACCCTACCATCCACCATGACCTACTCACCATACTGTTCTTCTACCCACCATAT
TGAAACGCTAACAAATGATCGTAAATAACACACACGTGCTTACCCTACCACTTTATACCACCACCACATGCCATACTCAC
...
A header line (one per chromosome), then the sequence
%}
%And the genome annotation in gff format, renamed to be the same filename as the genome but .gff

opts.hdrmeth = 2; %Method for converting the header line into chromosome name (see code)
opts.annot = 'gff'; %Annotation format

if nargin < 1
    [f p] = uigetfile('*.fna');
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
                else %Miscellaneous DNA component, ignore
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
        gfftype = tmp2{3};
        
        %Prealloc. Just assume an upper limit of 2e5? (human has ~2e4?)
        gendataraw = cell(2e5, 2);
        %Process each line by gfftype
        chr = 'invalid';
        ngene = 0;
        for i = 1:length(gfftype)
            switch gfftype{i}
                case 'region'
                    %New region (i.e. chromosome), set
                    %Scrub chromosome name from 9th col, 'chromosome=I'
                    attribs = tmp2{9}{i};
                    [re1, re2] = regexp(attribs, 'chromosome=\w+;');
                    if isempty(re1)
                        %Check if it's mitochondrial DNA
                        if strfind(attribs, 'mitochondrion')
                            chr = 'chrM';
                        else
                            chr='SKIP'; %Also makes it skip later
                            warning('Unknown region %s', attribs)
                        end
                    else %Is a chromosome, format to chrI
                        %Strip chromosome= and semicolon
                        chr = ['chr' attribs(re1+11:re2-1)];
                    end
                case 'gene'
                    %Add gene to record
                    ngene = ngene + 1;
                    gendataraw(ngene, :) = {chr [tmp2{4}(i) tmp2{5}(i) tmp2{7}{i} == '+']};
            end
            
        end
        %Strip empty
        gendataraw = gendataraw(1:ngene, :);
        
        %Group by chromosome ID
        [c, ia, ic] = unique(gendataraw(:,1));
        nchr = length(c);
        for i = nchr:-1:1
            %Ignore non-chromosome entries
            switch opts.hdrmeth
                case [1 2]
                    if ~strncmp(c{i} , 'chr',3)
                        continue
                    end
                otherwise
            end
            
            ki = ic == i;
            
            %Find corresponding index in genome data
            ii = find( strcmp( {out.chr}, c{i} ) );
            
            if isempty(ii)
                warning('Unknown chromosome %s', c{i})
                continue
            end
            
            %Save start, end, strand
            out(ii).gendat = cell2mat(gendataraw(ki, 2));
        end
        
        %Strip empty rows, if genome has weird entries
        ki = arrayfun(@(x)all(structfun(@isempty,x)), out);
        out = out(~ki);
        
    case 'csv'
        % Used to load data from a csv, archived here
        % Comparing the gff and the csv, the csv only gave protein products, while the gff had more things (e.g. tRNA and other functional RNAs)
        %Now load genome features, expects same filename but .csv
        [p f e] = fileparts(infp);
        gbfp = fullfile(p, [f '.csv']);
        
        %File is a csv, so load
        fid2 = fopen(gbfp);
        tmp2 = readtable(gbfp);
        %Columns: x_Name Accession Start Stop Strand GeneID Locus LocusTag ProteinLength ProteinName
        fclose(fid2);
        
        %Convert chromosome ID to suitable format
        switch opts.hdrmeth
            case {1 2}
                chrfns = strrep( tmp2.x_Name, 'chromosome ', 'chr');
                %Handle the mitochondrial data
                tf = ~cellfun(@isempty, strfind( tmp2.x_Name, 'mitochondri'));
                chrfns(tf) = {'chrM'};
            otherwise
                error('Invalid hdrmeth')
        end
        
        %Convert strand data to suitable format
        strand = strcmp(tmp2.Strand, '+'); %1 = fwd strand, 0 = rev strand
        %Group by chromosome ID
        [c, ia, ic] = unique(chrfns);
        nchr = length(c);
        for i = nchr:-1:1
            %Ignore non-chromosome entries
            switch opts.hdrmeth
                case 1
                    if ~strncmp(c{i} , 'chr',3)
                        continue
                    end
                otherwise
            end
            
            ki = ic == i;
            %Save start, end, strand
            out(i).gendat = [tmp2.Start(ki) tmp2.Stop(ki) strand(ki)];
        end
    otherwise
end


