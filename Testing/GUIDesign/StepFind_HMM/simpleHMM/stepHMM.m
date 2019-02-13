function out = stepHMM(intrace, inModel)
%Fits a HMM to a stepping problem, generates test data if none supplied
%Let's assume no backtracking - can do if we define a center for a / do symmetric

%Optimizations: calculate with smaller array fragments, not whole (sparse ok?)
%Can e.g. make aa sparse (easy construction with @spdiags)

%inModel has required fields:
%  a (scalar, transition array)
% and optional fields:
%  mu(scalar, noise; default is std(intrace(:)-smooth(intrace,125)) )
%  pi(array, initial probabilities; default is normpdf(y, tr(1), mu) )

binsz = 0.1;

if nargin<1
    %simulate trace data
    realmu = 10;
    realsig = realmu/2;
    %two options: stay, or hop forwards
    reala = [.99 .1];
    len = 5e3;
    realst = zeros(1,len);
    realst(1) = 1; %start in state 1
    for i = 2:len
        %roll dice
        switch find(rand(1) < cumsum(reala),1)
            case 2
                dst = realmu;
            otherwise
                dst = 0;
        end
        realst(i) = realst(i-1)+dst;
    end
    tr = realst + randn(1,len)*realsig;
    real.mu = realmu;
    real.sig = realsig;
    real.a = reala;
    real.tr = tr;
    real.st = realst;
else
    tr = double(intrace);
    len = length(tr);
end

if nargin<2 %generate model guess
    maxstep = 25;
    %a: search from 0 to 20bp step, guess 10bp step
    a = normpdf(0:binsz:maxstep, 10, 5);
    
%     a = zeros(1, 1+maxstep/binsz);
%     a(23) = 1;
    
    a(1) = a(1) + 1e8;
    a = a/sum(a);

    
    inModel.a = a;
    inModel.sig = sig;
else %given model
    a = inModel.a;
    if isfield(inModel, 'sig')
        sig = inModel.sig;
    end
    if isfield(inModel, 'pi')
        pi = inModel.pi;
    end
end

%guess sig if not supplied
if ~exist('sig', 'var')
    sig = std( tr(:) - smooth(tr,125) );
end

%renormalize tr, so smallest point is binsz, trace is increasing
pfit = polyfit(1:length(tr),tr,1);
if pfit(1)<0
    tr = fliplr(tr);
end
dtr = - min(tr)+binsz;
tr = tr + dtr;
%define state grid
y = (1:ceil(max(tr)/binsz))*binsz;
hei = length(y);

%define upper, lower bdys in terms of y-indicies
maxdif = max(abs(diff(tr)));
ub = min( ceil((tr+maxdif)/binsz), hei);
lb = max( floor((tr-maxdif)/binsz), 1);
wid = ub-lb+1;
widmx = max(wid);

%define normpdf, gaussian fcn
gauss = @(x,mu) exp( -(mu-x).^2 /2 /sig^2);
npdf = @(ind) gauss(tr(ind), y(lb(ind):ub(ind)));

%{
tic
%calculate alpha -- currently works, faster than wholewidth
al = zeros(len,widmx);
scal = zeros(len,1);
pi = gauss(tr(1), y(lb:ub));
al(1,1:wid(1)) = pi .* npdf(1);
scal(1) = sum(al(1,:));
al(1,:) = al(1,:)/scal(1);
num0s = -diff(lb); %number of 0s to pad
lena = length(a);
convwid = lena+size(al,2)-1;
for i = 2:len
    %can do fft instead?
    temp = conv(al(i-1,:),a);
%     %pad the front with zeros if the offset has shifted downwards
%     t1 = zeros(1, max(0, num0s(i-1)));
%     %include the part of the conv we care about
%     t2 = temp( max(1,1-num0s(i-1)):min(wid(i)-num0s(i-1),convwid) );
%     %pad the end with 0s if there weren't enough terms in conv
%     t3 = zeros(1, max(0, wid(i)-num0s(i-1)-convwid ) );
    al(i,1:wid(i)) = [ zeros(1, max(0, num0s(i-1))) temp( max(1,1-num0s(i-1)):min(wid(i)-num0s(i-1),convwid) ) zeros(1, max(0, wid(i)-num0s(i-1)-convwid ) ) ] .* npdf(i);
    scal(i) = sum(al(i,:));
    al(i,:) = al(i,:)/scal(i);
end
toc
%}

tic
%alpha, whole-width way
al2 = zeros(len,widmx);
scal2 = zeros(len,1);
npdf2 = @(ind) gauss(y, tr(ind));
if ~exist('pi', 'var')
    pi = npdf2(1);
else
    pi2 = zeros(1,hei);
    pi2(lb(1):ub(1)) = pi(1:wid(1));
    pi= pi2;
