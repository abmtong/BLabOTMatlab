function out = kinNumIntV2(x0, k, dt, nT)

%{
Inputs:
x0, the starting values. Keep in mind the order of the species
k, a struct of the rates:
  For a given order of reaction N products > M reactants (all unique):
   Call the fieldname kN_M, and make it a (N+M)-dimension array
   This rate is k(reactant 1, reactant 2, ... reactant N, prod 1, prod 2, ... prod M)

%Does not handle A + A > B, though could maybe be handled by A1 + A2 > B , A1 <-> A2 fast

%}

if nargin < 4
    nT = 1e4;
end

if nargin < 3
    dt = 1e-3;
end


wid = length(x0);

out = zeros(nT, wid);
out(1,:) = x0;

if ~isstruct(k)
    %Assume it's a 2>2
    if length(size(k)) == 2
        k.k1_1 = k;
    end
end

%Scan fieldnames for n products and n reactants
fns = fieldnames(k);
nK = length(fns);
[st, en] = regexp(fns, '\d*');
nR = cellfun(@(x,y,z) str2double(x(y(1):z(1))), fns, st, en);
nP = cellfun(@(x,y,z) str2double(x(y(2):z(2))), fns, st, en);

%Make sure length(size(k)) == nR + nP
nRP = structfun(@(x) length(size(x)), k);

notok = find( ~(nR+nP == nRP));
assert( isempty(notok) , 'K matricies %s are of wrong dimension', sprintf('%s,', fns(notok)) )


for i = 2:nT
    tprev = out(i-1,:);
    for j = 1:nK
        r = nR(j);
%         p = nP(j);
        rp = nRP(j);
        tmp = k.(fns{j});
        %bsxfun out(i-1,:) with kR_P R times, with out(i-1,:) reshaped to be along dim 1 to dim R
        for k = 1:r
            tmp = bsxfun(@times, tmp, reshape(tprev, [zeros(1,k-1) wid]));
        end
        %Incorporate dt here
        tmp = tmp * dt;
        %Then, sum across all dimensions except dim 1 to R (get R row vectors) to get usages
        for k = 1:r
            out(i,:) = out(i,:) - sumall(tmp, k);
        end
        %Sum across all dimensions except R+1 to R+P to get makings ; update out
        for k = r+1:rp
            out(i,:) = out(i,:) + sumall(tmp, k);
        end    
    end
end

function out = sumall(mtr, xdim)
%Sum over dims 1-dimmx but not xdim
%Returns a row vector
for ii = length(size(mtr)):-1:1 %Order shouldn't matter, but high-to-low will give less squeezing
    if ii == xdim
        continue
    end
    mtr = sum(mtr, ii); %Go hi > low
end
out = squeeze(mtr);
out = out(:)';
end

figure, plot(out);
end