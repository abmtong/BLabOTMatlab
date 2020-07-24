function out = DecimatePrimitive(in, N)
%'Decimates' a function by taking every N. None of this fancy low pass stuff.
len = floor(length(in)/N);
out = zeros(1,len);
for i = 1:len
    out(i) = mean(in(N*i:N*i+N-1));
end
end
