function plotNMu(rawc)
%Plots a violin of N opts

if ~iscell(rawc)
    rawc = {rawc};
end

n = length(rawc);
ns = length(rawc{1}(1).raw);

sds = zeros(ns,n);
mds = zeros(ns,n);

%Plot violins
figure
for i = 1:n
    r = sortraw(rawc{i});
    violin(r, 'x', (1:ns) + (i-1)/(n+1), 'width', .5/(n+2) , 'facecolor', getcol(i,n));
    sds(:,i) = cellfun(@std, r);
    mds(:,i) = cellfun(@(x)mad(x,1)/2/erfinv(.5), r);
end
sds = sds';
mds = mds';

%Plot vars
figure, hold on
plot(sds, 'Color', [1 .5 .5])
plot(mds, 'Color', [.5 1 .5])
plot(mean(sds,2), 'LineWidth', 2', 'Color', 'r')
plot(mean(mds,2), 'LineWidth', 2', 'Color', 'g')


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