function out = findStepHMMV1b_4steps(inTrace, inModel, verbose)
%Fits a HMM that models a staircase of four steps
%Two transition matricies: First 3 steps the same, last step different

%Inputs: 


%Let's assume no backtracking - can do if we define a center for a / do symmetric

%outdated comments
%out has fields: a, sig, pi, fit, logp
%a, sig, pi are model parameters
%fit is the vitterbi fit of the data
%logp is the log of the probability score

%inModel has required fields: a; and optional fields: mu, pi

if nargin < 1 || isempty(inTrace)
    %set to perfect signal, sd given
    sd = 1;
    lng = 50;
    inTrace = [zeros(1,lng*1.5) ones(1,lng)*2.5 ones(1,lng)*5 ones(1,lng)*7.5 ones(1,lng)*8.6];
    inTrace = inTrace + sd*randn(1,length(inTrace));
end

stT = tic;
binsz = 0.1;
tr = double(inTrace);
len = length(tr);

if nargin < 3 || isempty(verbose)
    verbose = 1;
end

if nargin<2 || isempty(inModel) %generate model guess
    maxstep = 25;
    %Transition probabilities for dwell and burst
    a.dp = .01; %changing this is enough to differentiate the states, ish; but also introduces artifacts?
    a.bp = .01;
    %Step probabilities for first 3 and last step
%     a.ds1 = ones(1, length(binsz:binsz:maxstep)) + 0.05 * randi(10,1,length(binsz:binsz:maxstep));
%     a.ds2 = ones(1, length(binsz:binsz:maxstep)) + 0.05 * randi(10,1,length(binsz:binsz:maxstep));
    aseedsd = 3;
    a.ds1 = normpdf( binsz:binsz:maxstep, 2.5, aseedsd); %seeding - otherwise the two states wouldn't diverge
    a.ds2 = normpdf( binsz:binsz:maxstep, 1.1, aseedsd);
    
    a.ds1 = a.ds1 / sum(a.ds1);
    a.ds2 = a.ds2 / sum(a.ds2);
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
    sig = sqrt(estimateNoise(tr));
end

%make trace increasing, minimum point binsz
tr = prepTrHMM(tr, binsz);
%define state grid
y = (1:ceil(max(tr)/binsz))*binsz;
hei = length(y);

%define upper, lower bdys in terms of y-indicies
maxdif = max(abs(diff(tr)));
pad = 0; %states to pad on each side? **maybe remove
ub = min(  ceil((tr+maxdif)/binsz+pad), hei);
lb = max( floor((tr-maxdif)/binsz-pad), 1);
wid = ub-lb+1;
widmx = max(wid);

%define normpdf, gaussian fcn; faster than @normpdf(?)
gauss = @(x,mu) exp( -(mu-x).^2 /2 /sig^2);
% npdf = @(ind) gauss(tr(ind), y(lb(ind):ub(ind)));

%define "index mod", for doing cyclic index things with matlab's 1-based units
modi = @(x) mod(x-1,4)+1;

%alpha, whole-width way
%al/be matricies will be al(time, stepstate, dwbustate)
%essentially append a 3rd dimension where needed
al = zeros(len,widmx, 4);
scal2 = zeros(len,1);
npdf2 = @(ind) gauss(y, tr(ind));
if ~exist('pi', 'var')
    pi = repmat(npdf2(1), [1 1 4]);
else
    pi2 = zeros(1,hei);
    pi2(lb(1):ub(1)) = pi(1:wid(1));
    pi= repmat(pi2, [1 1 4]);
end
%make first alpha, = pi * gauss
alold = pi .* repmat(npdf2(1), [1 1 4]); %* a.dp^2; alpha starts very large, but is this relevant?
alnew = alold;
%extract usable bit
al(1,1:wid(1),:) = alold(1,lb(1):ub(1),:);
%calc scale factor, scal2(i,1,j) = sum(alpha(i,:,j))
scal2(1) = sum(sum(al(1,:,:),2),3);
al(1,:,:) = al(1,:,:) / scal2(1); %bsxfun not necessary in later matlabs, as bsx'ing is done automatically

