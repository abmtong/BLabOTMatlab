function out = acorr(iny)
iny = iny(:); %column vector
len = length(iny);
out = zeros(1, len);

for i = 1:len
    out(i) = circshift(iny, i-1)' * iny;
end

out = out / out(1);