function [] = printShapeParms(configuration, seq, filename)

%-------------------------------------------------------
% cgDNA function: [] = printShapeParms(configuration, seq, filename)
%-------------------------------------------------------
% This function writes the ground-state coordinates
% to an output file.
%
% Input: 
%
%   configuration     ground-state coordinate vector 
%               [size N x 1].
%
%   seq         sequence along reference strand
%
%   filename    name of output file.
%
% Output: []
%
%   The file contains intra-basepair coordinates for 
%   each monomer, and inter-basepair coordinates for 
%   each dimer along the given sequence.
%
%
% If you find this code useful, please cite:
%
% D. Petkeviciute, M. Pasi, O. Gonzalez and J.H. Maddocks. 
%  cgDNA: a software package for the prediction of 
%  sequence-dependent coarse-grain free energies of B-form 
%  DNA. Nucleic Acids Research 2014; doi: 10.1093/nar/gku825. 
%
%-------------------------------------------------------

    seq = upper(seq);
    nbp = numel(seq);
    [eta,w,u,v] = vector2shapes(configuration);
    seqc = wcc(seq);
    
    ftext = fopen(filename,'w');

    fprintf(ftext,'Intra-basepair parameters: \n \n'); 
    fprintf(ftext,'Basepair   Buckle  Propeller  Opening    Shear    Stretch   Stagger \n\n'); 
    for i = 1:nbp
        fprintf(ftext,'%2d) %2s    %6.2f    %6.2f    %6.2f    %6.2f    %6.2f    %6.2f  \n', ...
                i, [seq(i) seqc(i)], eta(i,:), w(i,:));
    end

    fprintf(ftext,'\n'); 
    fprintf(ftext,'Inter-basepair parameters: \n \n'); 
    fprintf(ftext,'BP step     Tilt      Roll     Twist     Shift     Slide      Rise  \n\n'); 
    for i = 1:(nbp-1)
        bpi = [seq(i),   seqc(i)];
        bpip= [seq(i+1), seqc(i+1)];
        fprintf(ftext,'%2d) %5s %6.2f    %6.2f    %6.2f    %6.2f    %6.2f    %6.2f  \n', ...
                i, [bpi '/' bpip], u(i,:), v(i,:));
    end
    fclose(ftext);
    
end
