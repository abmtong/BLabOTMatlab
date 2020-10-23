function plotMus(mu0, optcell)

%Plots multiple opt structs [output of optHMMNP_rec]
figure, hold on
ns=256;
if ~isempty(mu0)
    %Plot starting as red
    plot( mu0, (1:256) + .1, 'ro' )
end

if ~iscell(optcell)
    optcell = {optcell};
end

for i = 1:length(optcell)
    raws = optcell{i};
    %Code below is essentially @updateMu
    
    %Concatenate and average together
    r = {raws.raw};
    r = [r{:}];
    r = reshape(r, ns, []);
    
    outraw = cell(1,ns);
    for j = 1:ns
        snp = r(j,:);
        snp = cellfun(@(x) x(:)', snp, 'Un', 0);
        snp = [snp{:}];
        outraw{j} = snp;
    end
    out = cellfun(@mean, outraw);
    
    %Plot comparison
    xx = (1:256) - (i-1)*0.1;
    plot(out, xx, 'o');
    cellfun(@(x,y)plot(x,zeros(1,length(x)) + y, '*',  'Color', .7 * ones(1,3)), outraw, num2cell(xx));
%     plot(prev, (1:ns)+.1, 'or');
    ylim([0 ns+1])
end