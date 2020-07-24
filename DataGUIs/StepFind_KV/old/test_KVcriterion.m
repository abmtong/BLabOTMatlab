function [outY, outX] = test_KVcriterion()
noises = [1 2 3];
len = 10000;
szs = [100 200 300];
heis = [1 5 10];

res = zeros(1,3);
noise = randn(1,len);
for i = 1:3
    base = noise*noises(2);
    baseL = base(1:szs(i)) + heis(2);
    baseR = base(szs(i)+1:end);
    res(i) = C_qe([baseL baseR]) - C_qe(baseL) - C_qe(baseR);
end
outX = noises;
outY = res;

% figure name testkvc
% plot([baseL baseR])
% line([1 len], mean([baseL baseR]) * [1 1])
% line([1 szs(2)], mean(baseL) * [1 1])
% line([szs(2)+1 len], mean(baseR) * [1 1])