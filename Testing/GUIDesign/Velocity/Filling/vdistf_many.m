function out = vdistf_many(inxs, names, opts)

%Input is cell of FCs, and their names

if nargin < 3
    opts = [];
end

opts.verbose = 0;

vdfs = cellfun(@(x) vdist_filling(x, opts), inxs, 'Un', 0);
%{vs vsd vn cbinx cbinpct pau fitmat};

%Plot vdists
vdistx = cellfun(@(x) x(5), vdfs);
vdisty = cellfun(@(x) x(1), vdfs);
figure Name vdm_vdist
set(gcf, 'Color', [1 1 1])
hold on
cellfun(@(x,y)plot(x,smooth(y,3)', 'LineWidth', 1), vdistx, vdisty)
legend(names{:})
xlabel('Percent Packaged')
ylabel('Velocity (bp/s)')
set(gca, 'FontSize', 16)
axis tight
ylim([0 inf])

%Plot pausepcts
ppcty = cellfun(@(x) x(6), vdfs);
figure Name vdm_ppct
set(gcf, 'Color', [1 1 1])
hold on
cellfun(@(x,y)plot(x,100*smooth(y,3)', 'LineWidth', 1), vdistx, ppcty);
legend(names{:});
xlabel('Percent Packaged')
ylabel('Percent Paused')
set(gca, 'FontSize', 16)
axis tight
ylim([0 inf])

out = vdfs;
