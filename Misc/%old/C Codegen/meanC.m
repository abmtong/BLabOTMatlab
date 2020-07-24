function out = meanC(in) %#codegen
%MEAN Summary of this function goes here
%   Detailed explanation goes here
assert(isa(in, 'double'));
assert(isequal(size(in),[3,3]));
out = mean(in);

end

