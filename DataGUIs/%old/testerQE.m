%As expected, any partitioning will reduce QE

a = randn(1,10000);
b = zeros(1,10000);

for i = 1:10000
    b(i) = C_qe(a(1:i-1)) + C_qe(a(i:end));
end

plot(b - b(1))