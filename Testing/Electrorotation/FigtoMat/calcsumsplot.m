function calcsumsplot(in)

%in is 3x24 matrix, with columns [nS nH oS oH oSo oHo] x [me sd sem n], rows [1 5 10]' hz

xx = [1 5 10];

%Whether to plot the 'op' protocols or not
plotop = 0;

%Colors to plot: red for hy, blue for syn, op = saturated, nai = not saturated
% cols = { [0 0 1] /3 [1 0 0] /3 [0 0 1] [1 0 0] [0 0 1]*.66 [1 0 0]*.66}; %Same order as above
colh = { [.66 .3 1]  [0 .3 1] [0.66 .9 1]  [0 .9 1] [0.66 .6 1]  [0 .6 1] }; %Same order as above
cols = cellfun(@hsv2rgb, colh, 'un', 0);

fg=figure('Name', 'Plot CalcSum');

hold on
for i = 1:6
    if ~plotop && i>4
        continue
    end
    errorbar(xx, in(:,i), in(:,i+12), 'Color', cols{i}, 'LineWidth', 1.5)
end

xl = [0 11];
xlim(xl)

atp = 294; %-dG of ATP hy at T=1 D=0.1 P=1000 uM
%Draw lines at +- atp
line(xl, atp * [1 1], 'Color', 'k', 'LineWidth', 2)
line(xl, atp * -[1 1], 'Color', 'k', 'LineWidth', 2)

ax=gca;
ax.FontSize = 18;
ax.XTick = xx;
fg.Color = [1 1 1];

xlabel('Rotation Rate (Hz)')
ylabel('Work on bead / rev (pN nm)')