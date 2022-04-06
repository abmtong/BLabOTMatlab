function out = fmtResTimesp2(p1, inOpts)

%Compare positions via ttest, check if they're the same?
% does ttest work ok for this case? CLT suggests so / close enough
% Let's see...

%For each group in p1...
fns = fieldnames(p1);
len = length(fns);
out = cell(1,len);
for i = 1:len
    %Grab values
    x = [ p1.(fns{i}).pre.x p1.(fns{i}).rpt.x p1.(fns{i}).pos.x ];
    y = [ p1.(fns{i}).pre.y p1.(fns{i}).rpt.y p1.(fns{i}).pos.y ];
    %Compare the ith and jth via ttest
    hei = length(x);
    mtr = zeros(hei);
    for j = 1:length(x)
        [~, mtr(j,1:j)] = cellfun(@(z) ttest2( y{j}, z ), y(1:j));
    end
    %Transpose
    mtr = mtr + mtr' - diag(ones(1,hei));
    out{i} = {x mtr};
    %Plot this matrix
    plotx = [ p1.(fns{i}).pre.x p1.(fns{i}).rpt.x p1.(fns{i}).pos.x - p1.(fns{i}).pos.x(1) + p1.(fns{i}).rpt.x(end) + 1 ];
    [xx, yy] = meshgrid(plotx, plotx);
    figure('Name', fns{i}), surface(xx, yy, mtr, 'EdgeColor', 'interp'), colormap([ repmat([1 1 1], 5, 1) ;repmat([0 0 0], 95, 1)])
end
