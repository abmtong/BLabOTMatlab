function out = acorr2(iny)
%Try to remove edge effects by not circshifting, renormalize bc now there's less data
%kinda like cauchy-schwarz norm

iny = iny(:)'; %row vector
len = length(iny);
out = zeros(1, len);
iny2 = iny.^2;%pre-square, to avoid recalculating per iter

for i = 1:len
%     out(i) = iny(i:end)' * iny(1:end-i+1) * ( len/(len-i+1) ); %scale by length
    out(i) = iny(i:end) * iny(1:end-i+1)' / sqrt( sum( iny2(i:end)) * sum(iny2(1:end-i+1))); %scale by magnitude (A*B/sqrt A*A B*B)
end

out = out / out(1);