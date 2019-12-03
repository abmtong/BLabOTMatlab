function out = kdfdwfindHMM(incon, inmodel, verbose)
%Fits a HMM to trace incon according to model guess inmodel
%Acceptable guesses: n states (integer), states (array), full struct of everything
%Defaults: mu: evenly spaced; a: translocation only, no skipped steps [assumes mu is sorted, makes a @tril]
% sig: estimated with @estimateNoise; pi: end

if nargin < 3
    verbose = 1;
end

%Check if inmodel is struct or not
if ~isstruct(inmodel)
    if isscalar(inmodel)
        %inmodel = ns, have to guess mu's
        mu = linspace( min(incon), max(incon), inmodel+2);
        mu = mu(2:end-1);
    else
        %inmodel is just insts
        mu = inmodel;
    end
    inmodel = [];
else
    mu = inmodel.mu;
end

%Get basic info of length
ns = length(mu);
len = length(incon);
dbar = len/ns;

%Translocation matrix == a
if isfield(inmodel, 'a')
    a=inmodel.a;
else
    a = diag(ones(1,ns)) + diag(ones(1,ns-1),-1)*dbar;
%     a = ones(ns) + diag(ones(1,ns)) * dbar;
    a = bsxfun(@rdivide, a, sum(a,2));
%     a=tril(a);
end

%Noise == sig
if isfield(inmodel, 'sig')
    sig = inmodel.sig;
else
    sig = sqrt(estimateNoise(incon, 2));
end

%Now that we have mu and sig, precalculate gaussian probabilities == npdf
npdf = zeros(len,ns);
for i = 1:len
    npdf(i,:) = normpdf(mu, incon(i), sig);
end
%Normalize
npdf = bsxfun(@rdivide, npdf, sum(npdf,2));

if isfield(inmodel, 'pi')
    pi = inmodel.pi;
else
    %pi guess is: start at end
    pi = zeros(size(mu));
    pi(end) = 1;
end

%Calculate alpha ('forewards variable')
al = zeros(len,ns);
scal = zeros(1,len);
al(1,:) = pi .* npdf(1,:);
scal(1) = sum(al(1,:));
al(1,:) = al(1,:)/scal(1);
for i = 2:len
    al(i,:) = al(i-1,:) * a .* npdf(i,:);
    scal(i) = sum(al(i,:));
    al(i,:) = al(i,:)/scal(i);
end

%{
%non-matrix way, probably slower for large matricies
al2 = zeros(len,ns);
scal2 = zeros(1,len);
al2(1,:) = pi .* npdf(1,:);
scal2(1) = sum(al2(1,:));
al2(1,:) = al2(1,:)/scal2(1);
for t = 1:len-1
    for j = 1:ns
        temp = 0;
        for i = 1:ns
        	temp = temp + al2(t,i) * a(i,j);
        end
        al2(t+1, j) = temp * npdf(t+1,j);
    end
    scal2(t+1) = sum(al2(t+1,:));
    al2(t+1,:) = al2(t+1,:)/scal2(t+1);
end
%}

%calculate beta
be = zeros(len,ns);
be(len,:) = ones(1,ns);
be(len,:) = be(len,:) / scal(len);
for i = len-1:-1:1
    be(i,:) = be(i+1, :) .* npdf(i+1,:) * a.' / scal(i);
end

%{
%non-matrix way
be2 = zeros(len,ns);
be2(len,:) = ones(1,ns);
be2(len,:) = be2(len,:) / scal2(len);
for t = len-1:-1:1
    for i = 1:ns
        temp = 0;
        for j = 1:ns
            temp = temp + be2(t+1, j) * a(i,j) * npdf(t+1,j);
        end
        be2(t,i) = temp / scal2(t);
    end
end
%}

%calculate gamma
ga = al .* be;
ga = bsxfun(@rdivide, ga,  sum(ga,2));

%mle fit
[~, ml] = max(ga, [], 2);

%calculate xi
xi = zeros(len-1, ns, ns);
for i = 1:len-1
    xi(i,:,:) = a .* bsxfun(@times, al(i,:).',be(i+1,:) .* npdf(i+1,:));
end
%normalize
xi = bsxfun(@rdivide, xi, sum(sum(xi,3),2));

%{
%non-matrix way, probably slower
xi2 = zeros(len-1,ns,ns);
for t = 1:len-1
    for i = 1:ns
        for j = 1:ns
        	xi2(t,i,j) = al(t,i) * a(i,j) * npdf(t+1,j) * be(t+1,j);
        end
    end
end
xi2 = bsxfun(@rdivide, xi2, sum(sum(xi,3),2));
%}

%calculate new a, pi
newpi = ga(1,:);
newa = squeeze(sum(xi,1));
% newa = bsxfun(@rdivide, newa,  sum(ga(1:end-1,:), 1) );
newa = bsxfun(@rdivide, newa, sum(newa, 2));
%%someting slightly wrong with either gamma or xi, norm. not quite working

%calculate new mu
newmu = zeros(1,ns);
for i = 1:ns
    newmu(i) = sum(ga(:,i).*incon') / sum(ga(:,i));
end

%calc new sig
newsig = zeros(1,len);
for i = 1:len
    newsig(i) = sum( ga(i,:) .* (incon(i) - mu).^2 );
end
newsig = sqrt(sum(newsig)/(length(newsig)-1));

%vitterbi
vitdp = zeros(len-1, ns); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
vitdp(1,:) = 1:ns;
vitsc = pi .* npdf(1,:);
for i = 1:len-1
    [vitsc, vitdp(i,:)] = max(bsxfun(@times, a, vitsc'), [], 1);
    vitsc = vitsc .* npdf(i+1,:) / sum(vitsc); %renormalize
end
%assemble path via backtracking
st = zeros(1,len);
[~, st(len)] = max(vitsc);
for i = len-1:-1:1
    st(i) = vitdp(i,st(i+1));
end

%Collect start and end
finish.a = newa;
finish.mu = newmu;
finish.sig = newsig;
finish.pi = newpi;
finish.st = st;
finish.fit = mu(st);
finish.fitmle = mu(ml);
finish.logp = sum(log(scal)) + log(sum(al(end,:)));
start.a = a;
start.mu = mu;
start.sig = sig;
start.pi = pi;
out.start = start;
out.finish = finish;

if verbose
    figure('Name', 'kdfdwfindHMM vit=g mle=r'), plot(incon),hold on, plot(mu(st), 'g'), plot(mu(ml), 'r')
end