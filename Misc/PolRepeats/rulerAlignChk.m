function rulerAlignChk(outraw, pauloc)


if nargin < 2
    pauloc = [83 108 141 168 236];
end

%Plot 'goodness' of rulerAlign from outraw output
if iscell(outraw)
    cellfun(@rulerAlignChk, outraw)
end


figure('Name', sprintf('Scale: %0.2f, Offset: %0.2f', outraw.scl, outraw.off))
subplot(3,1,1);
plot(outraw.sclrawx, outraw.sclraw)
title('Period score')
axis tight

subplot(3,1,2)
plot(outraw.ohistx, outraw.ohist)
title('Offset score')
axis tight

subplot(3,1,3)
plot(outraw.rephistx, outraw.rephist)
hold on
arrayfun(@(x) line(x*[1 1], ylim), pauloc)
title('Res time histogram')
axis tight
