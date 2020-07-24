%batchKVtime tester
nam = 'd2F';
len = 10;
tims = zeros(1,len);
lens = zeros(1,len);

for i = 1:len
    lens(i) = eval(sprintf('sum(cellfun(@length, %s%d));', nam, i));
    tims(i) = eval(sprintf('timeit(@()BatchKV(%s%d));', nam, i));
    close all
end

figure('Name', 'x v y')
plot(lens, tims);
hold on
plot(lens .* log(lens), tims);

%Should theoretically be O(n), and might actually be O(n)