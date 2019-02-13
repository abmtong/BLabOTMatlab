function out = findStepHMMV1(intrace, inModel)
%Fits a HMM that models a staircase
%Let's assume no backtracking - can do if we define a center for a / do symmetric

%Optimizations: calculate with smaller array fragments, not whole (sparse ok?)
%Can e.g. make aa sparse (easy construction with @spdiags)

%inModel has required fields:
%  a (scalar, transition array)
% and optional fields:
%  mu(scalar, noise; default is std(intrace(:)-smooth(intrace,125)) )
%  pi(array, initial probabilities; default is normpdf(y, tr(1), mu) )

stT = tic;
binsz = 0.1;
calcvitterbi = 1;
tr = double(intrace);
len = length(tr);

if nargin<2 %generate model guess
    %search from - to 25bp step, seed with gaussian (high sig = essentially flat fcn)
    maxstep = 25;
    guessmean = 5;
    guesssig = 100;
    %a: search from 0 to maxstep
    a = normpdf(0:binsz:maxstep, guessmean, guesssig);
%     a = zeros(1, 1+maxstep/binsz);
%     a(23) = 1;
    a(1) = a(1) + 1e5; %make the no-step much more likely than a step
    a = a/sum(a);
    inModel.a = a;
else %given model, i.e. the output of this fcn.
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
    inModel.sig = sig;
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
ub = min(  ceil((tr+maxdif)/binsz), hei);
lb = max( floor((tr-maxdif)/binsz), 1);
wid = ub-lb+1;
widmx = max(wid);

%define normpdf, gaussian fcn
gauss = @(x,mu) exp( -(mu-x).^2 /2 /sig^2);
% npdf = @(ind) gauss(tr(ind), y(lb(ind):ub(ind)));

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

%alpha, whole-width way
al = zeros(len,widmx);
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
al(1,1:wid(1)) = altemp(lb(1):ub(1));
scal2(1) = sum(al(1,:));
al(1,:) = al(1,:)/scal2(1);
for i = 2:len
    %start with altemp = full alpha(t-1)
    altemp = conv(altemp, a);
    altemp = altemp(1:hei) .* npdf2(i);
    al(i,1:wid(i)) = altemp(lb(i):ub(i));
    scal2(i) = sum(al(i,:));
    al(i,:) = al(i,:)/scal2(i);
    altemp = altemp / scal2(i);
end

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
be = zeros(len,widmx);
betemp = ones(1,hei)/scal2(len);
be(len,1:wid(len)) = betemp(lb(len):ub(len));
lena = length(a);
for i = len-1:-1:1
    %start with betemp = full beta(t+1)
    betemp = conv(betemp.*npdf2(i+1), a(end:-1:1));
    betemp = betemp(lena:end) / scal2(i);
    be(i,1:wid(i)) = betemp(lb(i):ub(i));
end

%calculate gamma
ga = al .* be;
ga = bsxfun(@rdivide, ga, sum(ga,2));


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

