function out = updateMuMC(raws, prev, n)

%Same as updateMu but picks RANDOMLY instead of mean/median/etc.
%The point is to, given a state spread, [do this a bunch of times], pick the best %ile, etc.

if nargin < 3
    n = 1;
end

%raws is a 1xn struct with field raw : 1x256 cell of column vectors of raw levels

ns = length(raws(1).raw);

%Concatenate and pick randomly
r = {raws.raw};
r = [r{:}];
r = reshape(r, ns, []);
out = zeros(n,ns); %Each row a different one

for i = 1:ns
    snp = r(i,:);
    snp = cellfun(@(x) x(:)', snp, 'Un', 0);
    snp = [snp{:}];
    if isempty(snp)
        if nargin >= 1
            out(:,i) = prev(i);
        else
            out(:,i) = NaN;
        end
    else
        out(:,i) = snp(randi(length(snp), n, 1)); %Roll random selections
    end
end