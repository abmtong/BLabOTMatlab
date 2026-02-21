function out = simTraceClpX_penalty()

fil = 10;
Fs = 2500;

sszdist = [0 1 0];
% sszdist = [1 1 1];
noi = 3;
% noi = 4.5;
kvpfs = single([1 2 2.5 3 5 10]);

tbinsz = .02;%sec
xbinsz = .1; %nm

nrep = 1e3;

[tra, tranoi, kvtra] = arrayfun(@(x)simTraceClpX(sszdist, noi, kvpfs(1), 0), 1:nrep, 'Un', 0);
%ground truth, with noise, stepfound

tranoif = cellfun(@(x) windowFilter(@mean, x, [], fil), tranoi, 'Un', 0);

%Do stepfinding

nn = length(kvpfs);
tmp = cell(1,nn);
for i = 1:nn
    [~, ~, tmp{i}] = BatchKV(tranoif, kvpfs(i));
end

%gt

[in, me] = cellfun(@tra2ind, tra, 'Un', 0);
dw = cellfun(@diff, in, 'Un', 0);
st = cellfun(@diff, me, 'Un', 0);


figure
subplot(2,1,1)
hold on
[p, x] = nhistc([dw{:}]/Fs, tbinsz);
plot(x,p, 'k')

lgn = arrayfun(@(x) sprintf('Stepfinding, penalty = %0.2f', x), kvpfs, 'Un', 0);

for i = 1:nn
    [kvin, kvme] = cellfun(@tra2ind, tmp{i}, 'Un', 0);
    kvdw = cellfun(@diff, kvin, 'Un', 0);
    kvst = cellfun(@diff, kvme, 'Un', 0);
    [p, x] = nhistc([kvdw{:}]*fil/Fs, tbinsz);
    plot(x,p)
end

legend([{'Ground-truth'} lgn])
ylabel('Probability Density')
xlabel('Dwell Time (s)')

subplot(2,1,2)
hold on
for i = 1:nn
    [kvin, kvme] = cellfun(@tra2ind, tmp{i}, 'Un', 0);
    kvdw = cellfun(@diff, kvin, 'Un', 0);
    kvst = cellfun(@diff, kvme, 'Un', 0);
    [p, x] = nhistc(-[kvst{:}], xbinsz);
    plot(x,p)
end

% [p, x] = nhistc(-[kvst{:}], xbinsz);
% plot(x,p)
legend(lgn)
ylabel('Probability Density')
xlabel('Step Size (nm)')


%Plot 10 random traces with fitting
nplot = 10;
rp = randperm(nrep, nplot);
for i = 1:nplot
    ii = rp(i);
    %Get data
    tr = tranoi{ii};
    gt = tra{ii};
    xx = (1:length(tr))/Fs;
    
    
    figure, hold on
    plot(xx,tr, 'Color', [.7 .7 .7]);
    plot(xx,gt, 'k')
    
    for j = 1:nn
        %Need to un-decimate stepfound traces
        [in, me] = tra2ind(tmp{j}{ii});
        in = [1 in(2:end-1)*fil length(gt)];
        
        plot(xx,ind2tra(in,me)+j)
    end
    
    legend([{'Data' 'Ground Truth'} lgn])
     xlabel('Time (s)')
     ylabel('Extension (nm)')
    
end





