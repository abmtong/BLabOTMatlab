function out = plotNMu(rawc)
%Plots a violin of N opts

if ~iscell(rawc)
    rawc = {rawc};
end

n = length(rawc);
ns = length(rawc{1}(1).raw);

figure
for i = 1:n
    r = sortraw(rawc{i});
    violin(r, 'x', (1:ns) + (i-1)/(n+1), 'width', .5/(n+2) , 'facecolor', getcol(i,n));
    
end

end

function ou = sortraw(in)
ns = length(in(1).raw);
r = {in.raw};
r = [r{:}];
r = reshape(r, ns, []);
ou = cell(1,ns);
for i = 1:ns
    snp = r(i,:);
    snp = cellfun(@(x) x(:)', snp, 'Un', 0);
    snp = [snp{:}];
    %@violin doesn't like empty cells. Replace
    if isempty(snp)
        snp = 10; %Some value
    end
    ou{i} = snp;
    
end

end