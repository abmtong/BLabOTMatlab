function out = splitN (input, numBins)
%Splits input[] into N bins, distributed sequentially, i.e. the ith row is in bin (i mod N)
%If input is a row vector (first dimension length 1), returns it as a column vector

%This is pretty inefficient, just do reshape

%Set defaults
if nargin < 2
    numBins = 2;
end

%Detect if input is a row vector, then xform into col vector
sz = size(input);
if(sz(1) == 1)
    input = input';
end

for i = 1:numBins
    name = ['r' num2str(i)];
    out.(name) = input(i:numBins:end,:,:,:,:,:);
end