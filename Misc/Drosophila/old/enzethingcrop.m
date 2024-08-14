function enzethingcrop(fig, xrng)


%Copy figure
fg = copyobj(fig, 0);

%Get children

axs = fg.Children;

for i = 1:length(axs)
    ax = axs(i);
    
    %Only do axes
    if ~isa(ax, 'matlab.graphics.axis.Axes')
        continue
    end
    
    ch = ax.Children;
    
    
    
    %Crop to xrng, inclusive
    for j = 1:length(ch)
        ob = ch(j);
        ki = ob.XData >= xrng(1) & ob.XData <= xrng(2);
        set(ob, 'XData', ob.XData(ki), 'YData', ob.YData(ki))
        
        %And set XData(1) to 1
        set(ob, 'XData', ob.XData - min(ob.XData) + 1 )
    end
    
    xlim(ax, xrng - xrng(1) + 1)
end

