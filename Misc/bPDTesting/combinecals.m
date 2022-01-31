function combinecals(fg)

if nargin < 1
    fg = gcf;
end

axs = fg.Children;
lnbx = axs(2).Children(end); %axs order is BY BX AY AX
lnax = axs(4).Children(end); %plot order is [text fit? fitdata? rawdata]0


% axmult = 1/0.211^2;
% bxmult = 1/2.4762^2;

axmult = 1/median(lnax.YData);
bxmult = 1/median(lnbx.YData);

%Join to graph, scale

figure
ax = gca;
newax = copyobj(lnax, ax);
newbx = copyobj(lnbx, ax);
newax.YData = newax.YData * axmult;
newbx.YData = newbx.YData * bxmult;
newax.Color = [0        0.447        0.741];
newbx.Color = [ 0.85        0.325        0.098];

ax.YScale = 'log';
ax.XScale = 'log';