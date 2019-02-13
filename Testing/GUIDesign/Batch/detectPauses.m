function outPauses = detectPauses()
%Uses iteration from BatchFindSteps

minPauseTime = 2; %seconds
Fs = 50e3; %Sampling rate
filterOpts = {@mean, 500, 50};
dec = filterOpts{3};
yPad = 50; %amt to take up/down of pause
minPausePts = Fs/dec*minPauseTime*normpdf(0);
mPkPrm = minPausePts/3;

%Choose folder
path = uigetdir('C:\Data\JP data may 2017\','Choose the folder with your phi29 traces'); %Doing a hard-coded default path for now
if ~path
    return
end
%Grab suitable files in the folder
files = dir([path filesep 'phage*.mat']);
fileNames = {files.name};

outPauses = [];
startT = tic;
%Loop over each file
for i = 1:length(fileNames)
    %Load the file, extract the trace
    load([path filesep fileNames{i}]);
    cons = stepdata.contour;
    frcs = stepdata.force;
    %Display progress message
    fprintf('Starting file %d of %d, has %d segments\n', i, length(fileNames), length(cons))
    %Loop over each segment
    for j = 1:length(cons)
        %Extract the trace
        con = cons{j};
        conf = windowFilter(filterOpts{1}, con, filterOpts{2:3});
        [y, x] = resTimeHist(conf);
        findpeaks(double(y),double(x), 'MinPeakProminence',mPkPrm);
        drawnow
        [pks, lcs] = findpeaks(double(y),double(x), 'MinPeakProminence',mPkPrm);
        keepind = pks>minPausePts;
        pks = pks(keepind);
        lcs = lcs(keepind);
        for k = 1:length(pks)
            outPauses(end+1).name = sprintf('%sS%02dP%02d', fileNames{i}, j, k); %#ok<AGROW>
            stInd = find(con < lcs(k) + yPad, 1);
            if isempty(stInd)
                stInd = 1;
            end
            enInd = find(con > lcs(k) - yPad, 1, 'last');
            if isempty(enInd)
                enInd = length(con);
            end
            outPauses(end).con = con(stInd:enInd);
            outPauses(end).frc = frcs{j}(stInd:enInd);
        end
    end
end
save([path filesep 'Pauses.mat'],'outPauses');
fprintf('Found %d pauses from %d traces in %0.2fm. %s\n', length(outPauses), length(fileNames), toc(startT)/60);
