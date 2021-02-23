function combine2figforpaper_pt2(fg)

if nargin < 1
    fg = gcf;
end
%Check normalization

axs = fg.Children;

for i = 1:length(axs)
    ch = axs(i).Children;
    
    %Want the areas of plots 4, 6 to equal area of plot 2
    ar2 = sum( abs(ch(2).XData -1 )) * median(abs(diff(ch(2).YData)));
    ar4 = sum( abs(ch(4).XData -3 ))* median(abs(diff(ch(4).YData)));
    ar6 = sum( abs(ch(6).XData -2 ))* median(abs(diff(ch(6).YData)));
    
    ymult = ar2/mean([ar4 ar6]);
    
    ch(2).XData = 1+ (ch(2).XData-1)/ymult;
    ch(1).XData = 1+ (ch(1).XData-1)/ymult;
    
end