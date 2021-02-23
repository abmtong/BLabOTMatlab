function rulerAlignChk(outraw)

%Plot 'goodness' of rulerAlign from outraw output


if iscell(outraw)
    cellfun(@rulerAlignChk, outraw)
end

%Hard-coded to be the Antony repeat for now
opts.per = 239;
opts.persch = [.9 1.1];
opts.perschd = .05;

figure('Name', sprintf('Scale: %0.2f, Offset: %0.2f', outraw.scl, outraw.off))
subplot(3,1,1);
persn = (opts.persch * opts.per)/opts.perschd; %Generate range
persn = floor(persn(1)):ceil(persn(2)); %Periods in number of binsizes
pers = persn * opts.perschd; %Periods in bp
plot(pers, outraw.sclraw)
title('Period score')

subplot(3,1,2)
nx = length(outraw.ohist);
hx = (1:nx)/nx*opts.per;
plot(hx, outraw.ohist)
title('Offset score')

subplot(3,1,3)
plot(hx, outraw.rephist)
px = [83 108 141 168 236];
hold on
arrayfun(@(x) line(x*[1 1], ylim), px)
title('Res time histogram')
