function [outp, outraw] = randomCheck_bstrap(seq)
%Checks randomness of a sequence of integers by runs analysis
% Inspired by Wald-Wolfowitz runs test, expanded to more integers via resampling
%  The W-W test does have numerical solutions for greater N, but this is easier (to write, but slower execution)
% Computes empirical [mean, sd] of the number of runs of the resampled sequences, returns P-value


method = 2; %Generating new samples via (1) permutation or (2) resampling with replacement (traditional bootstrapping)

nstrap = 1e4; %Simulate 1e4 bootstraps
% nstrap = min(max(1e4, length(seq)*10), 1e5); %Simulate 1e4 to 1e5 boostraps
%Calculate run lengths
in = tra2ind(seq);
nruns = length(in) - 1;

%Simulate random ordering and count runs
nbs = zeros(1,nstrap);
for i = 1:nstrap
    switch method
        case 1 %No replacement, just reordering (permutation test)
            nbs(i) = length( tra2ind( seq( randperm(length(seq)) ) ) ) - 1;
        case 2 %Resampling with replacement (bootstrappping)
            nbs(i) = length( tra2ind( seq( randi(length(seq), 1, length(seq)) ) ) ) - 1;
        case 3 %Distribution of diff(x)
            
    end
end %Permutation and bootstrapping seem to be similar ?

%Can either get the percentile or calculate mean/sd. Former seems better? Distributions seem gaussian enough, though so probably no issue

%Calculate percentile
pct = sum(nbs <= nruns) / length(nbs);

%Convert to two-tailed
outp = 2 * min(pct, 1-pct);

%if pct == 0, outside of nstrap: assume gaussian and calculate p, warn for
if pct == 0
    mu = mean(nbs);
    sd = std(nbs);
    
    zscr = (mu - nruns) / sd;
    
    % Calculate p value from Z-score (two-tailed)
    outp = normcdf( - abs(zscr) , 0, 1) *2;
    warning('Input case too rare to be found via bootstrapping, either use p from extrapolation (%04g) or nboot (<%04g)', outp, 1/nstrap)
end

% mu = mean(nbs);
% sd = std(nbs);
% 
% zscr = (mu - nruns) / sd;

%Calculate p value from Z-score (two-tailed)
% outp = normcdf( - abs(zscr) , 0, 1) *2;

%Assign outraw
outraw.p = outp;
outraw.nruns = nruns;
outraw.nboot = nbs;

%To compare two, maybe use sd from bootstrap, but the mean from the actual run

