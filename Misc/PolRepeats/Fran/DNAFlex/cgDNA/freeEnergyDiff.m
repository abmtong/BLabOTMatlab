function [deltaU] = freeEnergyDiff(config1, config2, nondimshapes, stiff)

%--------------------------------------------------------
% cgDNA function: [deltaU] = freeEnergyDiff(config1, config2, nondimshapes, stiff)
%--------------------------------------------------------
% Calculate the free energy difference between two
% configurations of a B-DNA molecule, given its
% ground-state conformation and stiffness.  The free
% energy difference is provided in units of kbT.  Note
% that the parameter set cgDNAparamset1 was extracted
% from MD simulations at 300K. The model free energy
% value in kcal/mol can therefore be obtained by
% multiplying by (0.0019872041 * 300.0).
% 
% The frustration part of the free energy is omitted in
% this calculation, as it cancels when calculating free
% energy differences between configurations of the same
% DNA molecule.
%
%
% Input:
%
%   config1      first configuration coordinate vector 
%                in non-dimensional Curves+ form
%                [size N x 1]
%   
%   config2      second configuration coordinate vector 
%                in non-dimensional Curves+ form
%                [size N x 1]
%   
%   nondimshapes ground-state coordinate vector 
%                in non-dimensional Curves+ form
%                [size N x 1]
%
%   stiff        ground-state stiffness matrix
%                in non-dimensional Curves+ form
%                [size N x N]
%
%   where N = 12*nbp - 6 and nbp is the length of the
%   sequence (number of basepairs). 
% 
%
% Output:
% 
%   deltaU       the free energy difference in kbT.
%
%
% Note 1:
% 
%    The ground-state conformation and stiffness for a given
%    DNA sequence can be obtained using constructSeqParms 
%    (see "help constructSeqParms").
%
%
% Note 2:
%
%    The entries of the input variables config1, config2,
%    nondimshapes and stiff must be consistent with the following
%    ordering of the structural coordinates
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
%----------------------------------------------------------

    U1 = 0.5*(config1 - nondimshapes)'*stiff*(config1 - nondimshapes);
    U2 = 0.5*(config2 - nondimshapes)'*stiff*(config2 - nondimshapes);

    deltaU = ( U2 - U1 );
end
