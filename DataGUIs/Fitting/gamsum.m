function out = gamsum(x, ks, as)

%Sum of two gammas (N gammas?) from Moschopoulos, Ann Inst Statist Math 1985
% https://doi.org/10.1007/BF02481123
% Will try to use the same notation as in that paper, but I will use k instead of \beta

% For eventual fitting of a Gamma plus exponential, for Phage fitting

%Input: X values, k/a matrix

%Ready for >>mle(@gamexp, ...);

%Write

%Test by basic identities (sum of exps, sum of gammas with equal as, equal ks)

%{
pdf = C sum(k=0, inf) delta_k y.^(p+k-1) exp(-y/beta_1) / Gamma(p+k) / beta_1(p+k)
p = sum a's
(they use \beta instead of k)
(They normalize th ebetas by the smallest beta = beta_1  ; C = 


%}

%This is an infinite series, let's put some arbitrary upper bound (hopefully it converges before then)
maxk = 1e4; %In the paper, k is their loop variable


%Step 1: Sort by k's, make k(1) be the smallest one
[ks, si] = sort(ks);
as = as(si);

%Sum of alphas, \rho
p = sum(as);

%Normalization factor
C = prod(  arrayfun(@(k,a) (ks(1) / k)^a, ks, as) );

%\gamma as a function of k
gk = zeros(1,maxk);
for i = 1:maxk
    gk(i) = sum( arrayfun( @(k,a) a * (1-ks(1) / k)^i / i , ks, as) );
end

%\delta, a recursive infinite sum
dk = zeros(1,maxk+1); %Index here is going to be one plus the index in the paper (i.e. their dk(0) = 1; here dk(1) = 1
dk(1) = 1;
for i = 1:maxk
    dk(i+1) = 1/(i+1) * sum( (1:i) .* dk(1:i) .* fliplr( dk(1:i) ) );
end

%And PDF
len = length(x);
out = zeros(1, len);
for i = 1:len
    out(i) = C * sum( dk .* x(i) .^( p + (0:maxk) ) .* exp( - x(i) / ks(1) ) ./ gamma(p+ (0:maxk) ) ./ ks(1) .^ (p + (0:maxk)) );
end

%Something's wrong...




