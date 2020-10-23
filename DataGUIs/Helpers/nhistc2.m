function [p, xe, n] = nhistc2(data, binsz, wts)
%Bins data into a histogram. Accepts n-dimesional and weighted data.
%Uses @discretize for speed. Input must be column vector, but 1D row vector specially handled.

%Input data: Array of size(n, k) where k is the number of dimensions
%Output: [weighted normalized histogram, bin edges, raw counts]

%Get size of input, to get number of points and dimensions
[ndat, ndim] = size(data);
%If data is a row array, or was mistakenly passed transposed, fix.
% You will never bin data wtih ndat < ndims... right?
if ndat < ndim
    data = data';
    [ndat, ndim] = size(data);
    warning('Input data should be a matrix of column arrays, transposing to fix.');
end

%Bin size: input bins for k dimensions, else use F-D
if nargin < 2
    binsz = zeros(1,ndim);
    for i = 1:ndim
        dt = data(:,i);
        binsz(i) = 2*iqr(dt)*numel(dt)^(-1/3); %F-D rule of thumb
    end
elseif numel(binsz) == 1
    binsz = binsz * ones(1,ndim);
end
assert(ndim == numel(binsz), 'Wrong number of bins for the dimensions of this data');

if nargin < 3
    wts = ones(size(data));
end

%Container for discretize output, bins
xe = cell(1,ndim);
dsc = cell(1,ndim);
ny = zeros(1,ndim);
for i = 1:ndim
    %Extract this column
    dt = data(:,i);
    bsz = binsz(i);
    %Generate bin edges
    edg = (floor(min(dt)/bsz):ceil(max(dt)/bsz))*bsz;
    %Make sure there's at least 2 edges
    if numel(edg) == 1
        edg = edg + [0 bsz];
    end
    xe{i} = edg;
    ny(i) = length(edg)-1;
    %Bin with discretize
    dsc{i} = discretize(dt, edg);
end


%And count. Two algorithms...
p = zeros([ny 1]); %Need to append a dim to the end in case ndim == 1 [zeros returns ndim x ndim matrix] (shouldn't use this code with ndim == 1 anyway, but eh)
n = zeros([ny 1]);

%If np is on the same order as n, just count by incrementing per data
np = prod(ny);
if np * 10 > ndat
    for i = 1:ndat
        dm = cellfun(@(x) x(i), dsc, 'Un', 0);
        li = sub2ind(ny, dm{:});
        n(li) =  n(li) + 1;
        p(li) = p(li) + wts(i);
    end
else
    %Otherwise, count per bin
    for i = 1:numel(p)
        %Need to use eval to get dynamic number of dimensions
        eval(sprintf('[%s] = ind2sub(ny,i);', sprintf('id(%d) ', 1:ndim)))
        idc = num2cell(id); %#ok<NASGU>
        evlstr = sprintf('dsc{%d} == id(%d) & ', [1:ndim; 1:ndim]);
        evlstr = evlstr(1:end-2); %Remove trailing &
        ki = eval(sprintf('%s', evlstr));
        n(i) = sum(ki);
        p(i) = sum(wts(ki));
    end
end
%Normalize
p = p / sum(wts) / prod(binsz);







