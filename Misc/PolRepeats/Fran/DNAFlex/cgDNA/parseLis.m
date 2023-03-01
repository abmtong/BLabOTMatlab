function [configuration, seq] = parseLis(filename)

%-----------------------------------------------------------
% cgDNA function: [configuration, seq] = parseLis(filename)
%-----------------------------------------------------------
% Parse the information contained in the .lis output of 
% Curves+ to obtain standard form Curves+ coordinates and
% sequence of the DNA molecule analysed in the .lis file.
% Curves+ can be used to obtain helical parameters from a
% .pdb file.  For example, the following command would
% produce a valid "1bna.lis" file from the Drew-Dickerson
% dodecamer structure file "1bna.pdb" (www.rcsb.org/pdb):
%
% /Users/RL/Code/Cur+ <<!
% &inp file=1bna.pdb,
%  lis=1bna, 
%  lib=/Users/RL/Code/standard, &end
% 2 1 -1 0 0
% 1:12
% 24:13
% !
% 
% Output .lis files obtained running Curves+ on trajectory 
% files are not a valid input for parseLis.
% For more information about Curves+ and its usage, see
% http://gbio-pbil.ibcp.fr/Curves_plus.
% parseLis was tested with version 2.4 of Curves+.
% 
% 
% Input:
%
%   filename       the complete path of the input .lis file
%
%
% Output:
%
%   configuration  standard form Curves+ coordinate vector
%                  of the B-DNA molecule described in the
%                  input .lis file [size N x 1]
%
%   S              base sequence on the reference strand 
%                  of the B-DNA molecule described in the
%                  input .lis file [size nbp x 1]
%
%   where N = 12*nbp - 6 and nbp is the length 
%   of the sequence seq (number of basepairs). 
%
%
% Note 1:
%
%    Curves+ is capable of producing .lis files for a 
%    much larger variety of DNA molecules than those 
%    tractable by the cgDNA model.  The input .lis file 
%    for parseLis() is expected to refer to a canonical 
%    B-DNA molecule with correct Watson-Crick base-pairing.
%    Although some checks are performed during parsing,
%    the user is advised to keep vigilant for unexpected 
%    behaviour.  A good check of consistency would be to
%    write a .pdb file of the coordinates obtained with
%    parseLis() (see "help makePDB"), and compare it to 
%    the Curves+ .pdb input.  A similar procedure is 
%    carried out in the cgDNA test suite.
%
%
% Note 2:
%
%    The entries in the variable configuration
%    are consistent with the following ordering of
%    the structural coordinates
%
%     y_1, z_1, ..., y_{nbp-1}, z_{nbp-1}, y_{nbp}
%
%    where for each a=1,2,3,... we have
%
%     y_a = (Buckle,Propeller,Opening,Shear,Stretch,Stagger)_a
%
%     z_a = (Tilt,Roll,Twist,Shift,Slide,Rise)_a.
%
%    For example
%
%     configuration((a-1)*12+1) = Buckle at basepair a
%     configuration((a-1)*12+2) = Propeller at basepair a
%      ...
%     configuration((a-1)*12+6) = Stagger at basepair a
%     configuration((a-1)*12+7) = Tilt at junction a, a+1
%     configuration((a-1)*12+8) = Roll at junction a, a+1
%      ...
%     configuration((a-1)*12+12) = Rise at junction a, a+1.
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

    NONE = 0;
    INTRA= 1;
    INTER= 2;
    SEPARATOR = ['-','/'];
    
    parsing = NONE;                     % parser state
    
    eta = [];                           % intra rot
    w   = [];                           % intra trasl
    u   = [];                           % inter rot
    v   = [];                           % inter trasl
    seq = [];                           % sequence
    
    % variables for checking valid input
    prev_index_ref  = -1;
    prev_index_comp = -1;
    
    fid = fopen(filename);
    if fid == -1
        error('parseLis: File "%s" not found!\n', filename);
    end
    while ~feof(fid)
        line = fgets(fid);
        if     regexp(line,'^\s*\(B\)') % (B) Intra-BP parameters
            parsing=INTRA;
            continue;
        elseif regexp(line,'^\s*\(C\)') % (C) Inter-BP parameters
            parsing=INTER;
            continue;
        elseif regexp(line,'^\s*\(D\)') % (D) ...
            break;
        end
        
        if parsing ~= NONE
            if regexp(line, '^\s+[0-9]+\)') % now parsing entries
                format = ['%d) %c%d', ...
                          SEPARATOR(parsing), ...
                          '%c %d %f %f %f %f %f %f %f %f'];
                tmp = sscanf(line, format);
                if parsing == INTRA
                    
                    % --- perform some checks 
                    % check base indices are sequential 
                    if prev_index_ref >= 0 && ...
                            abs(prev_index_ref - tmp(3)) ~= 1
                        warning(...
    'Base %d followed by base %d%s on strand 1: check your lis output.',...
                        prev_index_ref, tmp(3), char(tmp(2)));
                    end
                    if prev_index_comp >= 0 && ...
                            abs(prev_index_comp - tmp(5)) ~= 1
                        warning(...
    'Base %d followed by base %d%s on strand 2: check your lis output.',...
                        prev_index_comp, tmp(5), char(tmp(4)));
                    end
                    prev_index_ref  = tmp(3);
                    prev_index_comp = tmp(5);
                    % check correct base-pairing
                    if char(tmp(4)) ~= wcc(char(tmp(2)))
                        warning(...
    'Base mismatch detected at level %d: %s-%s. Check your lis output.',...
                        tmp(1), char(tmp(2)), char(tmp(4)));
                    end
                    % --- checks done
                    
                    seq = [seq, char(tmp(2))];
                    eta = [eta; tmp(9:11)'];
                    w   = [w;   tmp(6:8)'];
                else % INTER
                    u   = [u;   tmp(9:11)'];
                    v   = [v;   tmp(6:8)'];
                end
            end
        end
    end
    fclose(fid);

    % obtain configuration vector
    configuration = shapes2vector(eta,w,u,v);
end
