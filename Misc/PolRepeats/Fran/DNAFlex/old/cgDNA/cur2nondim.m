function [ndshapes] = cur2nondim(cshapes)

%-------------------------------------------------------
% cgDNA function: [ndshapes] = cur2nondim(cshapes)
%-------------------------------------------------------
% This function transforms the ground-state coordinates
% from the standard (dimensional) Curves+ form to the 
% non-dimensional Curves+ form.
%
% Input: 
%
%   cshapes  ground-state coordinate vector 
%            in standard Curves+ form
%            [size N x 1].
%
% Output:
%
%   ndshapes  ground-state coordinate vector 
%             in non-dimensional Curves+ form
%             [size N x 1]
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

    [etac, wc, uc, vc] = vector2shapes(cshapes);

    cay    = etac;
    ncay   = sqrt(sum(cay.^2,2));
    tangle = 10 * tan(0.5 * ncay/180*pi);
    eta    = bsxfun(@times, tangle, bsxfun(@rdivide, cay, ncay));

    cay    = uc;
    ncay   = sqrt(sum(cay.^2,2));
    tangle = 10 * tan(0.5 * ncay/180*pi);
    u      = bsxfun(@times, tangle, bsxfun(@rdivide, cay, ncay));

    ndshapes = shapes2vector(eta, wc, u, vc);

end
