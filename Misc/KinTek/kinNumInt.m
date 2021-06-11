function out = kinNumInt(x0, k1, k2, dt, nT)

%{
Inputs:
x0, the starting values. Keep in mind the order of the species
k-matricies:
k1: Single-order rate constants: k1(i,j) = k(ith -> jth species)
k2: Second-order rate constants: k2(i,j,k) = k(ith + jth -> kth species)
    Dont have a way to do i > j + k or others

%Maybe could make a generic struct k, with fieldnames k(Nin_Mout)
% Appearances are summed over the first N dimensions, usages are summed over last M dims

%}

if nargin < 5
    nT = 1e4;
end

if nargin < 4
    dt = 1e-3;
end


wid = length(x0);

out = zeros(nT, wid);
out(1,:) = x0;

if nargin < 3 || isempty(k2)
    k2 = zeros(wid,wid,wid);
end

if nargin < 2 || isempty(k1)
    k1 = zeros(wid,wid);
end

for i = 2:nT
    %Multiply k1-matrix by previous amounts to get matrix of dX's
    tmp = bsxfun(@times, out(i-1,:)', k1);
    %Sum across rows to get amount used of each, sum across cols to get amount created
    
    %Multiply k2-matrix by previous amts
    tmp2 = bsxfun(@times, bsxfun(@times, out(i-1,:), k2), out(i-1,:)');
    %Sum across dim 1,2 to get usage, across 3 to get formation
    
    out(i,:) = out(i-1,:) + (sum(tmp, 1) - sum(tmp, 2)' ) * dt + ...
        (- sum(sum(tmp2, 3), 2)' - sum(sum(tmp2, 3), 1) + squeeze(sum(sum(tmp2, 1), 2))') * dt;
    
    
end

% figure, plot(out);