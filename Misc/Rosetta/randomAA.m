function out = randomAA(n, method)

%n = number of amino acids
if nargin < 1
    n = 100;
end

%method : use natural distribution of AAs (method == 1) or random (== 2)
if nargin < 2
    method = 1;
end

%The 20 amino acids, 1-char code alphabetical by name
dict = 'ARNDCEQGHILKMFPSTWYV';
%Their corresponding 'natural' distribution
wgh = [.074 .042 .044 .059 .033 .058 .037 .074 .029 .038 .076 .072 .018 .040 .050 .080 .062 .013 .033 .068];
%Using http://www.tiem.utk.edu/~gross/bioed/webmodules/aminoacid.htm ; should check their cited papers
% Edited Ser .081 to .080 to make sum(weights) == 1 (Ser is the highest occurring, so affects it the least)
csw = cumsum(wgh);

%Note that these seem to be indeed randomly distributed on the DNA level except for Arg, meaning more codons and more common NTPs (A>G>U=C) = more prevalence

switch method
    case 1
        rng = arrayfun(@(x) find(x<csw, 1, 'first'), rand(1,n));
    case 2
        rng = randi(20,1,n);
end

out = dict(rng);