%Create transition matrix tm
tm(:,:,1) = [0 a.dp*a.ds1];
tm(:,:,2) = [0 a.bp*a.ds1];
tm(:,:,3) = [0 a.bp*a.ds1];
tm(:,:,4) = [0 a.bp*a.ds2];
%create stay probabilities
prb = [1-a.dp 1-a.bp 1-a.bp 1-a.bp];

%ARRAY SIZES
%alold alnew: [1 hei 4]: stores old (i-1) / new (i) full-width alphas
%al: [len widmx 4] : stores offset alpha values
%tm: [1 maxstep/binsz+1 4] : stores transition matrix
%scal2: [len 1 1] : stores scale factor scal2(i,1,1) for al(i,:,:)

for i = 2:len
    for j = 1:4
        %start with altemp = full alpha(t-1) since now we need to preserve altemp through j-cycles
        %add from those that jumped (j-1 -> j)
        tmp = conv( squeeze(alold(1,:,modi(j-1))), squeeze(tm(1,:,modi(j-1))));
        alnew(1,:,j) = tmp(1:hei);
        %and add from those that didn't jump (j -> j)
        alnew(1,:,j) = alnew(1,:,j) + alold(1,:,j) * prb(j);
    end
    %Multiply by gauss
    alnew(1,:,:) = bsxfun(@times, alnew(1,:,:), npdf2(i));
    %Normalize
    scal2(i) = sum(alnew(:));
    alold = alnew/scal2(i);
    %Extract useful bit to alpha
    al(i,1:wid(i),:) = alold(1,lb(i):ub(i),:);
end

%beta, whole-width way
be = zeros(len,widmx,4);
beold = ones(1,hei,4)/scal2(len);
benew = beold;

be(len,1:wid(len), :) = beold(1, lb(len):ub(len), :);
lentm = length(tm(1,:,1));

for i = len-1:-1:1
    %start with betemp = full beta(t+1)
    for j = 1:4
         %calculate new beta
         %add term from j <- j+1
         tmp = conv( squeeze(beold(1,:,modi(j+1))).*npdf2(i+1), squeeze(tm(1, end:-1:1, j)));
         benew(1,:,j) = tmp(lentm:end);
         %add term from j <- j
         benew(1,:,j) = benew(1,:,j) + beold(1,:,j).*npdf2(i+1) * prb(j);
    end
    %rename benew to beold and normalize
    beold = benew/ scal2(i);
    %save relevant bit
    be(i,1:wid(i),:) = beold(1,lb(i):ub(i),:);
end

%calculate gamma
ga = al .* be;
ga = bsxfun(@rdivide, ga, sum(sum(ga,3),2)); %normalize so sum ga for one i is 1

%calculate xi
%make new lb/ub which is the extremer of the two of i and i+1
lb2 = min( [lb(1:end-1); lb(2:end)] , [] , 1);
ub2 = max( [ub(1:end-1); ub(2:end)] , [] , 1);
wid2 = ub2-lb2+1;
maxwid2 = max(wid2);
%don't actually need this here(?) but useful for vitterbi later
%make 2d tm
tm2 = cell(1,4);
for j = 1:4
    tm2{j} = spdiags( repmat(tm(1,:,j), hei, 1), 0:lentm-1, hei, hei);
