ffcns = {@median, @mean, @gaussMean, @gaussDiffMean, @gaussDerivMean};
width = {1, 1, 1, 12, 12, 12};
dec = 25;
%name trace guiC
ax = gobjects(1,length(ffcns));
for i = 1:length(ffcns)
    tr = windowFilter(ffcns{i}, guiC, width{i},dec);
    
    hv4 = findStepHistV4(tr,0.2);
  %  hv5 = findStepHistV5(tr,0.2);
    hv6 = findStepHistV6(tr,0.2);
    figure('Name',func2str(ffcns{i}));
    hold on;
    len = length(guiC);
    plot((1:len)/dec, guiC,'Color',[.8 .8 .8]);
    ax(i) = gca;
    plot(tr,'Color', [.4 .4 .4])
    plot(hv4)
  %  plot(hv5)
    plot(hv6)
    hold off
end
linkaxes(ax,'xy')