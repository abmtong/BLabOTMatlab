function out = simTraceClpX_sszdist()

fil = 10;
Fs = 2500;

sszdist = [0 1 0];
% sszdist = [1 1 1];
% noi = 3;
noi = 4.5;
kvpf = single(2.5);

tbinsz = .02;%sec
xbinsz = .1; %nm

nrep = 1e3;

[tra, tranoi, kvtra] = arrayfun(@(x)simTraceClpX(sszdist, noi, kvpf, 0), 1:nrep, 'Un', 0);
%ground truth, with noise, stepfound

[kvin, kvme] = cellfun(@tra2ind, kvtra, 'Un', 0);
[in, me] = cellfun(@tra2ind, tra, 'Un', 0);

dw = cellfun(@diff, in, 'Un', 0);
kvdw = cellfun(@diff, kvin, 'Un', 0);

st = cellfun(@diff, me, 'Un', 0);
kvst = cellfun(@diff, kvme, 'Un', 0);

figure
subplot(2,1,1)
hold on
[p, x] = nhistc([dw{:}]/Fs, tbinsz);
plot(x,p, 'k')
[p, x] = nhistc([kvdw{:}]*fil/Fs, tbinsz);
plot(x,p)
legend({'Ground-truth' 'Stepfinding'})
ylabel('Probability Density')
xlabel('Dwell Time (s)')

subplot(2,1,2)
hold on
[p, x] = nhistc(-[st{:}], xbinsz);
% plot(x,p, 'k')
[p, x] = nhistc(-[kvst{:}], xbinsz);
plot(x,p)
legend({'Stepfinding'})
ylabel('Probability Density')
xlabel('Step Size (nm)')








