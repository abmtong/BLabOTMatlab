function out = stateHMM(inRealModel, inModel)
%Fits a HMM to a n-state hopping problem; generates test data if nothing supplied
ns = 4;

if nargin<1
    %simulate trace data
    % reals = [1 2 4.5];
    realmu = (1:ns)/ns + randn(1,ns)/ns^2/2;
    realsig = 1/ns;
    % reala = [.99 .002 .008; .004 .99 .006; .009 .001 .99];
    reala = rand(ns) / 100 /ns + diag(ones(1,ns));
    reala = bsxfun(@rdivide, reala, sum(reala,2));
    % reala = [.95 .01 .04; .02 .95 .03; .04 .01 .95];
    % reala = [.95 .05 0; .02 .95 .03; 0 .05 .95];
    len = 1e5;
    realst = zeros(1,len);
    realpi = [1 0 0];
    realst(1) = 1; %start in state 1
    for i = 2:len
        %roll dice
        newstate = find( rand(1) < cumsum(reala(realst(i-1),:)), 1);
        realst(i) = newstate;
    end
    tr = realmu(realst);
    tr = tr + realsig * randn(1,len);
    real.mu = realmu;
    real.sig = realsig;
    real.a = reala;
    real.tr = tr;
    real.st = realst;
    real.pi = realpi;
else
%     tr = inRealModel.tr;
%     len = length(tr);
%     realmu = inRealModel.mu;
%     realst = inRealModel.st;
%     real = inRealModel;
end

if nargin<2 %generate model guess
%     a = [.99 .005 .005; .005 .99 .005; .005 .005 .99];
a = ones(ns)/30 + diag(ones(1,ns));
a = bsxfun(@rdivide, a, sum(a,2));
%     a = [.99 .01 0; .005 .99 .005; 0 .01 .99];
%     a = ones(3)/3;
    %guess mu
    mu = (1:ns)/ns;
    %guess sig
    sig = 1/ns;
    %guess pi
    pi = normpdf(mu,tr(1),sig);
    pi = pi/sum(pi);
    
    inModel.a = a;
    inModel.mu = mu;
    inModel.sig = sig;
    inModel.pi = pi;
else %given model
    a = inModel.a;
    mu = inModel.mu;
    sig = inModel.sig;
    pi = inModel.pi;
end

%precalc/normalize normpdf
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

%it should be the case that ga = sum(xi, 3);
ga2 = sum(xi,3);
ga3 = sum(xi2,3);

%calculate new a, pi
newpi = ga(1);
newa = squeeze(sum(xi,1));
% newa = bsxfun(@rdivide, newa,  sum(ga(1:end-1,:), 1) );
newa = bsxfun(@rdivide, newa, sum(newa, 2));
%%someting slightly wrong with either gamma or xi, norm. not quite working

%to calculate new mu, sig, we actually need to vitterbi
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
% st = st + lb - 1;

figure, plot(y(st))

finish.a = newa;
finish.mu = newmu;
finish.sig = newsig;
finish.pi = newpi;

out.start = inModel;
out.real = real;
out.finish = finish;

%it works! kinda, weird on convergence (a's sometimes diverge)
figure, plot(tr, 'Color', [.7 .7 .7]), hold on, plot( realmu(realst), 'g' ), plot( newmu(st), 'b' )
fprintf('Trace logprob: %0.3f\n', sum(log(scal)) + log(sum(al(end,:))) )