end
altemp = pi .* npdf2(1);
al2(1,1:wid(1)) = altemp(lb(1):ub(1));
scal2(1) = sum(al2(1,:));
al2(1,:) = al2(1,:)/scal2(1);
for i = 2:len
    %start with altemp = full alpha(t-1)
    altemp = conv(altemp, a);
    altemp = altemp(1:hei) .* npdf2(i);
    al2(i,1:wid(i)) = altemp(lb(i):ub(i));
    scal2(i) = sum(al2(i,:));
    al2(i,:) = al2(i,:)/scal2(i);
    altemp = altemp / scal2(i);
end
toc

%{
tic
%calculate beta -- currently broken, use wholewidth
be = zeros(len,widmx);
% num0s = -num0s;
be(len,:) = ones(1,widmx) / scal(len);
for i = len-1:-1:1
    temp = conv(be(i+1,1:wid(i+1)).* npdf(i+1),a(end:-1:1));
    convwid = length(temp);
    %be(i,1:wid(i)) = [ zeros(1, max(0, num0s(i) - lena )) temp( min(1,wid(i)-num0s(i)):end-max(0,1-lena+num0s(i)) ) zeros(1, max(0, wid(i)-num0s(i)-convwid ) ) ] .* npdf(i+1) / scal(i);
%     t1= zeros(1, max(0, num0s(i) - lena ));
%     t2=temp( min(1,wid(i)-num0s(i)):end-max(0,1-lena+num0s(i)) );
%     t3=zeros(1, max(0, wid(i)-num0s(i)-convwid ) );
%     t4=[t1 t2 t3] .* npdf(i+1) / scal(i);
%     be(i,1:wid(i)) = t4;
    be(i,1:wid(i)) = [ zeros(1, max(0, num0s(i))) temp( max(1,1-num0s(i)):min(wid(i)-num0s(i),convwid) ) zeros(1, max(0, wid(i)-num0s(i)-convwid ) ) ] / scal(i);
end
toc
%}

%beta, whole-width way
tic
be2 = zeros(len,widmx);
betemp = ones(1,hei)/scal2(len);
be2(len,1:wid(len)) = betemp(lb(len):ub(len));
lena = length(a);
for i = len-1:-1:1
    %start with betemp = full beta(t+1)
    betemp = conv(betemp.*npdf2(i+1), a(end:-1:1));
    betemp = betemp(lena:end) / scal2(i);
    be2(i,1:wid(i)) = betemp(lb(i):ub(i));
end
toc

%calculate gamma
% ga = al .* be;
% ga = bsxfun(@rdivide, ga,  sum(ga,2));

ga2 = al2 .* be2;
ga2 = bsxfun(@rdivide, ga2, sum(ga2,2));

% [~, ms] = max(ga,[],2);
% ms = ms + lb' -1;
% figure, plot(y(ms)), hold on, plot(tr)

[~, ms] = max(ga2,[],2);
ms = ms + lb' -1;
figure, hold on
plot(tr, 'Color', [.7 .7 .7 ])
if exist('realst', 'var')
    plot( realst + dtr, 'Color', 'g')
end
plot(y(ms), 'Color', 'b')
%IT WORKSSSSSSSS

