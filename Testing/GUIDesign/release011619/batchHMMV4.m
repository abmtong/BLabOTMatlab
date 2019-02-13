function out = batchHMMV4(nitermax, stopatlogp)
%Applies stepFindHMM to a bunch of traces

if nargin < 1
    nitermax = 5;
end

if nargin < 2
    stopatlogp = 1;
end

lowprocesspriority = 0;

stT = tic;
[files, path] = uigetfile('.\pHMM*.mat','MultiSelect','on'); %'C:\Data\pHMM*.mat',
%Check to make sure files were selected
if ~path
    return
end
if ~iscell(files)
    files = {files};
end

%randomize order, for... reasons (might hit a patch of long time files ?)
% files = files(randperm(length(files)));

len = length(files);

if lowprocesspriority
    cmd_str = 'wmic process where name="MATLAB.exe" CALL setpriority 64';
    [~,~] = system(cmd_str);
end



%outflag = -1 (error), 0 (unconverged), 1(converged)
outflags = zeros(1,len);
parfor i = 1:len
    %load file and current iter.
    file = files{i};
    fp = [path filesep file];
    outflags(i) = fsHMMsave(fp, nitermax, stopatlogp);
end

fprintf('batchHMM finished in %0.1fm, %d files processed, %d files errored, %d files converged with itermax=%d\n',...
        toc(stT)/60, sum(outflags ~= -1), sum(outflags == -1), sum(outflags >= 1), nitermax)
out.flags = outflags;
out.files = files;
%{

%calculate a from all traces

%get length of a
lena = length(outraw(1).finish.a);
%average a will be weighted by number of points in the trace
newa = sum( bsxfun(@times, reshape( [aa.a], lena, len ), lentr-1), 2)';
newa = newa / sum(newa);

%plot, update
figure('Name', 'BatchHMM');
x = 0.1 * (1:lena-1);
plot(x, newa(2:end)), drawnow
ax = gca;
hold on

as = cell(1, nitermax);
as{1} = newa;
raws = cell(1, nitermax);
raws{1} = outraw;
for it = 2:nitermax
    %do next iters with global a's, need last iter's outraw and newa
    outraw2 = cell(1,len);
    parfor i=1:len
        model = outraw(i).finish;
        model.a = newa;
        outraw2{i} = findStepHMMV1(inTrCell{i}, model);
    end
    %process results
    outraw2 = [outraw2{:}];
    aa2 = [outraw2.finish];
    newa2 = sum( bsxfun(@times, reshape( [aa2.a], lena, len ), lentr-1) , 2)';
    newa2 = newa2/sum(newa2);
    
    %plot results
    plot(ax, x, newa2(2:end)), drawnow
    
    %save, rename var.s for next iter.
    as{it} = newa2;
    newa = newa2;
    raws{it} = outraw2;
    outraw = outraw2;
end
out1 = as;
out2 = raws;
%}
end