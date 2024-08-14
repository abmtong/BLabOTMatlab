function [outtr, isbt] = removeTrBts(tr, stepdir)
%Takes in an increasing staircase (eg an output from fitVitterbi) and removes backtracks
%Output is the trace and isbt, a bool if the step is a backtrack or not (i.e., if ind=tra2ind(outtr), ind( isbt(i) ) is the start of a backtrack)

%dir = 1 for positive, -1 for negative
if nargin < 2
    stepdir = 1;
end

if isempty(tr)
    outtr = [];
    isbt = [];
    return
end

%if stepdir = -1, just apply to negative data
if stepdir < 0
    tr = -tr;
end

%Keep a copy of the original trace (tr0)
tr0 = tr;

%V2: simpler
len = length(tr);
for i = 2:len
    if tr(i) < tr(i-1)
        tr(i) = tr(i-1);
    end
end

%Find backtracks
[~, me] = tra2ind(tr);
%Get steps with backtracks = where tr > tr0
bts = unique( tr( tr > tr0 ) );
%Convert to index of me
isbt = arrayfun(@(x) find( me == x, 1, 'first' ), bts);

%Assign outputs
outtr = tr;
if stepdir < 0
    outtr = -outtr;
end

%V1 version, probably slow?
%{
while true
    %Convert to ind/mea
    [ind, mea] = tra2ind(tr);
    
    %Find reverse steps
    neg = diff(mea) * stepdir < 0;
    
    %If no negative steps, we're done
    if ~any(neg)
        break
    end
    
    %Remove these steps: if neg(i) <0, remove ind(i+1) and mea (i+1)
    ind = ind([true ~neg true]);
    mea = mea([true ~neg]);
    
    %Convert to tr, to cover if there are two adjacent steps with the same value
    tr = ind2tra(ind, mea);
end

%Compare starting ind/mea and ending ind/mea to find bts
in0  = tra2ind(tr0);
in = tra2ind(tr);

%A bt occurred if there is a value between in(i) and in(i+1) in in0
%To handle edge bts, add one to in(end)
in(end) = in(end) + 1;
in0(end) = in0(end)+1;
isbt = arrayfun(@(x,y) any(in0 > x & in0 < y), in(1:end-1), in(2:end));
isbt = find(isbt);

outtr = tr;
%}


%{
% %Find duplicated steps
% [~, ia] = unique(mea, 'stable');
% %Convert ia to logical
% dup = false(1,length(mea));
% for i = 1:length(ia)
%     dup(ia) = true;
% end
% 
% %Find steps backward [kinda redundant to above, but does catch steps less than the inital step]
% bts = diff(mea)<0;
% 
% %To remove backtracks, remove duplicated steps and steps less than the inital step
% ki = [~bts true] | dup;
% ind = ind([ki true]);
% mea = mea(ki);
% 
% outtr = ind2tra(ind, mea);
% 
% isbt = find(~ki);
%}

%{
%Ugh, harder than expected to do a rigorous 'case-wise' way to do this (above). Just loop
i = 1;
outind = 1;
outmea = mea(1);
isbt = [];
st = diff(mea);
while true
    %See if the next step is negative
    if st(i) < 0
        %bt has started, look for nearest return to that step size with a positive step after it
        next = find(mea(i) == mea & [0 st] > 0);
        next = next(find(next > i, 1, 'first'));
        if isempty(next)
            %No applicable end, so end is bt
            break
        end
        %Mark this step as bt
        isbt = [isbt mea(i)]; %#ok<AGROW>
        i = next + 1;
    else
        %Otherwise, this step is okay, append
        i = i + 1;
    end
    %Check if we're done
    if i >= length(ind)
        break
    end
    outind = [outind ind(i)]; %#ok<AGROW>
    outmea = [outmea mea(i)]; %#ok<AGROW>
end

%Cap ind
outind = [outind ind(end)];

%Form output trace
outtr = ind2tra(outind, outmea);
%}