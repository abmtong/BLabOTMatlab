function outP = batchTesterHist_Iterate(inP)

%For naming purposes
iter = 2;
iter2 = 10;
%Iterate: Just choose one f/w/d
filters = {@mean};
widths = {0};
decs =   {50};
pre = ['Iter' num2str(iter) 'DNAhistV7'];

outP = cell(1,iter2-iter+1);


filePath = uigetdir('D:\Data\JP data may 2017\');
if filePath == 0
    return;
end

files = dir([filePath filesep 'phage*.mat']);
fileNames = {files.name};

i = 1;
j = 1;
k = 1;

ax = gobjects(1,iter2-iter+1);

for l = iter:iter2
    pre = ['Iter' num2str(l) 'DNAhistV7'];


outstr = [pre 'F' func2str(filters{i}) 'W' num2str(widths{j}) 'D' num2str(decs{k})];
if ~exist([filePath filesep outstr '.mat'],'file')
    BatchFindSteps_Batch_Hist(filters{i}, widths{j}, decs{k}, outstr, filePath, fileNames, inP(inP(:,2)>0,:));
end

outstr = [pre 'F' func2str(filters{i}) 'W' num2str(widths{j}) 'D' num2str(decs{k})];
load([filePath filesep outstr '.mat']);
f = figure('Name',outstr);
nextP=(normHist(collapseCell(outBursts),0.2));
bar(nextP(:,1),nextP(:,3))
ax(l - iter + 1) = gca;
zoom on
savefig(f, [filePath filesep 'FIG' outstr]);
%set(gca, 'XLim', [2 18])
inP = nextP;
outP{l - iter + 1} = nextP;
end
linkaxes(ax,'x');