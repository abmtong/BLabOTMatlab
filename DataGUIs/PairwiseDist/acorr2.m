function out = acorr2(iny, method, maxlag)
%Try to remove edge effects by not circshifting, renormalize bc now there's less data
%kinda like cauchy-schwarz norm
if nargin < 2
    method = 1;
end
if nargin < 3
    maxlag = length(iny);
end

iny = iny(:)'; %row vector
len = length(iny);
out = zeros(1, maxlag);

if method == 1 %scale by norm, good
    iny2 = iny.^2;%pre-square, to avoid recalculating per iter
    for i = 1:maxlag
        out(i) = iny(i:end) * iny(1:end-i+1)' / sqrt( sum( iny2(i:end)) * sum(iny2(1:end-i+1))); %scale by magnitude (A*B/sqrt A*A B*B)
    end
elseif method == 2 %scale by length, also good
    for i = 1:maxlag
        out(i) = iny(i:end) * iny(1:end-i+1)' * ( len/(len-i+1) );
    end
else %dont scale, bad
    for i = 1:maxlag
        out(i) = iny(i:end) * iny(1:end-i+1)';% don't scale, bad
    end
end
out = out/out(1);
out(isnan(out)) = 0; %if edges of iny are 0, then out(end) will be NaN if method == 1. Just zero out instead
