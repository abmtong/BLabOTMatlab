function [out, outraw] = updateMu(raws, prev, verbose)

if nargin < 3
    verbose = 1;
end

if nargin < 2
    prev = [];
end

%raws is a 1xn struct with field raw : 1x256 cell of column vectors of raw levels

ns = length(raws(1).raw);

%Concatenate and average together
r = {raws.raw};
r = [r{:}];
r = reshape(r, ns, []);

outraw = cell(1,ns);

for i = 1:ns
    snp = r(i,:);
    snp = cellfun(@(x) x(:)', snp, 'Un', 0);
    snp = [snp{:}];
    outraw{i} = snp;
end

out = cellfun(@mean, outraw); %Should I use mean or median?

if verbose == 2
    %Plot violin
    %@violin doesn't like empty cells. Replace
    or = outraw;
    or(cellfun(@isempty, or)) = {10};
    figure, violin(or)
else
    %Plot comparison
    figure, hold on
    plot(out, (1:ns), 'o');
    cellfun(@(x,y)plot(x,randn(1,length(x))/4*.05 + y+.05, '*',  'Color', .7 * ones(1,3)), outraw, num2cell(1:256));
    if ~isempty(prev)
        plot(prev, (1:ns)+.1, 'or');
    end
    ylim([0 ns+1])
end

if ~isempty(prev)
    %Replace NaNs with prev
    ki = isnan(out);
    out(ki) = prev(ki);
    fprintf('%d/%d values updated\n', sum(~ki), ns)
end