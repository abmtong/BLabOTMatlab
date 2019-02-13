ran = 1:12;

err = zeros(1, length(ran));
err2 = zeros(1, length(ran));
for i = ran
    [~, res] = mal_fwt(i, guiC);
    [~,~,tr] = FindStepDWT(guiC,i, 1,1);
    err(i-ran(1)+1) = var(guiC - res);
end
% figure
% hold on
% plot(ran, err)
% plot(ran(2:end), diff(err))
% plot(ran(3:end), diff(diff(err)))