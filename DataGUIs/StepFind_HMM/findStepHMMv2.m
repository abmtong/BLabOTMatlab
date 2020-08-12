function [out, tfconv] = findStepHMMv2(inOpts)
%Fits a HMM that models a staircase
%Input either a trace or output of this fcn
%v2: out is like inOpts

%% Check if input is opts or trace
if nargin && isstruct(inOpts)
    passedOpts = 1;
else
    passedOpts = 0;
end

%% Set default options
opts.verbose = 1;
opts.binsz = 0.1;
opts.maxstep = 15; %for transition matrix
opts.vitfit = 1; %Whether or not to vitterbi fit: can ~1.5x spd if we skip it
%Update binsz if supplied
if passedOpts
    opts = handleOpts(opts, inOpts);
end
%Extract for ease of referencing
binsz = opts.binsz;

%% Handle input data
if nargin < 1
    %Example trace: 3+1 step
    sd = 2;
    inTrace = [zeros(1,200) ones(1,100)*2.5 ones(1,100)*5 ones(1,100)*7.5 ones(1,100)*8.6];
    inTrace = [inTrace inTrace + 8.6 inTrace + 15];
    inTrace = inTrace + sd*randn(1,length(inTrace))+25;
elseif passedOpts
    inTrace = inOpts.tr;
else
    inTrace = inOpts;
