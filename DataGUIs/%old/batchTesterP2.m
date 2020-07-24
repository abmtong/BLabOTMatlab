% filters = {@median, @mean, @gaussMean}; % @median, @mean, 
% widths = {3};
% decs =   {2};
% pre = 'histV6';

filePath = uigetdir('C:\Data\JP data may 2017\DNAclip');

if isempty(filePath)
    return;
end

l = length(filters);
w = length(widths);
h = length(decs);

means = zeros(l, w, h);
var1s = zeros(l, w, h);
var2s = zeros(l, w, h);
meaci = zeros(l, w, h);
trez  = zeros(l,w,h);

wb = waitbar(0,'1 1 1');

for i = 1:l;
    for j = 1:w;
        for k = 1:h;
            waitbar( ( (i-1) * w * h + (j-1) * h + (k-1) ) / (l*w*h), wb, [ num2str(i) ' ' num2str(j) ' ' num2str(k)]);
            outstr = [pre 'F' func2str(filters{i}) 'W' num2str(widths{j}) 'D' num2str(decs{k})];
            load([filePath filesep outstr '.mat']);
            dat = collapseCell(outBursts);
            
            dat = dat(dat>0); %only take positive burst sizes, since mle doesnt like negative ones
            [bur, ci] = mle(dat, 'distribution', 'burr');
            means(i,j,k) = bur(1);
            var1s(i,j,k) = bur(2);
            var2s(i,j,k) = bur(3);
            meaci(i,j,k) = (ci(2,1) - ci(1,1))/2;
%             [~, trez(i,j,k)] = ttest2(dat, DgoodDat);
            f = figure('Name',outstr);
            p=(normHist(collapseCell(outBursts),0.2));
            bar(p(:,1),p(:,2))
            zoom on
            savefig(f, [filePath filesep 'FIG' outstr]);
        end
    end
end
delete(wb);