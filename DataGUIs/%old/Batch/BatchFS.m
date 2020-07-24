function out = BatchFS(sfFcn, filOpts, stepOpts, inStr)

if nargin < 3
    inStr = [];
end
if nargin < 2 || isempty(stepOpts)
    stepOpts = {};
end
if nargin < 1
    filOpts = {@mean, [], 10};
end

function outSteps = findSH(inTrace)
    if ~isempty(filOpts)
        inTrace = windowFilter(filOpts{1},inTrace,filOpts{2:end});
    end
    [~, outMeans] = sfFcn(inTrace, stepOpts{:});
    outSteps = -diff(outMeans);
end


res = BatchDo(@findSH, inStr);
out = collapseCell(res);

p = normHist(out, 0.1);
figure Name BatchFindSteps, bar(p(:,1),p(:,2))

end