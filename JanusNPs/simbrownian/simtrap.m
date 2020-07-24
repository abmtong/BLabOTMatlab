function out = simtrap(noi, k)

%takes in array of noise, and trap spring constant k [technically k/g*dt, whatever proportionality factor between position and motion]

if nargin < 2
    k = 0.1;
end

if nargin < 1
    noi = randn(1,1e4);
end


len = length(noi);

out = zeros(1,len);

for i = 2:len
    out(i) = out(i-1) - out(i-1)*k + noi(i);
end
