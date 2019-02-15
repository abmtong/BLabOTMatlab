function out = compareNoise
% compareNoise from different bits

bits = [14 16 18];
n = 1e7;
len = length(bits);
out = zeros(1, len);
rng = randn(1,n);
for i = 1:len
dat = round(rng*2^bits(i)) ./ 2^bits(i);
out(i) = std(dat);
end

out = (out/out(1))-1;

fprintf('Bits: ')
fprintf('%d ', bits)
fprintf('\nRel. Noises: ')
fprintf('%0.6e ', out)
fprintf('\n')