function out = findStepHMMV1b(inTrace, inModel, verbose)
%Fits a HMM that models a staircase
%Let's assume no backtracking - can do if we define a center for a / do symmetric
%If there is sufficient backtracking, some probabilties will go to zero - errors

%out has fields: a, sig, pi, fit, logp
%a, sig, pi are model parameters
%fit is the vitterbi fit of the data
%logp is the log of the probability score

%inModel has required fields: a; and optional fields: mu, pi

if nargin < 1
    %set to perfect signal, sd given
    sd = 1;
    inTrace = [zeros(1,100) ones(1,100)*2.5 ones(1,100)*5 ones(1,100)*7.5 ones(1,100)*8.6];
    inTrace = inTrace + sd*randn(1,length(inTrace));
%     inTrace = [inTrace 4+inTrace];
end

stT = tic;
binsz = 0.1;
tr = double(inTrace);
len = length(tr);

if nargin < 3 || isempty(verbose)
    verbose = 1;
end

if nargin<2 || isempty(inModel) %generate model guess
    inModel = [];
end

%trns matrix
if ~isfield(inModel, 'a')
    %search from 0 to 25bp step, seed with gaussian (high sig = essentially flat fcn)
    maxstep = 15;
    guessmean = 2.5;
    guesssig = 2;
    %a: search from 0 to maxstep
    a = normpdf(0:binsz:maxstep, guessmean, guesssig);
%     a=ones(1,length(0:binsz:maxstep));
    %guess transition prob is 1/100
    pstep = 0.001;
    a(2:end) = a(2:end)/sum(a(2:end)) *pstep;
    a(1) = 1-pstep;
else %given model, i.e. the output of this fcn.
    a = inModel.a;
end

%sd noise
if ~isfield(inModel, 'sig')
    sig = sqrt(estimateNoise(tr,[],2));
else
    sig = inModel.sig;
end

%starting state (default assigned below)
if isfield(inModel, 'pi')
    pi = inModel.pi;
end

%make trace increasing, minimum point binsz
tr = prepTrHMM(tr, binsz);
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
    altemp = altemp(1:hei) .* npdf2(i);%is the 1:hei necessary?
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

% %sanity check for _4steps
% [~, ms] = max(ga,[],2);
% ms = ms + lb' -1;
% figure, plot(ms);
% figure, surf(log(be))
% figure, surf(log(al))
% figure, plot(scal2)
% figure, surf(log(ga))

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

% figure%**debug
% ax1 = subplot(3,1,[1 2]);
% ax2 = subplot(3,1,[3]);

for i = 1:len-1
    %extract full alpha, beta, as sparse
    tempal = sparse(ones(1, wid(i)), lb(i):ub(i), al(i,1:wid(i)), 1, hei);
    tempbe = sparse(ones(1, wid(i+1)), lb(i+1):ub(i+1), be(i+1, 1:wid(i+1)), 1, hei);
    tempxi = aa .* bsxfun(@times, tempal.',tempbe .* npdf2(i+1));
    txi = full(tempxi(lb(i):ub(i), lb(i):ub(i)));
            
%         %**debug
%         mesh(ax1, txi-diag(diag(txi))), ax1.CameraPosition = [0 0 0]; ax1.CameraTarget = [1 1 0]; zlim(ax1,[0 1e-3])
%         plot(ax2, diag(txi))
%         drawnow
        
    
    xi(1:wid(i), 1:wid(i)) = xi(1:wid(i), 1:wid(i)) + txi/sum(txi(:));
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

% figure, mesh(log(xi))
% figure, mesh(xi-diag(diag(xi)))

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

%make a into a matrix
aa = spdiags( repmat(newa, maxwid2, 1), 0:lena-1, maxwid2, maxwid2);
%vitterbi for trace fit (mle is pretty much the same and faster, but vitterbi is more proper)
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

%assemble memory-less path (max over gamma)
[~, ms] = max(ga,[],2);
ms = ms + lb' -1;

%assign output structure
out.a = newa;
out.sig = newsig;
out.pi = newpi;
out.fit = y(st);
out.fitmle = y(ms);
out.logp = sum(log(scal2)) + log(sum(al(end,:)));

if verbose == 1
    %plot trace, likeliest state, vitterbi state in grey/blue/red respectively
    figure,subplot(3, 1, [1 2]), hold on
    plot(tr, 'Color', [.7 .7 .7 ])
    plot(y(ms), 'Color', 'b')
    plot(y(st), 'Color', 'r')
    %write stats
    yl = ylim;
    yp = 0.9 * yl(2) + 0.1 * yl(1);
    text(0,yp,sprintf('trnsprb %0.04f, sig %0.2f, logp %0.2f', 1-newa(1), out.sig, out.logp))
    %plot a
    subplot(3, 1, 3), plot( (1:length(a)-1)*binsz, newa(2:end) / (1-newa(1)) )
    %Finds steps from 0 to 25, but some can be 0; find last nonzero
    xm = find(newa > 1e-5, 1, 'last');
    xlim([0 xm*binsz])
    set(gca, 'YScale', 'log')
    %output stats to command window
    fprintf('%s took %0.2fs, logp=%0.2f\n', mfilename, toc(stT), out.logp)
elseif verbose == 2
    fprintf('%s took %0.2fs, logp=%0.2f\n', mfilename, toc(stT), out.logp)
end