function batchTesterDWT()

filters = {@mean}; % @median, @mean, 
widths = {0};
decs =   {1};
pre = 'DNAdwtI8T3';
iterthr = [8 3];


hist = 1;
l = length(filters);
w = length(widths);
h = length(decs);


filePath = uigetdir('D:\Data\JP data may 2017\');
if filePath == 0
    return;
end
files = dir([filePath filesep 'phage*.mat']);
fileNames = {files.name};

ax = gobjects(l,w,h);

wb = waitbar(0,'1 1 1');

for i = 1:l;
    for j = 1:w;
        for k = 1:h;
            waitbar( ( (i-1) * w * h + (j-1) * h + (k-1) ) / (l*w*h), wb, [ num2str(i) ' ' num2str(j) ' ' num2str(k)]);
 %           startT = tic;
            if hist
                outstr = [pre 'F' func2str(filters{i}) 'W' num2str(widths{j}) 'D' num2str(decs{k})];
                if ~exist([filePath filesep outstr '.mat'],'file')
                    BatchFindSteps_Batch_DWT(filters{i}, widths{j}, decs{k}, outstr, filePath, fileNames, iterthr);
                end
            end
        end
    end
end
delete(wb);

for i = 1:l;
    for j = 1:w;
        for k = 1:h;
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
                ax(i,j,k) = gca;
                zoom on
                savefig(f, [filePath filesep 'FIG' outstr]);
            end
        end
    end
end
linkaxes(ax(:),'xy');
%set(gca,'XLim',[2 18]);