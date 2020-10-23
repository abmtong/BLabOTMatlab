function out = fitVitterbi(tr, inOpts)
%Fits a staircase with known state sequence mu. This one is 'unoptimized' for monotonic staircases, so can handle any sort of staircase

%Does vitterbi fitting for a given [mu, sig]. Transition matrix decided by trnsprb, with allowed directions dir.
% Default states is a grid defined by [ssz, off].

opts.ssz = 1; %Spacing of states
opts.off = 0; %Offset of states
opts.dir = 1; %1 for POSITIVE only, -1 for NEG only, 0 for BOTH
opts.trnsprb = 1e-3;
opts.sig = [];
opts.mu = [];
opts.a = [];

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if isempty(opts.mu)
    %Make state matrix
    indSta = floor(min(tr/opts.ssz));
    indEnd = ceil(max(tr/opts.ssz));
    mu = (indSta:indEnd) * opts.ssz + opts.off;
else
    mu = opts.mu;
end
ns = length(mu);
len=length(tr);

if isempty(opts.a)
    %Make transition matrix, as Sparse
    a = sparse(diag(ones(1,ns))) + ...
        any(opts.dir == [0 1])  * opts.trnsprb*sparse(diag(ones(1,ns-1), 1)) +  ...
        any(opts.dir == [0 -1]) * opts.trnsprb*sparse(diag(ones(1,ns-1),-1));
    a = bsxfun(@rdivide, a, sum(a,2));
else
    a = opts.a;
end

if isempty(opts.sig)
    sig = sqrt(estimateNoise(tr));
else
    sig = opts.sig;
end

%precalc & normalize normpdf
gauss = @(x) exp( -(mu-x).^2 /2 /sig/sig);
npdf = zeros(len,ns);
for i = 1:len
    npdf(i,:) = gauss(tr(i));
end
%normalize
npdf = bsxfun(@rdivide, npdf, sum(npdf,2));

%vitterbi, just apply w/ inModel
vitdpim = zeros(len-1, ns); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
vitdpim(1,:) = 1:ns;
vitscim = pi .* npdf(1,:);
for i = 1:len-1
    for j = 1:ns
        [vitscim(j), vitdpim(i,j)] = max( a(:,j) .* vitscim' );
    end
%     [vitsc, vitdp(i,:)] = max(bsxfun(@times, newa, vitsc'), [], 1);
    vitscim = vitscim .* npdf(i+1,:) / sum(vitscim); %renormalize
end

%assemble path via backtracking
st2 = zeros(1,len);
[~, st2(len)] = max(vitscim);
for i = len-1:-1:1
    st2(i) = vitdpim(i,st2(i+1));
end
out = mu(st2);

%{

%Noise
sig = sqrt(estimateNoise(tr));

%Precalc & normalize normpdf
gauss = @(x) exp( -(mu-x).^2 /2 /sig/sig);
npdf = zeros(len,ns);
for i = 1:len
    npdf(i,:) = gauss(tr(i));
end
%Normalize
npdf = bsxfun(@rdivide, npdf, sum(npdf,2));

%Starting state
pi = normpdf(mu,tr(1),sig);
pi = pi/sum(pi);

%Calc alpha
al = zeros(len,ns);
scal2 = zeros(1,len);
al(1,:) = pi .* npdf(1,:);
scal2(1) = sum(al(1,:));
al(1,:) = al(1,:)/scal2(1);
for t = 1:len-1
    for j = 1:ns
        temp = 0;
        for i = 1:ns
            temp = temp + al(t,i) * a(i,j);
        end
        al(t+1, j) = temp * npdf(t+1,j);
    end
    scal2(t+1) = sum(al(t+1,:));
    al(t+1,:) = al(t+1,:)/scal2(t+1);
end

%Calc beta
be = zeros(len,ns);
be(len,:) = ones(1,ns);
be(len,:) = be(len,:) / scal2(len);
for t = len-1:-1:1
    for i = 1:ns
        temp = 0;
        for j = 1:ns
            temp = temp + be(t+1, j) * a(i,j) * npdf(t+1,j);
        end
        be(t,i) = temp / scal2(t);
    end
end

%Calculate gamma
ga = al .* be;
ga = bsxfun(@rdivide, ga,  sum(ga,2));
[~, mlei] = max(ga, [], 2);

%Get MLE fit
out = mu(mlei);


%Vitterbi, jst apply w/ inModel
vitdpim = zeros(len-1, ns); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
vitdpim(1,:) = 1:ns;
vitscim = pi .* npdf(1,:);
for i = 1:len-1
    for j = 1:ns
        [vitscim(j), vitdpim(i,j)] = max( newa(:,j) .* vitscim' );
    end
%     [vitsc, vitdp(i,:)] = max(bsxfun(@times, newa, vitsc'), [], 1);
    vitscim = vitscim .* newnpdf(i+1,:) / sum(vitscim); %renormalize
end

%assemble path via backtracking
st2 = zeros(1,len);
[~, st2(len)] = max(vitscim);
for i = len-1:-1:1
    st2(i) = vitdpim(i,st2(i+1));
end

%}