%calculate xi
%make new lb/ub which is the extermer of the two of i and i+1
lb2 = min( [lb(1:end-1); lb(2:end)] , [] , 1);
ub2 = max( [ub(1:end-1); ub(2:end)] , [] , 1);
wid2 = ub2-lb2+1;
maxwid2 = max(wid2);
%make 2d a
aa = spdiags( repmat(a, hei, 1), 0:lena-1, hei, hei);
xi = zeros(hei);
for i = 1:len-1
    %extract full alpha, beta
    tempal = sparse(ones(1, wid(i)), lb(i):ub(i), al(i,1:wid(i)), 1, hei);
    tempbe = sparse(ones(1, wid(i+1)), lb(i+1):ub(i+1), be(i+1, 1:wid(i+1)), 1, hei);
    tempxi = aa .* bsxfun(@times, tempal.',tempbe .* npdf2(i+1));
    txi = full(tempxi(lb(i):ub(i), lb(i):ub(i)));
    xi(1:wid(i), 1:wid(i)) = xi(1:wid(i), 1:wid(i)) + txi/sum(sum(txi));
end

%{
xi2 = zeros(maxwid2);
npdf3 = @(ind) gauss(y(lb2(ind):ub2(ind)), tr(ind));
for i = 1:len-1
    %take al, be 
    tempal = zeros(1, wid2(i));
    tempbe = zeros(1, wid2(i));
    tempal( (lb(i):ub(i)) -lb2(i)+1 ) = al(lb(i):ub(i));
    tempbe( (lb(i+1):ub(i+1)) -lb2(i)+1 ) = be(lb(i+1):ub(i+1));
    txi2 = aa(1:wid2(i), 1:wid2(i)) .* bsxfun(@times, tempal.',tempbe .* npdf3(i));
    xi2(1:wid2(i), 1:wid2(i)) = xi2(1:wid2(i), 1:wid2(i)) + txi2/sum(sum(txi2));
end
newa2 = zeros(size(a));
[B, d] = spdiags(xi2);
B = sum(B,1);
for j = 1:length(d)
    newa2(d(j)+1) = newa2(d(j)+1) + B(j);
end
newa2 = newa2/sum(newa2);
%}

%new pi
newpi = zeros(1,hei);
newpi(lb(1):ub(1)) = ga(1,1:wid(1));

%new a
newa = zeros(size(a));
[B, d] = spdiags(xi);
d = d(d>=0); %find why d is negative sometimes - I assume when P underflows (backtracking?)
if(any(d<0))
    fprintf('d < 0 on this trace')
end
B = sum(B,1);
for j = 1:length(d)
    newa(d(j)+1) = newa(d(j)+1) + B(j);
end
newa = newa/sum(newa);

%new sig
newsig = zeros(1,len);
for i = 1:len
    newsig(i) = sum( ga(i,1:wid(i)) .* (tr(i) - y(lb(i):ub(i))).^2 );
end
newsig = sqrt(sum(newsig)/(length(newsig)-1));

%plot likeliest state
[~, ms] = max(ga,[],2);
ms = ms + lb' -1;
figure,subplot(3, 1, [1 2]), hold on
plot(tr, 'Color', [.7 .7 .7 ])
if exist('realst', 'var')
    plot( realst + dtr, 'Color', 'g')
end
plot(y(ms), 'Color', 'b')

%vitterbi, quick way (broken)
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

if calcvitterbi
    aa = spdiags( repmat(newa, maxwid2, 1), 0:lena-1, maxwid2, maxwid2);
    %vitterbi for trace fit (mle is pretty much the same, takes twice time)
    vitdp = zeros(len-1, maxwid2); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
    vitsc = npdf2(1).^2;
    for i = 1:len-1
%         [vitsc, vitdp(i, :)] = max(bsxfun(@times, aa, vitsc'), [], 1);
        [tvitsc, tvitdp] = max(bsxfun(@times, aa(1:wid2(i),1:wid2(i)), vitsc(lb2(i):ub2(i))'), [], 1);
        vitsc = zeros(1,hei);
        vitsc(lb2(i):ub2(i)) = tvitsc;
        vitdp(i, 1:wid2(i)) = tvitdp + lb2(i) -1;
        vitsc = vitsc .* npdf2(i+1) / sum(vitsc); %renormalize, apply score
    end
    %assemble path via backtracking
    st = zeros(1,len);
    [~, st(len)] = max(vitsc);
    for i = len-1:-1:1
        st(i) = vitdp(i,st(i+1)-lb2(i)+1);
    end
    plot(y(st), 'Color', 'r')
end
subplot(3, 1, 3), plot( (1:length(a)-1)*binsz, newa(2:end))
% hold on, plot( (1:length(a)-1)*binsz, newa2(2:end)) %, xlim([0 10])

finish.a = newa;
finish.sig = newsig;
finish.pi = newpi;

out.start = inModel;
out.finish = finish;
fprintf('HMM took %0.2fs, logprob=%0.2f\n', toc(stT), log(sum(al(end,:)))+sum(log(scal2)))