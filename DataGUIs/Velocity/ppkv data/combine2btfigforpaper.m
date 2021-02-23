function out = combine2btfigforpaper(fg, fglo)

%First convert to violin with plot2violin

%Combines bt figs , fg and fglo)

%We want [light blue] lolo, [blue] reglo, [red] reghi

%This is order [fglo, first plotted], [fg, first plotted], [fg, last plotted]

%start with fg as base
newfg = copyobj(fg, 0);

%For each axs in this figure...
axs = newfg.Children;
axlo = fglo.Children;

%Sometimes there's non-axes stuff (selections), just keep axes
axs = axs( arrayfun(@(x)isa(x, 'matlab.graphics.axis.Axes') , axs));
axlo = axlo( arrayfun(@(x)isa(x, 'matlab.graphics.axis.Axes') , axs));

for i = 1:length(axs)
    %Move first patch and its line to the right
    axs(i).Children(5).XData = axs(i).Children(5).XData +1;
    axs(i).Children(6).XData = axs(i).Children(6).XData +1;
    %Delete second graph
    arrayfun(@delete,axs(i).Children(3:4))
    %Copy graph from fglo, make light blue
    ob2 = copyobj(axlo(i).Children(end), axs(i));
    ob1 = copyobj(axlo(i).Children(end-1), axs(i));
    ob2.FaceColor = [79 209 255]/255;
end

