function [out1, out2] = batchHMMV2(inTrCell)
%Applies stepFindHMM to a bunch of traces
%Timing: loF
% Takes about 5' per trace per iter. on my laptop (time = 5 * traces * iters / cores)
%I'd guess hiF takes less time (neighborhood will be smaller - abs(diff(tr)) will be smaller, bc smaller noise)

tic
if ~iscell(inTrCell)
    inTrCell = {inTrCell};
end

len = size(inTrCell,2);

%inTrCell = {traces} or { traces ; results ; status }, if the latter extract the extra info
%results is the regular output, and status = 1 (done), 0 (untried), -1 (errored)
if size(inTrCell, 1) == 3
    outraw = inTrCell(2,:);
    outstatus = [inTrCell{3,:}];
    inTrCell = inTrCell(1,:);
else
    outraw = cell(1,len);
    outstatus = zeros(1,len);
end



    function out = fsHMM(inTrace)
        try
            out = findStepHMMV1(inTrace);
        catch
            out = [];
        end
    end

%do stepfinding in parallel
for i = fliplr(find(outstatus == 0)) %only do ones that have no status, call last one first to allocate parjob
    parjob(i) = parfeval(@fsHMM, 1, inTrCell{i}); %#ok<AGROW>
end
parclean = onCleanup(@() cancel(parjob));

numcomplete = 0;
timeout = 5;
%collect results
wb = waitbar(0, 'HMM progress', 'CreateCancelBtn', @(src, event) setappdata(gcbf(), 'Cancelled', true));
setappdata(wb, 'Cancelled', false);
stT = tic;
halted = 0;
%delete waitbar on exit
wbclean = onCleanup(@()delete(wb));

while numcomplete < len
    [ind, res] = fetchNext(parjob, timeout);
    if ~isempty(ind) %job completed
        %increment, update waitbar
        numcomplete = numcomplete + 1;
        %check if completed or errored (returns [] if errored)
        if ~isempty(res)
            outraw{ind} = res;
            outstatus(ind) = 1;
        else %isempty, trace errored
            outstatus(ind) = -1;
        end
    end
    %check for exit via cancel button
    if getappdata(wb, 'Cancelled')
        fprintf('HMM Cancelled, returning tracedata\n')
        out1 = [ inTrCell ; outraw ; num2cell(outstatus) ];
        out2 = [];
        halted = 1;
        break
    end
    
    %update waitbar
    %estimate time remaining
    t = toc(stT);
    str = 'TBD';
    if numcomplete > 0
        eta = (len / numcomplete -1)* t; %eta, seconds
        if eta > 3600 %time in hours
            str = sprintf('%0.1fh', eta/3600);
        else %time in minutes
            str = sprintf('%0.1fm', eta/60);
        end
    end
    waitbar(numcomplete/len, wb, sprintf('HMM progress, ETA:%s', str) );
end
cancel(parjob);
delete(wb);

%if execution halted early, just stop
if halted
    return
end


%crop to only good traces
keepind = outstatus == 1;
inTrCell = inTrCell(keepind);
outraw = outraw(keepind);
len = length(inTrCell);
lentr = cellfun(@length, inTrCell);

outraw = [outraw{:}]; %form struct array
aa = [outraw.finish]; %extract a's

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
out1.a = newa;
out1.a2 = newa2;
out2 = {outraw outraw2};


%plot results
x = 0.1 * (1:lena-1);
figure, plot( x, newa(2:end))
hold on
plot( x, newa2(2:end))
toc
end