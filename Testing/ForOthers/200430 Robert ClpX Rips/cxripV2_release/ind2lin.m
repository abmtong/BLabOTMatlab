function [outx, outy] = ind2lin(in, me)
%Outputs the minimum points to create a staircase [i.e. like a tra but unsampled x]

% in([ 1 2 2 3 3 4 4 ... end-1 end-1 end]);
% me([1 1 2 2 3 3 4 4 ... end end]);

outx = in( repmat( 1:length(in) , [2 1]) );
outx = outx(2:end-1);

outy = me( repmat( 1:length(me) , [2 1]) );
outy = outy(:)';