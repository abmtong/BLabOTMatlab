
filter = @median;
w = 0:7;
d = 1:3;

data = zeros(length(w),length(d),2);

for i = 1:length(w)
    for j = 1:length(d)
        trace = windowFilter(filter, guiC, w(i), d(j));
        [inds, means] = AFindSteps(trace);
        data(i,j,1) = length(inds) - 1;
        data(i,j,2) = means(1) - means(end);
    end
end