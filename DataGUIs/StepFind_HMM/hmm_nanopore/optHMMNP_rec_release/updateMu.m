function [out, outraw] = updateMu(raws, prev, verbose)

if nargin < 3
    verbose = 1;
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

out = cellfun(@mean, outraw); %Should I use median instead?

if nargin > 1
    if verbose
        %Plot comparison
        figure, hold on
        plot(out, (1:ns), 'o');
        cellfun(@(x,y)plot(x,zeros(1,length(x)) + y, '*',  'Color', .7 * ones(1,3)), outraw, num2cell(1:256));
        plot(prev, (1:ns)+.1, 'or');
        ylim([0 ns+1])
    end
    %Replace NaNs with prev
    ki = isnan(out);
    out(ki) = prev(ki);
    fprintf('%d/%d values updated\n', sum(~ki), ns)
end