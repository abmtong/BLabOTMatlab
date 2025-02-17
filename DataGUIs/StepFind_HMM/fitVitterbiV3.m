function out = fitVitterbiV3(tr, inOpts)

%Does vitterbi fitting for a given [mu, sig]. Transition matrix decided by trnsprb, with allowed directions dir.
% Default states is a grid defined by [ssz, off]
%V2: removed full-width transition matrix
%V3: windowed operation for smaller matricies

%Should rewrite using logprb, to avoid underflow

opts.ssz = 1; %Spacing of states
opts.off = 0; %Offset of states
opts.dir = 1; %1 for POSITIVE only, -1 for NEG only, 0 for BOTH
opts.trnsprb = [1e-3 1e-3]; %[Positive, Negative] transition probability
opts.sig = [];
opts.mu = []; %If passing mu, keep in mind opts.dir refers to the element-order

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Make sure trnsprb is 2-element
if length(opts.trnsprb) == 1
    opts.trnsprb = opts.trnsprb * [1 1];
end

%Make state matrix, or use input mu
yimin = floor(min(tr/opts.ssz));
yimax = ceil(max(tr/opts.ssz));
if isempty(opts.mu)
    mu = (yimin:yimax) * opts.ssz + opts.off;
else
    mu = opts.mu;
    opts.ssz = max(diff(mu));
end
ns = length(mu);
len=length(tr);

if isempty(opts.sig)
    sig = sqrt(estimateNoise(tr));
else
    sig = opts.sig;
end

%Make transition matrix, as Sparse
a = [any(opts.dir == [0 1])  * opts.trnsprb(1) 1 any(opts.dir == [0 -1]) * opts.trnsprb(2)];
a = bsxfun(@rdivide, a, sum(a,2));

%Define upper, lower bdys for viterbi [slice of states we need to consider at each pt]
maxdif = max(abs(diff(tr)));
maxdif = max([maxdif*2, length(a)*opts.ssz*2, sig*5]);
ub = min( ceil((tr+maxdif-yimin*opts.ssz+1)/opts.ssz), ns);
lb = max(floor((tr-maxdif-yimin*opts.ssz+1)/opts.ssz), 1);
lb3 = min( [lb; lb(2:end) inf ; inf lb(1:end-1)] , [] , 1);
ub3 = max( [ub; 0 ub(1:end-1); ub(2:end) 0] , [] , 1);
wid = ub3-lb3+1;
widmx = max(wid);

%Check arraysize, break up if too large
maxarrsz = 1e9; %1GB arrays max
if len * widmx * 8 > maxarrsz %Check if array size will be too large
    %If so, cut up traces into pieces with maxarrsz/5 size
    npcs = ceil( len * widmx * 8 * 5 / maxarrsz );
%     warning('Trace too long, splitting %d point trace into %d parts', len, npcs)
    %Cut up
    trcutind = round(linspace(1,len+1, npcs+1));
    trs = arrayfun(@(x,y) tr(x:y), trcutind(1:end-1), trcutind(2:end)-1, 'Un', 0);
    %Apply to each segment
    fits = cellfun(@(x)fitVitterbiV3(x, opts), trs, 'Un', 0);
    %Rejoin
    out = [fits{:}];
%     warning('Trace direction may be incorrect at edges, beware')
    return
end


% %precalc & normalize normpdf - dont do this anymore bc memory
% gauss = @(x) exp( -(mu-x).^2 /2 /sig/sig);
% npdf = zeros(len,ns);
% for i = 1:len
%     npdf(i,:) = gauss(tr(i));
% end
% %normalize
% npdf = bsxfun(@rdivide, npdf, sum(npdf,2));

npdf = @(ind) normpdf(mu, tr(ind), sig); %Shortcut

%vitterbi, just apply w/ inModel
vitdp = zeros(len-1, widmx); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
% vitdpim(1,:) = lb(1):ub(1);
vitsc = npdf(1).^2;
for i = 1:len-1
    %Create matrix a
    aa = diag(ones(1,wid(i))*a(2)) + diag(ones(1,wid(i)-1),-1)*a(3) + diag(ones(1,wid(i)-1),1)*a(1);
    aa = bsxfun(@rdivide, aa, sum(aa,2));
    %Calculate proposed paths, take best
    [tsc, tvitdp] = max( bsxfun( @times, aa, vitsc(lb3(i):ub3(i))'), [], 1);
    %Sanity: tsc > 0
    if tsc == 0
        warning('Probability zeroed out, check (probably a backtrack in a non-backtracking staircase)') %Maybe deal in logprob instead...
        out = [];
        return
    end
    %Apply score, apply npdf, renormalize
    vitsc = [ zeros(1, lb3(i)-1) tsc zeros(1, ns-ub3(i)) ] .* npdf(i+1) / sum(tsc);
    %Save best paths
    vitdp(i, 1:wid(i)) = tvitdp + lb3(i) -1;
%     if ~mod(i, 1e3)
%     plot(tsc), drawnow
%     end
end

%assemble path via backtracking
st = zeros(1,len);
[~, st(len)] = max(vitsc);
for i = len-1:-1:1
    st(i) = vitdp(i,st(i+1)-lb3(i)+1);
end
out = mu(st);