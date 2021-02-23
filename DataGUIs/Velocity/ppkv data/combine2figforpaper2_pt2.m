function combine2figforpaper2_pt2(fg)
%Fix norm for IH/RR graph

if nargin < 1
    fg = gcf;
end
%Check normalization

axs = fg.Children;

for i = 1:length(axs)
    ch = axs(i).Children;
    
    %Want the areas of plot 2 [red, RR] to equal plot 4 [IH]
    ar2 = sum( abs(ch(2).XData -2 )) * median(abs(diff(ch(2).YData)));
    ar4 = sum( abs(ch(4).XData -1 ))* median(abs(diff(ch(4).YData)));
%     ar6 = sum( abs(ch(6).XData -2 ))* median(abs(diff(ch(6).YData)));
    
    ymult = ar4/ar2 ;
    
    %But also maximize all x's at +- 0.45
    
    mx4 = max(ch(4).XData-1)/ymult;
    mx2 = max(ch(2).XData -2);
    mul = max(mx4, mx2) / 0.45;
    
    ch(4).XData = 1+ (ch(4).XData-1)/ymult/mul;
    ch(3).XData = 1+ (ch(3).XData-1)/ymult/mul;
    
    
    ch(2).XData = 2+ (ch(2).XData-2)/mul;
    ch(1).XData = 2+ (ch(1).XData-2)/mul;
    
    
    
end