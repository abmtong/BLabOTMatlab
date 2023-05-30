function [sequence] = parseFasta(filename)

%-----------------------------------------------------------
% cgDNA function: [sequence] = parseFasta(filename)
%-----------------------------------------------------------
% Read a FASTA format file or a plain text file containing a
% valid DNA sequence and return the sequence as a string of
% upper case characters. The plain text file must contain
% only valid 1-letter base-name codes (i.e. A, C, G and T),
% while all whitespace is ignored (including spaces,
% tabulator and newline characters, allowing the sequence to
% be distributed on multiple lines). The FASTA format is
% similar, but the sequence may be preceded by a single line
% of description which must start with the character ">"
% (see also http://en.wikipedia.org/wiki/FASTA_format).
% Multiple sequences in the FASTA files are not supported.
%
% For a more complete FASTA file parser, please see the 
% <fastaread> function in the Matlab Bioinformatics Toolbox
% (http://www.mathworks.com/help/bioinfo/index.html) 
%
%
% Input:
%
%   filename       the complete path of the input file
%
%
% Output:
%
%   sequence       base sequence read from the file
%                  [size nbp x 1]
%
%   where nbp is the length of the sequence (number of
%   basepairs).
%
%
% If you find this code useful, please cite:
%
% D. Petkeviciute, M. Pasi, O. Gonzalez and J.H. Maddocks. 
%  cgDNA: a software package for the prediction of 
%  sequence-dependent coarse-grain free energies of B-form 
%  DNA. Nucleic Acids Research 2014; doi: 10.1093/nar/gku825.
%
%--------------------------------------------------------

    
    basenames = ['A' 'T' 'C' 'G'];
    
    fid = fopen(filename);
    if fid == -1
        error('parseFasta: File "%s" not found!\n', filename);
    end
    fasta = textscan(fid,'%s','Delimiter','\n');
    fasta = fasta{:};
    
    sequence = repmat(' ', 1, sum(cellfun(@numel,fasta)));
    seqi = 1;
    for li = 1:numel(fasta)
        % skip header
        if strncmp(fasta{li}, '>', 1)
            continue;
        end
        tseq = strtrim(fasta{li});
        tlen = numel(tseq);
        % check validity
        invalid = zeros(1,tlen);
        for ibn = 1:numel(basenames)
            invalid = invalid | tseq == basenames(ibn);
        end
        invalid = ~invalid;
        if any(invalid)
            error(...
'parseFasta: Unrecognised code "%s" on line %d of file "%s".',...
    tseq(find(invalid,1)), li, filename);
        end
        % add to full sequence
        sequence(seqi:seqi+tlen-1) = tseq;
        seqi = seqi + tlen;
    end
    sequence = strtrim(sequence);
end
