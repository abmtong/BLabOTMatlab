function out = combine2btfigforpaper2(fgih, fgrr)

%Combines bt figs 

%Take first graph from IH [IH loF] , then first RR graph [RR loF]

%This is order [fglo, first plotted], [fg, first plotted], [fg, last plotted]

%start with fg as base
newfg = copyobj(fgih, 0);

%For each axs in this figure...
axih = newfg.Children;
axrr = fgrr.Children;

%Sometimes there's non-axes stuff (selections), just keep axes
axih = axih( arrayfun(@(x)isa(x, 'matlab.graphics.axis.Axes') , axih));
axrr = axrr( arrayfun(@(x)isa(x, 'matlab.graphics.axis.Axes') , axrr));

for i = 1:length(axih)
    %Recolor IH graph
    axih(i).Children(end).FaceColor = [0 153 0]/255;
    
    %Copy graph from RR, move over, recolor to red
    ob2 = copyobj(axrr(i).Children(end), axih(i));
    ob1 = copyobj(axrr(i).Children(end-1), axih(i));
    ob1.XData = ob1.XData + 1;
    ob2.XData = ob2.XData + 1;
    ob2.FaceColor = [1 0 0];
    xlim(axih(i),[0 3]);
end

