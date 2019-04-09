function lof2vel_p2(axs)
%combines 4 axes into one chart

fg = figure('Name', 'Velocity Distribution', 'Color', [1 1 1]);
len = length(axs); %should be 4
naxs = gobjects(1,len);
% ylbls = {'DNA/DNA' 'DNA/RNA' 'RNA/DNA' 'RNA/RNA'};
for i = 1:len
    naxs(i) = copyobj(axs(i), fg);
    naxs(i).Position = [.1 .9-.2*i .8 .2];
end
linkaxes(naxs, 'xy')
xlim([-40 80])