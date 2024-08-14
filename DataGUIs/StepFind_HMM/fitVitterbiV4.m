function out = fitVitterbiV4(tr, inOpts)

%Does vitterbi fitting for a given [mu, sig]. Transition matrix decided by trnsprb, with allowed directions dir.
% Default states is a grid defined by [ssz, off]
%V2: removed full-width transition matrix
%V3: windowed operation for smaller matricies
%V4: Switch to logprb. Only works now as a simple staircase !

%Should rewrite using logprb, to avoid underflow

opts.ssz = 1; %Spacing of states
opts.off = 0; %Offset of states
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

%Make transition options [step fwd, stay, step back]
a = log([opts.trnsprb(1) 1 opts.trnsprb(2)]);

%Check arraysize, break up if too large
maxarrsz = 1e9; %1GB arrays max
if len * ns * 8 > maxarrsz %Check if array size will be too large
    %If so, cut up traces into pieces with maxarrsz/5 size
    npcs = ceil( len * ns * 8 * 5 / maxarrsz );
%     warning('Trace too long, splitting %d point trace into %d parts', len, npcs)
    %Cut up
    trcutind = round(linspace(1,len+1, npcs+1));
    trs = arrayfun(@(x,y) tr(x:y), trcutind(1:end-1), trcutind(2:end)-1, 'Un', 0);
    %Apply to each segment
    fits = cellfun(@(x)fitVitterbiV4(x, opts), trs, 'Un', 0);
    %Rejoin
    out = [fits{:}];
%     warning('Trace direction may be incorrect at edges, beware')
    return
end

%Log normpdf of a given pt.
npdf = @(ind) log(1/sig/sqrt(2*pi)) - 0.5*( (tr(ind) - mu) / sig ).^2;
%Store step results
vitdp = zeros(len-1, ns); %vitdp(t,p)=k means the best way to get to (t+1,p) is from (t,q-k) 
%Score of each pt
vitsc = npdf(1)'*2;
for i = 1:len-1
%    %RUNS BUT IS WRONG
%     %Calculate proposed paths, take best
%     %We can make this by a shifted vitsc...
%     tmp = vitsc(lb3(i):ub3(i))';
%     tmp2 = [ [tmp(2:end); -inf]+a(3) tmp [-inf; tmp(1:end-1)]+a(1)  ];
%     [tsc, tvitdp] = max( tmp2, [], 2);
%     %Apply score, apply npdf
%     vitsc = [ -inf(1, lb3(i)-1) tsc' -inf(1, ns-ub3(i)) ] + npdf(i+1);
%     %Save best paths, as a relative index: 0 if stay, -1 if step back, +1 if step fwd
%     vitdp(i, 1:wid(i)) = tvitdp + -2;
    
    %Calculate score of each point
    %     Score of step back     Do nothing   Score of step forwards
    tmp2 = [ [vitsc(2:end); -inf]+a(3) vitsc [-inf; vitsc(1:end-1)]+a(1)  ];
    [tsc, tvitdp] = max( tmp2, [], 2);
    %Apply score, apply npdf
    vitsc = tsc + npdf(i+1)'; %Shouldn't need to recenter vitsc in log prob space
    %Save best paths, as a relative index: 0 if stay, -1 if step back, +1 if step fwd
    vitdp(i, :) = tvitdp + -2;
end

%Assemble path via backtracking
st = zeros(1,len);
%Start in final best state...
[~, st(len)] = max(vitsc);
for i = len-1:-1:1
    %And apply the step
    st(i) = st(i+1) - vitdp(i,st(i+1));
end
out = mu(st);



