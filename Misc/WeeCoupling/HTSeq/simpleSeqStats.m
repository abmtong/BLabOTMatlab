function out = simpleSeqStats(c,cc)

%Plot:
%n ins, del
nsnp = c(2,:);
%Cutoff at 99th percentile
% nsnpmax = prctile(nsnp, 99);
% nsnpmax = 4;
% figure Name nIns, pie( categorical( min(nsnp, nsnpmax) ) );

nsnp = c(3,:);
% %Cutoff at 99th percentile
% nsnpmax = prctile(nsnp, 99);
% figure Name nDel, pie( categorical( min(nsnp, nsnpmax) ) );



%n SNPs dist
nsnp = c(1,:);
%Cutoff at 99th percentile
nsnpmax = prctile(nsnp, 99)+1;
nsnpmax = 4;
figure Name nSNP, pie( categorical( min(nsnp, nsnpmax) ) );
out = histcounts( categorical( min(nsnp, nsnpmax) ) );

% %nAny dist
% nsnp = sum( c, 1);
% %Cutoff at 99th percentile
% nsnpmax = prctile(nsnp, 99)+1;
% nsnpmax = 4;
% figure Name nAny, pie( categorical( min(nsnp, nsnpmax) ) );
% 
% %nSNP+INDEL
% 
% nsnp = c(1,:) & (c(2,:) | c(3,:));
% %Cutoff at 99th percentile
% nsnpmax = inf;%prctile(nsnp, 99)+1;
% nsnpmax = 4;
% figure Name SNP+INDEL, pie( categorical( min(nsnp, nsnpmax) ) );
% 
% 
