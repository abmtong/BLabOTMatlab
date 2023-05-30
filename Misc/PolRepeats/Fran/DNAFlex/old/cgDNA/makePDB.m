function [] = makePDB(seq, basepair, filename)

%--------------------------------------------------------
% cgDNA function: [] = makePDB(seq, basepair, filename)
%--------------------------------------------------------
% Given the reference point and frame of each base,
% this function constructs the ideal coordinates of 
% the non-hydrogen atoms of each base according to the
% Tsukuba definition, and writes the output to a PDB 
% file (backbone atoms are not included).  The atomic
% coordinates are expressed relative to a fixed lab
% frame which coincides with the first basepair frame.
%
%
% Input: 
%
%   seq         sequence along reference strand
%
%   basepair    structure with reference point and frame
%               for each base on each strand (see Note 1).
%
%
% Auxiliary input: 
%
%   idealBases.mat  matlab file with the ideal 
%                   coordinates (in base frame) of 
%                   the non-hydrogen atoms of the 
%                   four bases T, A, C, G.
%
%
% Output: []
%
%   
% Note 1:
%
%   'basepair' is a (1 x nbp) struct array with fields:
%    - 'D' : the frame of the base on the reading strand;
%    - 'r' : the coordinates of the base on the r. s.;
%    - 'Dc': the frame of the base on the complementary strand;
%    - 'rc': the coordinates of the base on the c. s.;
%
%    Reference point coordinates are 3x1 vectors, while frames 
%    are 3x3 matrices, with the frame coordinate vectors stored
%    as columns.  'nbp' is the length of the sequence.
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

    seq = upper(seq);
    nbp = numel(seq);

    load('idealBases.mat');

    s = 'ATGC';

    fpdb = fopen(filename,'w');

    ntotal = 0;

    for i = 1:nbp %main strand
        
        k = find(s==seq(i)); %which base (A,T,G or C) 
        for j=1:(abase(k).n)
            
            ntotal = ntotal +1;
            acoord = basepair(i).r + basepair(i).D*abase(k).atoms(j).coord'; 
            fprintf(fpdb,'ATOM    %3d  %3s  %s    %2d     %7.3f  %7.3f  %7.3f \n', ntotal, abase(k).atoms(j).name, abase(k).S, i, acoord);   
        end    
        
    end; 

    fprintf(fpdb,'TER  \n'); 

    F = [1 0 0; 0 -1 0; 0 0 -1];

    for i = 1:nbp %complementary strand
        
        k = find(s==wcc(seq(nbp-i+1))); %which base (A,T,G or C) 
        for j=1:(abase(k).n)
            
            ntotal = ntotal +1;
            acoord = basepair(nbp-i+1).rc + basepair(nbp-i+1).Dc*F*abase(k).atoms(j).coord'; 
            fprintf(fpdb,'ATOM    %3d  %3s  %s    %2d     %7.3f  %7.3f  %7.3f \n', ntotal, abase(k).atoms(j).name, abase(k).S, i+nbp, acoord);   
        end    
        
    end; 


    fclose(fpdb);
    
end
