function out=  ttestmatrix(indata, n)
if nargin < 2
    n = length(indata);
end
out = zeros(n);
for i = 1:n
    for j = 1:n
        if i >= j 
            continue
        end
        [~, out(i,j)] = ttest2(double(indata{i}), double(indata{j}), 'VarType', 'unequal');
    end
end