end
xi = zeros(hei, hei, 4);
% figure%**debug
% ax1 = subplot(3,1,[1 2]);
% ax2 = subplot(3,1,3]);
for i = 1:len-1
    txi = zeros(wid(i), wid(i), 4);
    for j = 1:4
        %Add step part
        %extract full alpha, beta, as sparse
        tempal = sparse(ones(1, wid(i)),   lb(i):ub(i),     al(i  , 1:wid(i)  , j        ), 1, hei);
        tempbe = sparse(ones(1, wid(i+1)), lb(i+1):ub(i+1), be(i+1, 1:wid(i+1), modi(j+1)), 1, hei);
        tempbe2= sparse(ones(1, wid(i+1)), lb(i+1):ub(i+1), be(i+1, 1:wid(i+1), j        ), 1, hei);
        tempxi = tm2{j} .* bsxfun(@times, tempal.',tempbe .* npdf2(i+1));
        txi1 = full(tempxi(lb(i):ub(i), lb(i):ub(i)));
        %calculate non-step part
        txi2 = diag( tempal .* tempbe2 .* npdf2(i+1) * prb(j) );
        %And add to txi
        txi(:,:,j) = txi1 + txi2( lb(i):ub(i),lb(i):ub(i) );
    end
%     %**debug
%     mesh(ax1, txi-diag(diag(txi))), ax1.CameraPosition = [0 0 0]; ax1.CameraTarget = [1 1 0];  zlim(ax1,[0 1e-3])
%     plot(ax2, diag(txi))
%     drawnow
    
    %normalize, add to xi
    xi(1:wid(i), 1:wid(i), :) = xi(1:wid(i), 1:wid(i), :)+txi/sum(txi(:));
end


%new pi
newpi = zeros(1,hei,4);
newpi(1,lb(1):ub(1),:) = ga(1,1:wid(1),:);

%new transition matrix
newa = cell(1,4);
for j=1:4;
    tnewa = zeros(size(tm(1,:,j)));
    [B, d] = spdiags(xi(:,:,j)); %extract diagonals
    d = d(d>=0); %Sanity check for proper alignment (only positive steps : positive diagonals)
    if(any(d<0))
        fprintf('d < 0 on this trace')
    end
    B = sum(B,1);
%     tnewa = B(d+1);
    for k = 1:length(d)
        tnewa(d(k)+1) = tnewa(d(k)+1) + B(k);
    end
    newa{j} = tnewa;
end
%Sum same steps / transition probabilities together
%newa1/2 transitions
%newdp/bp chance to transition

%Get 123rd step size
newa1 = zeros(1,lentm);
for j = 1:3
    newa1 = newa1 + newa{j};
end
newa1(1) = [];
newa1 = newa1 / sum(newa1);

%Get 4th step size
newa2 = newa{4};
newa2(1) = [];
newa2 = newa2 / sum(newa2);

%Get first dwelltime
newdp = newa{1};
newdp = newdp/sum(newdp);
newdp = 1-newdp(1);

%Get bursttime
newbp = zeros(1,lentm);
for j = 2:4
    newbp = newbp + newa{j};
end
newbp = newbp/sum(newbp);
newbp = 1-newbp(1);

%get net waittime
newap = (newbp*3 + newdp) / 4;

%new sig
newsig = zeros(1,len);
for i = 1:len
    %sig(pt i) = sum(sum(ga(i, :, :) .* (tr(i)-y(:))^2)), = sum( ga[sum along dim 3] .* (tr-y).^2)
    newsig(i) = sum( sum(ga(i,1:wid(i),:),3) .* (tr(i) - y(lb(i):ub(i))).^2 );
end
newsig = sqrt(sum(newsig)/(length(newsig)-1));

%make tm into a matrix, width maxwid2 (instead of maxwid)
%for vitterbi, to end up in state j we need to either wait at state j or come from state j-1
usea = [];
useb = [];
tm3 = cell(1,4);
for j = 1:4
    switch j
        case 1
            usea = newa2; %come from state 4, use small step
            useb = newbp;
        case 2
            usea = newa1;
            useb = newdp; %came from state 1, use longer dwell
        case [3 4]
            usea = newa1;
            useb = newbp;
    end
    tm3{j} = spdiags( repmat( [1-useb usea*useb], maxwid2, 1), 0:lentm-1, maxwid2, maxwid2);
end

%vitterbi for trace fit (mle is pretty much the same and faster, but vitterbi is more proper)
vitdp = -ones(len-1, maxwid2) - sqrt(-1) * ones(len-1, maxwid2); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
%State is now two numbers, do this here by encoding the stepstate (what was dim. 3 in previous matricies) as the complex part
%Score of each end state - will pick the maximum of this at every time
vitsc = repmat(npdf2(1).^2, 1, 1, 4);

for i = 1:len-1
    for j = 1:4
        %To make the proper score matrix, which is the score of (j-1) as a column repeated but with score of (j) on the diagonal, add the difference in score of j and j-1 to the diagonal
        difsco = vitsc(1,:,j) - vitsc(1,:,modi(j-1));
        [tvitsc, tvitdp] = max(bsxfun(@times, tm3{j}(1:wid2(i),1:wid2(i)), repmat( vitsc(1,lb2(i):ub2(i),modi(j-1))', 1, wid2(i)) + diag( difsco(lb2(i):ub2(i))) ), [], 1);
        %we need to know whether the transition is a stay (initial state = final state) or a step (not that)
        indstay = tvitdp == 1:wid2(i);
        vitsc(1,:,j) = zeros(1,hei);
        vitsc(1,lb2(i):ub2(i),j) = tvitsc;
        %Did not jump if indstay, so those indicies stay the same. Otherwise, jump -> the best way is from the previous state.
        vitdp(i,1:wid2(i),j) = (tvitdp + lb2(i) -1) + sqrt(-1) * modi( (indstay*j) + (~indstay*(j-1)) );
    end
    %Normalize score
    vitsc = bsxfun(@times,vitsc / sum(vitsc(:)), npdf2(i)); %renormalize, apply position score
end

%assemble path via backtracking
st = complex(zeros(1,len), zeros(1,len)) ;
[~, maxst] = max(vitsc(:));
[maxstr, maxstc] = ind2sub([hei 4], maxst);
st(len) = maxstr + sqrt(-1) * maxstc;
for i = len-1:-1:1
    tmpst = real(st(i+1));
    tmpst2 = imag(st(i+1));
    st(i) = vitdp(i,tmpst-lb2(i)+1, tmpst2);
end


%assemble memory-less path (max over gamma, irregardless of step state)
[~, ms] = max(sum(ga,3),[],2);
mst = zeros(1,len);
%find most probable step state
for i = 1:len
    snip = squeeze(ga(i,ms(i),:));
    [~, mst(i)] = max(snip);
end
ms = ms + lb' -1;

%assign output structure

newtm.bp = newbp;
newtm.dp = newdp;

% newtm.bp = newbp;
% newtm.dp = newdp;
newtm.ds1 = newa1;
newtm.ds2 = newa2;
out.a = newtm;
out.sig = newsig;
out.pi = newpi;
out.fit = y(real(st)) + sqrt(-1) * imag(st);
out.fitmle = y(ms) + sqrt(-1) * mst;
% out.fitmle = y(ms);
out.logp = sum(log(scal2)) + log(sum(sum(al(end,:,:))));

if verbose
    %plot trace, likeliest state, vitterbi state in grey/blue/red respectively
    figure('Name', sprintf('fsHMM logp=%0.2f', out.logp)), subplot(3, 1, [1 2]), hold on
    plot(tr, 'Color', [.7 .7 .7 ])
    mesh(repmat(1:length(st), [2 1]), [y(ms); y(ms)]+1, zeros(2,len), [mst; mst] )
    mesh(repmat(1:length(st), [2 1]), repmat(y(real(st)), [2 1]), zeros(2,length(st)), repmat(imag(st), [2 1]))
    colorbar, colormap jet
    %write stats
    yl = ylim;
    yp = 0.9 * yl(2) + 0.1 * yl(1);
    text(0,yp,sprintf('[dp bp] = [%0.04f %0.04f], sig %0.2f, logp %0.2f', newtm.dp, newtm.bp, out.sig, out.logp))
    %plot a
    subplot(3, 1, 3), plot( (1:length(newtm.ds1))*binsz, newtm.ds1)
    hold on, plot( (1:length(newtm.ds2))*binsz, newtm.ds2)
    xm = find(newtm.ds1 > 1e-5, 1, 'last');
    xm2 = find(newtm.ds2 > 1e-5, 1, 'last');
    xlim([0 max(xm, xm2)*binsz])
    set(gca, 'YScale', 'log')
    %output stats to command window
    fprintf('%s took %0.2fs, logp=%0.2f\n', mfilename, toc(stT), out.logp)
end