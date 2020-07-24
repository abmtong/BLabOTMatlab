function lof2pwdv2(dd, dr, rd, rr)

[pdd, pddx] = sumPWDV1b(dd);
delete(gcf);
[pdr, pdrx] = sumPWDV1b(dr);
delete(gcf);
[prd, prdx] = sumPWDV1b(rd);
delete(gcf);
[prr, prrx] = sumPWDV1b(rr);
delete(gcf);

pddx = pddx * .34;
pdrx = pdrx * .34;
prdx = prdx * .34;
prrx = prrx * .34;

figure, plot(prrx, prr)
ax(4) = gca;
figure, plot(prdx, prd);
ax(3) = gca;
figure, plot(pdrx, pdr);
ax(2) = gca;
figure, plot(pddx, pdd);
ax(1) = gca;
len=4;
fg = figure('Name', 'PWDs', 'Color', [1 1 1]);
naxs = gobjects(1,len);
% ylbls = {'DNA/DNA' 'DNA/RNA' 'RNA/DNA' 'RNA/RNA'};
for i = 1:len
    naxs(i) = copyobj(ax(i), fg);
    naxs(i).Position = [.1 .9-.2*i .8 .2];
end
linkaxes(naxs, 'x')