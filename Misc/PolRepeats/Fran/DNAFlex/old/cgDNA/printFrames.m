function [] = printFrames(basepair, filename, format)  

%----------------------------------------------------------
% cgDNA function: [] = printFrames(basepair, filename, format)
%----------------------------------------------------------
% Writes a text file with the point and frame data 
% according to the data in basepair. 
%
% Input: 
% 
%   basepair    structure with reference point and frame
%               for each base on each strand (see Note 1).
%
%   filename    name of output file.
%
%   format      define output format (see Note 2).
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
% Note 2:
%
%   Two output formats are available for point and frame 
%   data, corresponding to format = 1 or format = 2.
% 
%   format=1 produces a text file in which the point and
%   frame for each base is written as a 4x3 matrix, with the
%   first row being the coordinates of the base reference
%   point, and each of the three subsequent rows being the
%   components of the base frame vectors d_1, d_2 and d_3;
%   the bases are ordered from top to bottom, first all the
%   bases of the reference strand, then all the bases of the
%   complementary strand.
%  
%   format=2 produces a text file in which the point and frame
%   for each base is written as a line of 14 integers, the
%   first being the index of a strand (1-reference,
%   2-complementary), the second being the index of a basepair,
%   the next nine being the coordinates of the frame vectors
%   d_1, d_2 and d_3 multiplied by 1000, and the last three
%   being the coordinates of the reference point multiplied by
%   1000; the bases are ordered from top to bottom, first all
%   the bases of the reference strand, then all the bases of
%   the complementary strand.
%
%
% If you find this code useful, please cite:
%
% D. Petkeviciute, M. Pasi, O. Gonzalez and J.H. Maddocks. 
%  cgDNA: a software package for the prediction of 
%  sequence-dependent coarse-grain free energies of B-form 
%  DNA. Nucleic Acids Research 2014; doi: 10.1093/nar/gku825.
%
%----------------------------------------------------------

    nbp = numel(basepair);
    
    s = fopen(filename,'w');

    if format==1
        fprintf(s,'%d \n' ,1);
    end
         
    for j=1:nbp
       %main strand
       if format == 1
           D = basepair(j).D;
           r = basepair(j).r;
           fprintf(s,' %d   %d \n' ,1,j);
           fprintf(s,'  %10.6f  %10.6f  %10.6f \n', r(1), r(2), r(3));
           fprintf(s,'  %10.6f  %10.6f  %10.6f \n', D(1,1), D(2,1), D(3,1));
           fprintf(s,'  %10.6f  %10.6f  %10.6f \n', D(1,2), D(2,2), D(3,2));
           fprintf(s,'  %10.6f  %10.6f  %10.6f \n', D(1,3), D(2,3), D(3,3));
       elseif format == 2
           D = basepair(j).D*1000;
           r = basepair(j).r*1000;
           fprintf(s,' %d   %2d ', 1,j);
           fprintf(s,' %6.0f %6.0f %6.0f', D(1,1), D(2,1), D(3,1));
           fprintf(s,' %6.0f %6.0f %6.0f', D(1,2), D(2,2), D(3,2));
           fprintf(s,' %6.0f %6.0f %6.0f', D(1,3), D(2,3), D(3,3));
           fprintf(s,' %6.0f %6.0f %6.0f \n', r(1), r(2), r(3));
       end
    end
    
    for j=1:nbp      
       %complementary strand
       if format == 1
           D = basepair(j).Dc;
           r = basepair(j).rc;
           fprintf(s,' %d   %d \n' ,2,j);
           fprintf(s,'  %10.6f  %10.6f  %10.6f \n', r(1), r(2), r(3));
           fprintf(s,'  %10.6f  %10.6f  %10.6f \n', D(1,1), D(2,1), D(3,1));
           fprintf(s,'  %10.6f  %10.6f  %10.6f \n', -D(1,2), -D(2,2), -D(3,2));
           fprintf(s,'  %10.6f  %10.6f  %10.6f \n', -D(1,3), -D(2,3), -D(3,3));     
       elseif format == 2
           D = basepair(j).Dc*1000;
           r = basepair(j).rc*1000;
           fprintf(s,' %d   %2d ' ,2,j);
           fprintf(s,' %6.0f %6.0f %6.0f', D(1,1), D(2,1), D(3,1));
           fprintf(s,' %6.0f %6.0f %6.0f', -D(1,2), -D(2,2), -D(3,2));
           fprintf(s,' %6.0f %6.0f %6.0f', -D(1,3), -D(2,3), -D(3,3));
           fprintf(s,' %6.0f %6.0f %6.0f \n', r(1), r(2), r(3));      
       end
    end
 
    fclose(s);
    
end
