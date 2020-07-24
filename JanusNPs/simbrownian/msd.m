function out = msd(x)
len = floor(length(x)/2);
out = zeros(1,len);
for i = 1:len
    out(i) = mean( (x(1:end-i) - x(1+i:end) ).^2 );
end 