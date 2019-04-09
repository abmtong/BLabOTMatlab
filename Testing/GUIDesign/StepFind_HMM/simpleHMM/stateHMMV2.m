function out = stateHMMV2(tr, inModel)
%Fits a HMM to a n-state hopping problem; generates test data if nothing supplied

if nargin<2 %generate model guess
    inModel = [];
end

if ~isfield(inModel, 'ns')
    ns = 2;
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

if ~isfield(inModel, 'mu')
    mu = (2:ns+1)/(ns+2) * (max(tr) - min(tr)) + min(tr); %evenly divided
    inModel.mu = mu;
else
    mu = inModel.mu;
end

if ~isfield(inModel, 'sig')
    sig = sqrt(estimateNoise(tr, [], 2));
%     sig = std(tr);
    inModel.sig = sig;
else
    sig = inModel.sig;
end

if ~isfield(inModel, 'pi')
    pi = normpdf(mu,tr(1),sig);
    pi = pi/sum(pi);
    inModel.pi = pi;
else
    pi = inModel.pi;
end

len = length(tr);

%precalc & normalize (necessary?) normpdf
gauss = @(x) exp( -(mu-x).^2 /2 /sig/sig);
npdf = zeros(len,ns);
for i = 1:len
    npdf(i,:) = gauss(tr(i));
end
%normalize
npdf = bsxfun(@rdivide, npdf, sum(npdf,2));


sta1 = tic;
%calculate alpha
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
ta1 = toc(sta1);

sta2 = tic;
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
ta2 = toc(sta2);

stb1 = tic;
%calculate beta
be = zeros(len,ns);
be(len,:) = ones(1,ns);
be(len,:) = be(len,:) / scal(len);
for i = len-1:-1:1
    be(i,:) = be(i+1, :) .* npdf(i+1,:) * a.' / scal(i);
end
tb1 = toc(stb1);

stb2 = tic;
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
tb2 = toc(stb2);

fprintf('al: matrix %0.5fs, for %0.5fs; be: matrix %0.5fs, for %0.5fs\n', ta1, ta2, tb1, tb2)

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


%more rigorous way
xi = zeros(len-1, ns, ns);
for i = 1:len-1
    xi(i,:,:) = a .* bsxfun(@times, al(i,:).',be(i+1,:) .* npdf(i+1,:));
end
%normalize
%could also do in loop (temp = ..., tempsum = sum(sum(temp)), xi(i,:,:) = temp/tempsum, but matrix ops should be faster?
xi = bsxfun(@rdivide, xi, sum(sum(xi,3),2));

%non-matrix way, probably slower unless JIT
xi2 = zeros(len-1,ns,ns);
for t = 1:len-1
    for i = 1:ns
        for j = 1:ns
            xi2(t,i,j) = al(t,i) * a(i,j) * npdf(t+1,j) * be(t+1,j);
        end
    end
end
xi2 = bsxfun(@rdivide, xi2, sum(sum(xi,3),2));

%it should be the case that ga = sum(xi, 3); : true
% ga2 = sum(xi,3);
% ga3 = sum(xi2,3);

%calculate new var.s
newpi = ga(1,:);
newa = squeeze(sum(xi,1));
newa = bsxfun(@rdivide, newa, sum(newa, 2));
newmu = sum(bsxfun(@times, ga, tr'), 1) ./ sum(ga, 1);
newsig = sqrt( sum(sum(ga .* bsxfun(@minus, tr', newmu).^2))  / (len-1) ) ;

newgauss = @(x) exp( -(mu-x).^2 /2 /newsig/newsig);
newnpdf = zeros(len, ns);

%precalc & normalize (necessary?) normpdf
for i = 1:len
    newnpdf(i,:) = newgauss(tr(i));
end
%normalize
newnpdf = bsxfun(@rdivide, newnpdf, sum(newnpdf,2));

%vitterbi
vitdp = zeros(len-1, ns); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
vitdp(1,:) = 1:ns;
vitsc = newpi .* newnpdf(1,:);
for i = 1:len-1
    [vitsc, vitdp(i,:)] = max(bsxfun(@times, newa, vitsc'), [], 1);
    vitsc = vitsc .* newnpdf(i+1,:) / sum(vitsc); %renormalize
end

%assemble path via backtracking
st = zeros(1,len);
[~, st(len)] = max(vitsc);
for i = len-1:-1:1
    st(i) = vitdp(i,st(i+1));
end

%vitterbi, just apply w/ inModel
vitdp = zeros(len-1, ns); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
vitdp(1,:) = 1:ns;
vitsc = pi .* npdf(1,:);
for i = 1:len-1
    [vitsc, vitdp(i,:)] = max(bsxfun(@times, a, vitsc'), [], 1);
    vitsc = vitsc .* npdf(i+1,:) / sum(vitsc); %renormalize
end

%assemble path via backtracking
st2 = zeros(1,len);
[~, st2(len)] = max(vitsc);
for i = len-1:-1:1
    st2(i) = vitdp(i,st2(i+1));
end

finish.a = newa;
finish.mu = newmu;
finish.sig = newsig;
finish.pi = newpi;
finish.ns = ns;
finish.fitmle = fitmle(:)';
finish.fit = st(:)';
finish.fitnoopt = st2(:)';

out.start = inModel;
out.finish = finish;

%it works! kinda, weird on convergence (a's sometimes diverge)
figure, plot(tr, 'Color', [.7 .7 .7]), hold on, plot( newmu(st), 'b' )
plot( newmu(st2)+range(tr)/5, 'g' )
plot( newmu(fitmle)+2*range(tr)/5, 'r' )
fprintf('Trace logprob: %0.3f\n', sum(log(scal)) + log(sum(al(end,:))) )