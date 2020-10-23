function out = calibNP(tr, seq, mu)

%Calibrates a nanopore trace by showing a trace and its corresponding sequence. Uses DNA values as reference.

if nargin < 3
    mu = randperm(64)/64;
end

if nargin < 2
    st = randi(4,100);
    cod = 'ATGC';
    st = cod(st);
end

%From sequence, get states
st = seq2st(seq, mu);

%Solve this with FitVitterbi ...
% Hmm, the state sequence is like a thousand long, may be too long

%We're assuming that DNA signals are (mostly) similar to the RNA ones, then we can maybe do
% a search over the gamma matrix

ga = [];% Let's say we have the gamma matrix ...
seq = [];% And the sequence, in state number-order
[~, sti] = seq2st(seq);

%Hmm, so how do we solve this ... Want to minimize prod(ga) over sequence through the states
%How many paths are there? Can we brute force this? probably not - there are (Npts-2 choose Ntrns-1) paths

%  But maybe we can monte carlo guess at some:
len = length(tr);
nst = length(sti);

%Montecarlo guess
nguess = 1e4;

bestinds = [];
bestlogp = -inf;

%To get , we'll sum ln(ga)
logga = log(ga);

for i = 1:nguess
    %Get random incidies
    inds = [1 len (1+randperm(len-2, nst-1))];
    tr = ind2tra(inds, sti);
    %Get the probability
    trind = tr + (0:len-1)*len; %Get the linear index of each point: add len * (j-1) to each point
    thisp = sum(logga(trind));
%     %'Normal' way to sum this
%     thisp = 0;
%     for j = 1:len
%         thisp = thisp + logga(j, tr(j));
%     end
    if thisp > bestlogp
        bestinds = inds;
    end
end

%Alternatively, we can do K-V and place the most likely N steps, and take like the median over many traces (which is 'most likely' the right trace)

%Part 2

%Do pseudo-KV for each interior step: Find best transition between the two states

for i = 2:nst
    %Get pt before and after (i-1 and i+1)
    st = bestinds(i-1);
    en = bestinds(i+1);
    
    %Extract the two rows of ga that pertain to this state change
    pre = logga(st:en, sti(i-1));
    pos = logga(st:en, sti(i));
        
    %Find the best pt to transition
    newi = bestinds(i)-st+1; %Default to bestinds(i) if the below loop doesn't run [leave point as is]
    newp = -inf;
    for j = 2:en-st-1
        %Try placing the step at this point
        tryp = pre(1:j-1) + pos(j:end);
        if tryp > newp
            newp = tryp;
            newi = j;
        end
    end
    
    %Update index
    bestinds(i) = newi+st-1;
end








