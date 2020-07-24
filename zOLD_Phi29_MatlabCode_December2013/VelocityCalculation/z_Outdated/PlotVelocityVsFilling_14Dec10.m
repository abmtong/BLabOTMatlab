figure; hold on;
%%
%for i=1:length(Bin.Start)
%    plot(ones(1,length(Bin.Velocity{i}))*(Bin.Start(i)+Bin.End(i))/2, Bin.Velocity{i},'.y');
%end

for i=1:length(Bin.Start)
    %plot((Bin.Start(i)+Bin.End(i))/2, mean(Bin.Velocity{i}),'ok');
    errorbar((Bin.Start(i)+Bin.End(i))/2000, ...
    mean(Bin.Velocity{i}), ...
    std(Bin.Velocity{i})/sqrt(Bin.SampleNumber(i)),'.b');
end
%%
xlabel('Capsid Filling (kb)');
ylabel('Packaging Velocity (bp/sec)');
title('WT (black) vs F6F7 pRNA Mutant (blue) At 1000uM ATP');