% %calculate xi, matrix way
% xi = zeros(len-1, widmax, widmax);
% for i = 1:len-1
%     xi(i,:,:) = a .* bsxfun(@times, al(i,:).',be(i+1,:) .* npdf(i+1,:));
% end
% %normalize
% xi = bsxfun(@rdivide, xi, sum(sum(xi,3),2));

%{
disp xicalc
tic
%form a into matrix
aa = zeros(hei);
for i = 1:hei
    for j = 1:hei
        if j-i+1 >= 1 && j-i+1 <= lena;
            aa(i,j) = a(j-i+1);
        end
    end
end
toc

tic
xi = zeros(len-1, widmx, widmx); %big-ass matrix, O(3gb) - no sparse for 3D matrix
for i = 1:len-1
    %extract full alpha, beta
    tempal2 = zeros(1,hei);
    tempbe2 = zeros(1,hei);
    tempal2(lb(i):ub(i)) = al2(i,1:wid(i));
    tempbe2(lb(i+1):ub(i+1)) = be2(i+1,1:wid(i+1));
    tempxi2 = aa .* bsxfun(@times, tempal2.',tempbe2 .* npdf2(i+1));
    xi(i,1:wid(i),1:wid(i)) = tempxi2(lb(i):ub(i), lb(i):ub(i));
end
xi = bsxfun(@rdivide, xi, sum(sum(xi,3),2));
toc
%}

disp spxicalc
%memory check: size of xi (gb) if we need to keep xi (vs. just sum over it)
%{
reqmem = 8*len*widmx^2/2^30;
if reqmem>4
    resp = input(sprintf('Will require %0.2fGB memory. Continue? y/n', reqmem));
    if strcmpi(resp, 'y') || any(resp == 1)
        fprintf('Continuing \n');
    else
        fprintf('Quitting \n');
        return
    end
end
%}

tic
aa2 = spdiags( repmat(a, hei, 1), 0:lena-1, hei, hei);
toc
tic
% xi2 = cell(1,len-1);
xi3 = zeros(hei);
for i = 1:len-1
    %extract full alpha, beta
    tempal2 = sparse(ones(1, wid(i)), lb(i):ub(i), al2(i,1:wid(i)), 1, hei);
    tempbe2 = sparse(ones(1, wid(i+1)), lb(i+1):ub(i+1), be2(i+1, 1:wid(i+1)), 1, hei);
    tempxi2 = aa2 .* bsxfun(@times, tempal2.',tempbe2 .* npdf2(i+1));
    xi2 = full(tempxi2(lb(i):ub(i), lb(i):ub(i)));
    xi3(1:wid(i), 1:wid(i)) = xi3(1:wid(i), 1:wid(i)) + xi2/sum(sum(xi2));
end
% xi2 = cellfun(@(x) x/sum(sum(x)) , xi2, 'Uni', 0);
toc
%IT WORKS, sparse works and is faster, sameish memory

% %it should be the case that ga = sum(xi, 3);
% ga2xi = sum(xi2,3);
% [~, ms] = max(ga2xi,[],2);
% ms = ms + lb(1:end-1)' -1;
% figure, plot(y(ms)), hold on, plot(tr)

%new pi
newpi = ga2(1,:);

%{
%calculate new a
newa = zeros(size(a));
for i = 1:len-1
    [B, d] = spdiags(xi2{i});
    B = sum(B, 1);
    for j = 1:length(d)
        newa(d(j)+1) = newa(d(j)+1) + B(j);
    end
end
newa = newa / sum(newa);
%}

newa = zeros(size(a));
[B, d] = spdiags(xi3);
B = sum(B,1);
for j = 1:length(d)
    newa(d(j)+1) = newa(d(j)+1) + B(j);
end
newa = newa/sum(newa);

%calculate new sig; var = sum over time( sum over states(QE, weighted by gamma) ) / n-1
newsig = zeros(1,len);
for i = 1:len
    newsig(i) = sum( ga2(i,1:wid(i)) .* (tr(i) - y(lb(i):ub(i))).^2 );
end
newsig = sqrt(sum(newsig)/(length(newsig)-1));

%vitterbi for later
%{
%to calculate new mu, sig, we actually need to vitterbi
vitdp = zeros(len-1, widmx); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
vitsc = npdf2(1).^2;
for i = 1:len-1
    [vitsc, vitinds] = max(bsxfun(@times, aa2, vitsc'), [], 1);
    vitdp(i, 1:wid(i)) = vitinds (lb(i):ub(i)) .* logical(vitsc(lb(i):ub(i))); %second term zeros vitdp if score is 0
    vitsc = vitsc .* npdf2(i+1) / sum(vitsc); %renormalize, apply score
end
%assemble path via backtracking
st = zeros(1,len);
[~, st(len)] = max(vitsc);
for i = len-1:-1:1
    st(i) = vitdp(i,st(i+1)-lb(i+1)+1);
end

figure, plot(tr, 'Color', [.7 .7 .7 ]), hold on, plot(y(st))
%}

%to calculate new mu, sig, we actually need to vitterbi

%memcheck
reqmem = 8*len*hei/2^30;
if reqmem>6
    resp = input(sprintf('Will require %0.2fGB memory. Continue? y/n', reqmem));
    if strcmpi(resp, 'y') || any(resp == 1)
        fprintf('Continuing \n');
    else
        fprintf('Quitting \n');
        return
    end
end

vitdp = zeros(len-1, hei); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
vitsc = npdf2(1).^2;
for i = 1:len-1
    [vitsc, vitdp(i, :)] = max(bsxfun(@times, aa2, vitsc'), [], 1);
    vitsc = vitsc .* npdf2(i+1) / sum(vitsc); %renormalize, apply score
end
%assemble path via backtracking
st = zeros(1,len);
[~, st(len)] = max(vitsc);
for i = len-1:-1:1
    st(i) = vitdp(i,st(i+1));
end

figure, plot(tr, 'Color', [.7 .7 .7 ]), hold on, plot(y(st))



figure, plot( (1:length(a)-1)*binsz, newa(2:end)) %, xlim([0 10])

finish.a = newa;
finish.sig = newsig;
finish.pi = newpi;

out.start = inModel;
% out.real = real;
out.finish = finish;

fprintf('logprob %0.2f\n', log(sum(al2(end,:)))+sum(log(scal2)))

% figure, plot(tr, 'Color', [.7 .7 .7]), hold on, plot( realmu(realst), 'g' ), plot( newmu(st), 'b' )