end
%Check if input is an array or struct
tr = double(inTrace(:)'); %Make double, row vector
len = length(tr);

%Define state grid
yimin = floor(min(tr)/binsz);
yimax = ceil(max(tr)/binsz);
y = (yimin:yimax) * binsz;
hei = length(y);

%% Set default model
%Step size probability
opts.a = ones(1,1+2*opts.maxstep/opts.binsz);
opts.a((end+1)/2) = 1e4;
opts.a = opts.a/sum(opts.a);
%Noise
opts.sig = sqrt(estimateNoise(tr));
opts.pi = normpdf(y, tr(1), opts.sig);
opts.logp = -inf;
opts.fitmle = [];
opts.fit = [];

%If a model is supplied, apply it
if passedOpts
    opts = handleOpts(opts, inOpts);
end

%Extract model params, for easier use + to preserve initial params
a = opts.a;
lena = length(a);
sig = opts.sig;
pi = opts.pi;

%To measure time
stT = tic;
%Midpt is at a(ahalf+1)
ahalf = (length(a)-1)/2;

%Define upper, lower bdys [slice of states we need to consider at each pt]
maxdif = max(abs(diff(tr)));
maxdif = max(maxdif, length(a)*binsz);
ub = min( ceil((tr+maxdif-yimin*binsz+1)/binsz), hei);
lb = max(floor((tr-maxdif-yimin*binsz+1)/binsz), 1);
wid = ub-lb+1;
widmx = max(wid);

%% Calculate
%Calculate alpha ('forward variable')
al = zeros(len,widmx);
scal = zeros(len,1); %Scale factor, to prevent underflow
npdf2 = @(ind) normpdf(y, tr(ind), sig); %Shortcut
altemp = pi .* npdf2(1);
al(1,1:wid(1)) = altemp(lb(1):ub(1));
scal(1) = sum(al(1,:));
al(1,:) = al(1,:)/scal(1);
for i = 2:len
    %al(y,t) = al(y,t-1) conv a * normpdf
    altemp = conv(altemp, a); %alpha(t-1)
    altemp = altemp(ahalf+1:ahalf+hei) .* npdf2(i);
    al(i,1:wid(i)) = altemp(lb(i):ub(i));
    scal(i) = sum(al(i,:)); %Normalize to 1, store in scal
    al(i,:) = al(i,:)/scal(i);
    altemp = altemp / scal(i);
end

%Calculate beta ('reverse variable')
be = zeros(len,widmx);
betemp = ones(1,hei)/scal(len);
be(len,1:wid(len)) = betemp(lb(len):ub(len));
for i = len-1:-1:1
    %be(y,t) = be(y,t+1) * normpdf conv a
    betemp = conv(betemp.*npdf2(i+1), a(end:-1:1));
    betemp = betemp(end-hei-ahalf+1:end-ahalf) / scal(i); %Use same normalization as in alpha
    be(i,1:wid(i)) = betemp(lb(i):ub(i));
end

%Calculate gamma (the probability of being at each state)
ga = al .* be;
ga = bsxfun(@rdivide, ga, sum(ga,2));

%Calculate xi (the probability of transitioning between two states)
%Make new lb/ub which is the extermer of the two of i and i+1, since we need to consider both times now
lb2 = min( [lb(1:end-1); lb(2:end)] , [] , 1);
ub2 = max( [ub(1:end-1); ub(2:end)] , [] , 1);
wid2 = ub2-lb2+1;
maxwid2 = max(wid2);
%Make 2d a
widaa = min(hei, ahalf);
aa = spdiags( repmat(a, hei, 1), -widaa:widaa , hei, hei);
xi = zeros(hei);
for i = 1:len-1
    %Extract full alpha, beta, as sparse
    tempal = sparse(ones(1, wid(i)), lb(i):ub(i), al(i,1:wid(i)), 1, hei);
    tempbe = sparse(ones(1, wid(i+1)), lb(i+1):ub(i+1), be(i+1, 1:wid(i+1)), 1, hei);
    %xi(i,j) = al(i) * be(j) * normpdf(j) * a(j-i)
    tempxi = aa .* bsxfun(@times, tempal.',tempbe .* npdf2(i+1));
    %Extract the square as defined by lb/ub
    txi = full(tempxi(lb(i):ub(i), lb(i):ub(i)));
    %Add to xi. Sum along time, since we assume time-independent a
    xi(1:wid(i), 1:wid(i)) = xi(1:wid(i), 1:wid(i)) + txi/sum(txi(:));
end

%% Calculate new model
%New pi
newpi = zeros(1,hei);
newpi(lb(1):ub(1)) = ga(1,1:wid(1));

%New a
newa = zeros(size(a));
[B, d] = spdiags(xi);
B = sum(B,1);
for j = 1:length(d)
    newa(d(j)+ahalf+1) = newa(d(j)+ahalf+1) + B(j);
end
newa = newa/sum(newa);

%New sig
newsig = zeros(1,len);
for i = 1:len
    newsig(i) = sum( ga(i,1:wid(i)) .* (tr(i) - y(lb(i):ub(i))).^2 );
end
newsig = sqrt(sum(newsig)/(length(newsig)-1));

%% Find most probable path using vitterbi algorithm
% Only fit if asked for
if opts.vitfit
    %Make a into a matrix
    widaa = min(maxwid2, (lena-1)/2);
    aa = spdiags( repmat(newa(ahalf+1+(-widaa:widaa)) , maxwid2, 1), -widaa:widaa, maxwid2, maxwid2);
    %Save most probable sub-paths: vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
    vitdp = zeros(len-1, maxwid2);
    vitsc = npdf2(1).^2; %Keep track of score
    for i = 1:len-1
        [tvitsc, tvitdp] = max(bsxfun(@times, aa(1:wid2(i),1:wid2(i)), vitsc(lb2(i):ub2(i))'), [], 1);
        vitsc = zeros(1,hei);
        vitsc(lb2(i):ub2(i)) = tvitsc;
        vitdp(i, 1:wid2(i)) = tvitdp + lb2(i) -1;
        vitsc = vitsc .* npdf2(i+1) / sum(vitsc); %Renormalize, apply score
    end
    %Assemble path via backtracking
    st = zeros(1,len);
    [~, st(len)] = max(vitsc); %Start from the most probable endpoint...
    for i = len-1:-1:1
        st(i) = vitdp(i,st(i+1)-lb2(i)+1); %And find the most probable previous point
    end
else
    st =[];
end

%% Calculate MLE fit (most probable state at each point)
[~, ms] = max(ga,[],2);
ms = ms + lb' -1;

%% Assign output structure
%Start with input
out = opts;
out.tr = tr;
%Keep a copy of the old ones
out.old.a = a;
out.old.sig = sig;
out.old.pi = pi;
out.old.fit = out.fit;
out.old.fitmle = out.fitmle;
out.old.logp = out.logp;
%Assign new ones
out.a = newa;
out.sig = newsig;
out.pi = newpi;
out.fit = y(st);
out.fitmle = y(ms);
out.logp = sum(log(scal)) + log(sum(al(end,:)));
%Check for convergence
tfconv = out.old.logp > out.logp;
if tfconv
    convmsg = ', converged';
else
    convmsg = '';
end

%% Verbose options
if opts.verbose == 1
    %Plot trace, likeliest state, vitterbi state in grey/blue/red respectively
    figure,subplot(3, 1, [1 2]), hold on
    plot(tr, 'Color', [.7 .7 .7 ])
    plot(y(ms), 'Color', 'b')
    plot(y(st), 'Color', 'r')
    %Write stats
    yl = ylim;
    yp = 0.9 * yl(2) + 0.1 * yl(1);
    text(0,yp,sprintf('trnsprb %0.04f, sig %0.2f, logp %0.2f', 1-newa(ahalf+1), out.sig, out.logp))
    %plot a
    plota = newa;
    plota(ahalf+1)=0;
    subplot(3, 1, 3), plot( -opts.maxstep:binsz:opts.maxstep, plota)
    %output stats to command window
    fprintf('%s took %0.2fs, logp=%0.4f%s\n', mfilename, toc(stT), out.logp, convmsg)
elseif opts.verbose == 2 %Just plot command line update
    fprintf('%s took %0.2fs, logp=%0.4f%s\n', mfilename, toc(stT), out.logp, convmsg)
end