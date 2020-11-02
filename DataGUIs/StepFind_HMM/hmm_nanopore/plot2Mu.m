function out = plot2Mu(rawA, rawB)
%Plots a violin of two opts

if nargin < 2
    rawB = rawA;
end

ns = length(rawA(1).raw);

%Concatenate
rA = sortraw(rawA);
rB = sortraw(rawB);

%Plot violin

figure, 
violin(rA, 'x', 1:ns, 'facecolor', [1 0 0]);
violin(rB, 'x', (1:ns)+.4, 'facecolor', [0 1 0]);


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