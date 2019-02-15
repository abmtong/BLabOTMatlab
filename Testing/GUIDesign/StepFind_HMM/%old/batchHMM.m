function [res, raw] = batchHMM(inTrCell)
%Applies stepFindHMM to a bunch of traces
%Timing: loF
% Takes about 5' per trace per iter. on my laptop (time = 5 * traces * iters / cores)
%I'd guess hiF takes less time (neighborhood will be smaller - abs(diff(tr)) will be smaller, bc smaller noise)

tic
if ~iscell(inTrCell)
    inTrCell = {inTrCell};
end

len = size(inTrCell,2);
lentr = cellfun(@length, inTrCell);

%inTrCell = {traces} or { traces ; results ; status }, if the latter extract the extra info
if size(inTrCell, 1) == 3
    outraw = inTrCell(2,:);
    outstatus = [inTrCell{3,:}];
    inTrCell = inTrCell(1,:);
else
    outraw = cell(1,len);
    outstatus = zeros(1,len);
end

%where results is the regular output, and status = 1 (done), 0 (untried), -1 (errored)

%do stepfinding in parallel
parfor i = find(outstatus == 0);
    try
        outraw{i} = findStepHMMV1(inTrCell{i});
        outstatus(i) = 1;
    catch
        outstatus(i) = -1;
    end
end
outraw = [outraw{:}]; %form struct array
aa = [outraw.finish]; %extract a's

%crop to only good traces
keepind = outstatus == 1;
inTrCell = inTrCell(keepind);
outraw = outraw(keepind);
len = length(inTrCell);
trlen = cellfun(@length, inTrCell);

%calculate a from all traces


%get length of a
lena = length(outraw(1).finish.a);
%average a will be weighted by number of points in the trace
newa = sum( bsxfun(@times, reshape( [aa.a], lena, len ), lentr-1), 2)';
newa = newa / sum(newa);

%do iter. 2 with global a's
outraw2 = cell(1,len);
parfor i=1:len
    model = outraw(i).finish;
    model.a = newa;
    outraw2{i} = findStepHMMV1(inTrCell{i}, model);
end
outraw2 = [outraw2{:}];
aa2 = [outraw2.finish];
newa2 = sum( bsxfun(@times, reshape( [aa2.a], lena, len ), lentr-1) , 2)';
newa2 = newa2/sum(newa2);
%assign output
res.a = newa;
res.a2 = newa2;
raw = {outraw outraw2};

%plot results
x = 0.1 * (1:lena-1);
figure, plot( x, newa(2:end))
hold on
plot( x, newa2(2:end))
toc