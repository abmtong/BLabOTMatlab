function batchTesterKV()

filters = {@mean}; % @median, @mean, 
widths = {12};
decs =   {25};
preB = 'RNAkv';

pre = 'DNAhistV7';
kv = 1;
hist = 0;


l = length(filters);
w = length(widths);
h = length(decs);


filePath = uigetdir('D:\Data\JP data may 2017\');
if filePath == 0
    return;
end
files = dir([filePath filesep 'phage*.mat']);
fileNames = {files.name};
%times = zeros(l, w, h);

ax = gobjects(l,w,h,2);

wb = waitbar(0,'1 1 1');

for i = 1:l;
    for j = 1:w;
        for k = 1:h;
            waitbar( ( (i-1) * w * h + (j-1) * h + (k-1) ) / (l*w*h), wb, [ num2str(i) ' ' num2str(j) ' ' num2str(k)]);
 %           startT = tic;
 
            if hist
                outstr = [pre 'F' func2str(filters{i}) 'W' num2str(widths{j}) 'D' num2str(decs{k})];
                if ~exist([filePath filesep outstr '.mat'],'file')
                    BatchFindSteps_Batch_Hist(filters{i}, widths{j}, decs{k}, outstr, filePath, fileNames);
                end
            end
            if kv
                outstrB = [preB 'F' func2str(filters{i}) 'W' num2str(widths{j}) 'D' num2str(decs{k})];
                if ~exist([filePath filesep outstrB '.mat'],'file')
                    BatchFindSteps_Batch(filters{i}, widths{j}, decs{k}, outstrB, filePath, fileNames);
                end
            end
   %         times(i, j , k) = toc(startT);
        end
    end
end
delete(wb);

% means = zeros(l, w, h);
% var1s = zeros(l, w, h);
% var2s = zeros(l, w, h);
% meaci = zeros(l, w, h);
% trez  = zeros(l,w,h);

wb = waitbar(0,'1 1 1');

for i = 1:l;
    for j = 1:w;
        for k = 1:h;
            waitbar( ( (i-1) * w * h + (j-1) * h + (k-1) ) / (l*w*h), wb, [ num2str(i) ' ' num2str(j) ' ' num2str(k)]);
            outstr = [pre 'F' func2str(filters{i}) 'W' num2str(widths{j}) 'D' num2str(decs{k})];
            if hist
                load([filePath filesep outstr '.mat']);
               % dat = collapseCell(outBursts);
    %             dat = dat(dat>0); %only take positive burst sizes, since mle doesnt like negative ones
    %             [bur, ci] = mle(dat, 'distribution', 'burr');
    %             means(i,j,k) = bur(1);
    %             var1s(i,j,k) = bur(2);
    %             var2s(i,j,k) = bur(3);
    %             meaci(i,j,k) = (ci(2,1) - ci(1,1))/2;
         %       [~, trez(i,j,k)] = ttest2(dat, DgoodDat);
                f = figure('Name',outstr);
                p=(normHist(collapseCell(outBursts),0.2));
                bar(p(:,1),p(:,2))
                ax(i,j,k,1) = gca;
                zoom on
                savefig(f, [filePath filesep 'FIG' outstr]);
            end
            
            if kv
                outstrB = [preB 'F' func2str(filters{i}) 'W' num2str(widths{j}) 'D' num2str(decs{k})];
                load([filePath filesep outstrB '.mat']);  
                f2 = figure('Name',outstrB);
                p=(normHist(collapseCell(outBursts),0.2));
                bar(p(:,1),p(:,2))
                ax(i,j,k,2) = gca;
                zoom on
               savefig(f2, [filePath filesep 'FIG' outstrB]);
            end
        end
    end
end
linkaxes(ax(:),'xy');
set(gca,'XLim',[2 18]);
delete(wb);