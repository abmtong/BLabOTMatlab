function [shapes, stiff] = constructSeqParms(seq, params)
%-----------------------------------------------------------
% cgDNA function: [shapes,stiff] = constructSeqParms(seq, params)
%-----------------------------------------------------------
% This function constructs the ground-state coordinate
% vector and stiffness matrix in non-dimensional Curves+
% form for a given sequence, using the specified parameter
% set in params.  
%
%
% Input: 
%
%   seq     sequence along reference strand;
%
%   params  parameter set structure (see Note 1). 
%
%
% Output:
%
%   shapes  ground-state coordinate vector 
%           [size N x 1]
%
%   stiff   ground-state stiffness matrix
%           [size N x N]
%
%   where N = 12*nbp - 6 and nbp is the length 
%   of the sequence seq (number of basepairs). 
%
%
% Note 1:
%
%    'params' is an object with the 'dimer' and 'base'
%    properties defined, containing stiffness blocks and 
%    weighted shape vectors for each of the 16 possible 
%    base-pair steps (dimer), and each of the 4 possible 
%    base pairs (base).  The two are described below. 
%    Equations referenced below are from
%    Gonzalez et al., J. Chem. Phys. 138, 055102 (2013).
%    
%    - 'dimer': a 1x16 struct array with fields: 
%      - 'S'  : the basepair step as a string of 2 chars;
%      - 'b18': the 18x18 stiffness block corresponding 
%               to basepair 'S',
%               (K_2^{\alpha\beta}, eq. 29, pag. 9);
%      - 'c18': the 18x1 weighted shape vector corresponding
%               to basepair 'S',
%               (\sigma_2^{\alpha\beta}, eq. 30, pag. 9);
%   
%    - 'base':  a 1x4 struct array with fields: 
%      - 'S': the base as a character, 
%             (i.e. 'A', 'G', 'C' or 'T');
%      - 'b': the 6x6 stiffness block corresponding
%             to base 'S',
%             (K_1^{\alpha}, eq. 29, pag. 9);
%      - 'c': the 6x1 weighted shape vector corresponding
%             to base 'S',
%             (\sigma_1^{\alpha}, eq. 30, pag. 9);
%      
%    Note that in the provided 'cgDNAparamset1.mat', dimer(17) 
%    and base(5) contain arithmetic averages of each field
%    of the preceding elements in the array.
%
%
% Note 2:
%
%    The entries in the variables shapes and stiff
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
%     shapes((a-1)*12+1) = Buckle at basepair a
%     shapes((a-1)*12+2) = Propeller at basepair a
%      ...
%     shapes((a-1)*12+6) = Stagger at basepair a
%     shapes((a-1)*12+7) = Tilt at junction a, a+1
%     shapes((a-1)*12+8) = Roll at junction a, a+1
%      ...
%     shapes((a-1)*12+12) = Rise at junction a, a+1.
%
%    Correspondingly, we have
%
%     stiff(i,j) = stiffness coefficient for the pair of
%                  coordinates shapes(i) and shapes(j).
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

    dimer = params.dimer;
    base  = params.base;

    % Initialize variables
    seq = upper(seq);
    nbp = numel(seq);
    nv = 12; nover = 6;
    N = nv*(nbp-1)+nover;
    nz = (nv^2 + 2*nv*nover) * (nbp-1) + nover^2;
    stiff = spalloc(N,N,nz);
    sigma = zeros(N,1);


    % Assemble stiffness matrix 'stiff' and sigma vector 'sigma'
    fprintf('Constructing stiffness matrix...\n');tic;
    for i = 1:nbp
        k = (i-1)*12 + 1;
        if(i < nbp)
            stiff(k:k+17,k:k+17) = stiff(k:k+17,k:k+17) + dimer(fsi(dimer,seq(i:i+1))).b18;
            sigma(k:k+17) = sigma(k:k+17) + dimer(fsi(dimer,seq(i:i+1))).c18;
        end
        stiff(k:k+5,k:k+5) = stiff(k:k+5,k:k+5) + base(fsi(base,seq(i))).b;   
        sigma(k:k+5) = sigma(k:k+5) + base(fsi(base,seq(i))).c;   
    end

    % Compute ground-state coord vector via matrix inversion 
    fprintf('Constructing ground-state shape...\n');toc
    shapes = stiff\sigma;

end

%--------------------------------------------------------
function i = fsi(struc, s)

    n = size(struc);

    for j = 1:n(2)
        if(strcmpi(struc(j).S,s)) 
            i=j; 
            return;
        end;    
    end    

end
