function out = BatchVelCell(inContour, filteropts, fSamp)

if nargin<3 || isempty(fSamp)
    fSamp = 2500;
end
if nargin < 2 || isempty(filteropts)
    filteropts = {@mean, [], 10};
end

function outVel = findVel(inTrace)
    tr = windowFilter(filteropts{1},inTrace,filteropts{2:end});
    %pf = linfit(1:length(tr),tr);
    pf = linfit(tr);
    outVel = -pf(1);
end

vels = cellfun(@findVel, inContour);
out = vels * fSamp / filteropts{3};

p = normHist(out, 5);
figure, bar(p(:,1),p(:,2))

end