function out = acorr2(iny)
%Doesn't circshift the data, removing edge effects?

iny = iny(:); %column vector
len = length(iny);
out = zeros(1, len);

for i = 1:len
    out(i) = iny(i:end)' * iny(1:end-i+1) * ( len/(len-i+1) );
end

out = out / out(1);