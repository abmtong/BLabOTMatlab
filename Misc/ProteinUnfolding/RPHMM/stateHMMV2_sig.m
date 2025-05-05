function out = stateHMMV2_sig(tr, inModel)
%Fits a HMM to a n-state hopping problem; generates test data if nothing supplied

if nargin<2 %generate model guess
    inModel = [];
end

if nargin<1
    %simulate hopping, n-state
    ns = 3;
    len=1e4;
    sig = .5;
    tprb = .99;
    st = rand(1,len);
    st = double(st>tprb);
    st = mod(1+cumsum(st), ns);
    tr = st + randn(1,len)*sig;
else
    tr = double(tr(:)');
    len = length(tr);
end

if ~isfield(inModel, 'verbose')
    verbose = 1;
    inModel.verbose = 1;
else
    verbose = inModel.verbose;
end


if ~isfield(inModel, 'ns')
    if isfield(inModel, 'mu')
        ns = length(inModel.mu);
    elseif isfield(inModel, 'a')
        ns = length(inModel.a);
    else
        ns = 3;
    end
    inModel.ns = ns;
else
    ns = inModel.ns;
end


%generate missing model stuffs
if ~isfield(inModel, 'a')
    a = ones(ns)/1e4 + diag(ones(1,ns));
    a = bsxfun(@rdivide, a, sum(a,2));
    inModel.a = a;
else
    a = inModel.a;
    
end
%Normalize a
a = bsxfun(@rdivide, a, sum(a,2));

if ~isfield(inModel, 'mu')
%     mu = ((1:ns)+1)/(ns+2) * (max(tr) - min(tr)) + min(tr); %evenly divided by range
    mu = prctile(tr, ((1:ns)+1)/(ns+2) * 100);%evenly divided by prb
    inModel.mu = mu;
else
    mu = inModel.mu;
end

if ~isfield(inModel, 'sig')
    sig = sqrt(estimateNoise(tr)) * ones(1,ns);
    inModel.sig = sig;
else
    sig = inModel.sig;
    if length(sig) == 1
        sig = sig * ones(1,ns);
    end
end

if ~isfield(inModel, 'pi')
    pi = normpdf(mu,tr(1),sig);
    pi = pi/sum(pi);
    inModel.pi = pi;
else
    pi = inModel.pi;
end

len = length(tr);

%precalc & normalize normpdf
gauss = @(x) exp( -(mu-x).^2 /2 ./sig./sig);
npdf = zeros(len,ns);
for i = 1:len
    npdf(i,:) = gauss(tr(i));
end
%normalize
npdf = bsxfun(@rdivide, npdf, sum(npdf,2));


% sta1 = tic;
% %calculate alpha
% al = zeros(len,ns);
% scal = zeros(1,len);
% al(1,:) = pi .* npdf(1,:);
% scal(1) = sum(al(1,:));
% al(1,:) = al(1,:)/scal(1);
% for i = 2:len
%     al(i,:) = al(i-1,:) * a .* npdf(i,:);
%     scal(i) = sum(al(i,:));
%     al(i,:) = al(i,:)/scal(i);
% end
% ta1 = toc(sta1);

% sta2 = tic;
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
% ta2 = toc(sta2);

% stb1 = tic;
% %calculate beta
% be = zeros(len,ns);
% be(len,:) = ones(1,ns);
% be(len,:) = be(len,:) / scal(len);
% for i = len-1:-1:1
%     be(i,:) = be(i+1, :) .* npdf(i+1,:) * a.' / scal(i);
% end
% tb1 = toc(stb1);
% 
% stb2 = tic;
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
% tb2 = toc(stb2);
al = al2;
scal = scal2;
be = be2;
% fprintf('al: matrix %0.5fs, for %0.5fs; be: matrix %0.5fs, for %0.5fs\n', ta1, ta2, tb1, tb2)

%calculate gamma
ga = al .* be;
ga = bsxfun(@rdivide, ga,  sum(ga,2));
[~, fitmle] = max(ga, [], 2);
% ga = zeros(len,ns);
% for i = 1:len
%     ga(i,:) = al(i,:) .* be(i,:);
%     ga(i,:) = ga(i,:) / sum(ga(i,:));
% end


%naive method
%{
%assign, use naive maximum likelihood for now
[~, newst] = max(ga,[],2);

% check, seems good
% figure, plot(tr, 'Color', [.7 .7 .7]), hold on, plot(mlss), plot(reals(realst))

%reestimate params
for i = 1:ns
    newmu(i) = mean(tr(newst == i));
end
newsig = std(tr - newmu(newst));
newa = zeros(ns);
for i = 1:len-1
    newa(newst(i), newst(i+1)) = newa(newst(i), newst(i+1)) + 1;
end
%normalize
newa = bsxfun(@rdivide, newa, sum(newa,2));
%}


% %more rigorous way
% xi = zeros(len-1, ns, ns);
% for i = 1:len-1
%     xi(i,:,:) = a .* bsxfun(@times, al(i,:).',be(i+1,:) .* npdf(i+1,:));
% end
% %normalize
% %could also do in loop (temp = ..., tempsum = sum(sum(temp)), xi(i,:,:) = temp/tempsum, but matrix ops should be faster?
% xi = bsxfun(@rdivide, xi, sum(sum(xi,3),2));


%non-matrix way, probably slower unless JIT
xi2 = zeros(len-1,ns,ns);
for t = 1:len-1
    for i = 1:ns
        for j = 1:ns
            xi2(t,i,j) = al(t,i) * a(i,j) * npdf(t+1,j) * be(t+1,j);
        end
    end
end
xi2 = bsxfun(@rdivide, xi2, sum(sum(xi2,3),2));

%it should be the case that ga = sum(xi, 3); : true
% ga2 = sum(xi,3);
% ga3 = sum(xi2,3);

xi = xi2;
%calculate new var.s
newpi = ga(1,:);
newa = squeeze(sum(xi,1));
newa = bsxfun(@rdivide, newa, sum(newa, 2));
newmu = sum(bsxfun(@times, ga, tr'), 1) ./ sum(ga, 1);
newsig = sqrt( sum(ga .* bsxfun(@minus, tr', newmu).^2,1)  ./ (sum(ga ,1)-1) ) ;

newgauss = @(x) exp( -(mu-x).^2 /2 ./newsig./newsig);
newnpdf = zeros(len, ns);

%precalc & normalize (necessary?) normpdf
for i = 1:len
    newnpdf(i,:) = newgauss(tr(i));
end
%normalize
newnpdf = bsxfun(@rdivide, newnpdf, sum(newnpdf,2));
% tic
% %vitterbi
% vitdp = zeros(len-1, ns); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
% vitdp(1,:) = 1:ns;
% vitsc = newpi .* newnpdf(1,:);
% for i = 1:len-1
%     [vitsc, vitdp(i,:)] = max(bsxfun(@times, newa, vitsc'), [], 1);
%     vitsc = vitsc .* newnpdf(i+1,:) / sum(vitsc); %renormalize
% end
% toc

%vit no bsxfun
% tic
vitdp2 = zeros(len-1, ns); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
vitdp2(1,:) = 1:ns;
vitsc2 = newpi .* newnpdf(1,:);
for i = 1:len-1
    for j = 1:ns
        [vitsc2(j), vitdp2(i,j)] = max( newa(:,j) .* vitsc2' );
    end
%     [vitsc, vitdp(i,:)] = max(bsxfun(@times, newa, vitsc'), [], 1);
    vitsc2 = vitsc2 .* newnpdf(i+1,:) / sum(vitsc2); %renormalize
end

% toc
vitsc = vitsc2;
vitdp = vitdp2;
%assemble path via backtracking
st = zeros(1,len);
[~, st(len)] = max(vitsc);
for i = len-1:-1:1
    st(i) = vitdp(i,st(i+1));
end

%viterbi, just apply w/ inModel
vitdpim = zeros(len-1, ns); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
vitdpim(1,:) = 1:ns;
vitscim = pi .* npdf(1,:);
for i = 1:len-1
    for j = 1:ns
        [vitscim(j), vitdpim(i,j)] = max( a(:,j) .* vitscim' );
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

%Calculate logprob of this path. Is this just log(vitsc), if we didn't kept track of normalization? Oh well
%Noise term
lp1 = sum( log(normpdf(tr-newmu(st), 0, newsig(st)) ) );
%Transitions term
lp2 = zeros(1,len-1);
for i = 1:len-1
    lp2(i) = newa(st(i), st(i+1));
end
lp2 = sum( log( lp2 ) );
logprob = lp1+lp2;

out.a = newa;
out.mu = newmu;
out.sig = newsig;
out.pi = newpi;
out.ns = ns;
out.fitmle = fitmle(:)';
out.fit = st(:)';
out.fitnoopt = st2(:)';
out.logprob = logprob;

out.start = inModel;
%Changed output to not be out.start and out.finish, so old code may error.

%Plot: Trace and fit, r/g/b = MLE fit, Vit fit (input model), and Vit fit
if verbose == 1
    figure, plot(tr, 'Color', [.7 .7 .7]), hold on, plot( newmu(st), 'b' )
    plot( newmu(st2)+range(tr)/5, 'g' )
    plot( newmu(fitmle)+2*range(tr)/5, 'r' )
    fprintf('Trace logprob: %0.3f\n', sum(log(scal)) + log(sum(al(end,:))) )
elseif verbose == 2
    fprintf('Trace logprob: %0.3f\n', sum(log(scal)) + log(sum(al(end,:))) )
end