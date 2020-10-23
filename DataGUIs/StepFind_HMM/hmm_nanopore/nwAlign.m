function out = nwAlign(seq1, seq2, sd, verbose)
%Does alingment using a 'Needleman-Welch'--like algorithm like in Laszlo et al

%Uses sequence 1 as the 'main sequence'
if nargin < 3
    sd = 2;
end

if nargin < 4
    verbose = 1;
end

%Penalty matrix. 
penmtr = [10 5 1 0 3 10]; %Penalty for Back2, Back1, Down, Fwd, Skip1, Skip2 transitions

%Similarity matrix. We'll use Z-score
simmtr = abs(bsxfun(@minus, seq1(:), seq2(:)'))/sd;


% So how should we go about doing this? Want to draw a line from UL to LR
% Because of alignment, we're fairly certain about first few nt. 

wid = length(seq2);
hei = length(seq1);

pos = 0;
len = length(seq1);
res = zeros(1,len);
%Here we start at '0,0'
for i = 1:len
    %Scores, in order [Back2 Back1 Down Fwd Skip1 Skip2]
    scr = inf(1,6);
    
    %Get scores by looking at this row
    rng = pos + (-2:3);
    %Deal with out-of-bounds areas
    stI = find(rng >= 1, 1, 'first');
    enI = find(rng <= wid, 1, 'last');

    %Get the scores, add penalties
    scr(stI:enI) = simmtr(i, rng(stI:enI)) + penmtr(stI:enI);
    
    %Take the best one
    [~, besti] = min(scr);
    
    %Update
    res(i) = rng(besti);
    pos = res(i);
end

%Maybe instead do it like Vitterbi, using simmtr as score
%% Assign the path via Vitterbi

%Initial state guess
pi = inf(1,wid);
pi(1:3) = penmtr(4:6);
%Place to save vitterbi paths
vitdp = zeros(len-1, ns); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
%Vitterbi score (probability)
vitsc = pi;
for i = 1:len-1
    %Calculate proposed paths, take best
    [tsc, tvitdp] = max( bsxfun( @times, a, vitsc'), [], 1); %% IN PROGRESS
    %Apply score, apply npdf, renormalize
    vitsc = tsc .* npdf(i+1) / sum(tsc);
    %Save best paths
    vitdp(i, :) = tvitdp;
end
%Assemble path via backtracking
st = zeros(1,len);
[~, st(len)] = max(vitsc);
for i = len-1:-1:1
    st(i) = vitdp(i,st(i+1));
end

%Plot
figure, hold on
if verbose
    %Plot matrix of scores. Just do text for now, instead of surf
%     for i = 1:wid
%         for j = 1:hei
%             text(i, j, sprintf('%0.2f', simmtr(j,i)));
%         end
%     end
    [xx, yy] = meshgrid((1:wid)-.5, (1:hei)-.5);
    surf(xx, yy, simmtr);
    %Plot line through
    plot3(res, 1:len, max(max(simmtr))*1.1*ones(1,len), 'LineWidth', 2)
end





