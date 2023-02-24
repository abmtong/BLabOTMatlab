function out = sumNucHistWee(inst, opts)

opts.verbose = 0;

figure('Name', 'sNHW', 'Color', [1 1 1])
hold on
len = length(inst);
for i = 1:len
    [y, x] = sumNucHist(inst(i).con, opts);
    plot(x,y)
end

yl=ylim;
%Green lines at disp locs
for i = 1:length(opts.disp)
    plot([1 1]*opts.disp(i), yl, 'g')
end
%Red lines at disp2 locs
for i = 1:length(opts.disp2)
    plot([1 1]*opts.disp2(i), yl, 'r')
end

xlim([0 150])
legend({inst.name})
ylabel('Residence Time (s/bp)')
xlabel('nt transcribed')