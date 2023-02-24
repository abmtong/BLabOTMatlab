function out = sumNucHistWee_kdf(inst, opts)

opts.verbose = 0;
fil = 200;
kdfsd = 4;
kdfroi = [-10 200];
binsz = 0.1;


figure('Name', 'sNHW', 'Color', [1 1 1])
hold on
len = length(inst);

out = cell(1,len);
for i = 1:len
    %Filter down
    dat = inst(i).con;
    datF = cellfun(@(x) windowFilter(@mean, x, fil, 1), dat, 'Un', 0);
    
    %Make monotonic
    datFM = cellfun(@makeMono, datF, 'Un', 0);
    
    %Make kdf
    [kdfs, xx] = cellfun(@(x) kdf(x, binsz, kdfsd, kdfroi), datFM, 'Un', 0);
    xx = xx{1}; 
    
    %NaN it out past the last point
    maxy = cellfun(@(x)prctile(x,99), datFM);
    
%     %Optional: only choose crossers
%     ki = maxy > 120;
%     kdfs = kdfs(ki);
    
    for j = 1:length(kdfs)
        kdfs{j}(xx > (maxy(j) + 2*kdfsd )) = nan;
    end
    
    %And average
    out{i} = mean( reshape([kdfs{:}], length(xx), []) , 2, 'omitnan' )';
    
    
%     [y, x] = sumNucHist(inst(i).con, opts);
    plot(xx,out{i})
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