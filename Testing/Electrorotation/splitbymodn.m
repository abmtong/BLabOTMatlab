function [outx, outys, outysds, outyns, inds] = splitbymodn(inx, inys, n)

%Handles both array and cell of arrays inys, so make cell (undo later)
if ~iscell(inys)
    inys = {inys};
end

%Find uniques mod n. Use uniquetol to account for differences ~ eps
[outx, ~, inds] = uniquetol(mod(inx, n), eps(max(abs(inx)))*10);

outys = repmat({zeros(1,length(outx))}, 1, length(inys));
outysds = repmat({zeros(1,length(outx))}, 1, length(inys));
outyns = zeros(1,length(outx));
for j = 1:length(inys)
    tmp = inys{j};
    tmpme = zeros(1,length(outx));
    tmpsd = zeros(1,length(outx));
    for i = 1:length(outx)
        ti = tmp(inds == i);
        %Remove outliers. We'll have ~10 samples, so use zsc = 2.
        zsc = 2;
        while true
            tmn = mean(ti);
            tsd = std(ti);
            ki = ti > tmn - tsd * zsc & ti < tmn + tsd * zsc;
            if all(ki)
                break
            end
            ti = ti(ki);
        end
        tmpme(i) = mean(ti);
        tmpsd(i) = std(ti);
        outyns(i) = sum(ti);
    end
    outys{j} = tmpme;
    outysds{j} = tmpsd;
end
%sort, just in case
[outx, si] = sort(outx);
outys = cellfun(@(x) x(si), outys, 'Un', 0);
outysds = cellfun(@(x) x(si), outysds, 'Un', 0);
inds = inds(si);
if length(inys) == 1
    outys = outys{1};
    outysds = outysds{1};
end