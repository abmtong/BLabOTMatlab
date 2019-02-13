%setup

%figure = gca
ax=gca;
ax.Children;
lns = ans;
ex1 = lns(4);
ex2 = lns(2);
rt1 = lns(3);
rt2 = lns(1);

%xy2png({ex1.XData, rt1.XData ex2.XData-120 rt2.XData-120}, {ex1.YData, rt1.YData ex2.YData rt2.YData}, 1)