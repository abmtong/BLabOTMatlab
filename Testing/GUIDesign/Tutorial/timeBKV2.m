%batchKVtime tester
%Trace is called 'dtst';
nlen = length(dtst);
len = 30;
tims = zeros(1,len);
lens = zeros(1,len);
pipe = '|';
fprintf('[%s]\n[', pipe(ones(1, len)))
for i = 1:len
    lens(i) = nlen * i;
    trc = repmat(dtst,1,i);
    startT = tic; %Time = sum of 3 runs
    AFindStepsV4(trc, single(5), [], 0);
    AFindStepsV4(trc, single(5), [], 0);
    AFindStepsV4(trc, single(5), [], 0);
    tims(i) = toc(startT);
    fprintf('|')
end
fprintf(']')

figure('Name', 'x v y')
plot(lens, tims);
hold on