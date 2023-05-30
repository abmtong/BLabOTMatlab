function [curshapes] = nondim2cur(shapes)

%-------------------------------------------------------
% cgDNA function: [curshapes] = nondim2cur(shapes)
%-------------------------------------------------------
% This function transforms the ground-state coordinates
% from non-dimensional Curves+ form to the standard
% (dimensional) Curves+ form.
%
% Input: 
%
%   shapes  ground-state coordinate vector 
%           in non-dimensional Curves+ form
%           [size N x 1].
%
% Output:
%
%   curshapes  ground-state coordinate vector 
%              in standard Curves+ form
%              [size N x 1]
%
%   where N = 12*nbp - 6 and nbp is the length 
%   of the DNA sequence (number of basepairs).
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


    [eta, w, u, v] = vector2shapes(shapes);

    cay   = eta/10;
    ncay  = sqrt(sum(cay.^2,2));
    angle = 2*atan(ncay)/pi*180;
    etac  = bsxfun(@times, angle, bsxfun(@rdivide, cay, ncay));

    cay   = u/10;
    ncay  = sqrt(sum(cay.^2,2));
    angle = 2*atan(ncay)/pi*180;
    uc    = bsxfun(@times, angle, bsxfun(@rdivide, cay, ncay));

    curshapes = shapes2vector(etac, w, uc, v);

end
