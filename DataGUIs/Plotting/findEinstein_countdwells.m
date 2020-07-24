function out = findEinstein_countdwells(st, iny)
%For steps that are asymmetric, align to final step [make it different] and distribute the dwells
% Output is in order (out{i} = dwells before the ith step)

if nargin < 2
    iny = cumsum(-2.5*ones(1,4) + [0 0 0 1]);
end

ns = length(iny);
dws = cell(1,ns);
len = length(st);
dy = iny(end);

for i = 1:len
    tr = st(i).ft;
    [in, me] = tra2ind(tr);
    sz = diff(me);
    dw = diff(in);
    
    inds = find(sz == dy);
    %Make sure: we fond a step and that they are all 4 within each other
    if isempty(inds)
        continue
    elseif any(mod(inds,ns) ~= mod(inds(1),ns))
        warning('Trace %d skipped because small step %s is not pattern %d', i, sprintf('%d,',inds), ns)
        continue
    else
        %Find the step offset
        off = mod(inds(1),ns);
        %Choose dwell before each step (same index of sz and dw)
        for j = 1:length(dw) % 2:length(sz)
            tmp = moda(j-off, ns);
            dws{tmp} = [dws{tmp} dw(j)];
        end
    end
end
out = dws;

%Plot distributions
figure('Name', sprintf('FE_CountDwells %s', inputname(1)))
hold on
x = cellfun(@sort, dws, 'Un', 0);
y = cellfun(@(x) (1:length(x))/length(x), dws, 'Un', 0);
cellfun(@plot,x,y)

end

function out = moda(x, n)
%x mod n that outputs 1 to n instead of 0 to n-1
out = mod(x,n);
if out == 0
    out = n;
end
end