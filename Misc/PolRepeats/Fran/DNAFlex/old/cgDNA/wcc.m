function complementary = wcc(sequence,varargin)

%-------------------------------------------------------
% cgDNA function: complementary = wcc(sequence,varargin)
%-------------------------------------------------------
% Compute the sequence of the Watson-Crick Complementary
% strand of the provided DNA sequence.
%
% Input: 
%
%   sequence     a sequence of valid DNA base 
%                single-letter codes (i.e. 'A', 'C', 'G' 
%                or 'T');
%
%   [ dir ]      optional argument: negative values mean
%                the resulting complementary sequence 
%                should be returned in reverse order.
%                By default, dir = 0
%
% Output:
%
%   complementary    the complementary sequence.
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
    
    Watson=['ACGT_'];
    Crick =['TGCA_'];
    sequence = upper(sequence);
    complementary = sequence;
    
    dir = 0; % default: do not reverse complementary sequence
    if nargin > 1
        dir = varargin{1};
    end
        
    for i=1:numel(sequence)
        complementary(i) = Crick(find(Watson==sequence(i)));
    end
    
    if dir < 0
        complementary = complementary(end:-1:1);
    end
end
