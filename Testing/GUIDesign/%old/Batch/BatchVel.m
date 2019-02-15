function out = BatchVel(filteropts, fSamp, inStr)

if nargin < 3
    inStr = [];
end
if nargin<2 || isempty(fSamp)
    fSamp = 2500;
end
if nargin < 1 || isempty(filteropts)
    filteropts = {@mean, [], 10};
end

function outVel = findVel(inTrace)
    tr = windowFilter(filteropts{1},inTrace,filteropts{2:end});
    pf = linfit(1:length(tr),tr);
    outVel = -pf(1);
end

res = BatchDo(@findVel, inStr);
out = collapseCell(res) * fSamp / filteropts{3};

p = normHist(out, 5);
figure, bar(p(:,1),p(:,2))

end