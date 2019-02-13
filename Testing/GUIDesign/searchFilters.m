function searchFilters(data, filfcn, filopts)
%Tests effect of filtering on one trace using @windowFilter(filfcn, data, ...) where each row of filopts is [width dec]

len = size(filopts, 1);

for i = 1:len
    dataf = windowFilter(filfcn, data, filopts(i,1),filopts(i,2));
    figure('Name', sprintf('%sW%dD%d',func2str(filfcn), filopts(i,:)))
    ax3 = subplot(4,1,4);
    [~, ~, t] = fsChSq(dataf,[],1);
    ax1 = subplot(4,1,[1 2]);
    plottt(dataf, t)
    ax2 = subplot(4,1,3);
    plot(dataf-t)
    linkaxes([ax1, ax2], 'x')
end