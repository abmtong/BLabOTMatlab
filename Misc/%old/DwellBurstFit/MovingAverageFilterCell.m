function out = MovingAverageFilterCell( xData, N )
%Filters the row vector in with a moving average with window size N. The first N-1 data points will be removed.
out = cell(1,length(xData));
for i = 1:length(xData)
    xdata   = filter(ones(1, N), N, xData{i});
    out{i}   = xdata(N:end);
end