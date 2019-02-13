function out = MovingAverageFilter( in, N )
%Filters the row vector in with a moving average with window size N. The first N-1 data points will be removed.
out = zeros(1,length(in)-N+1);
for i = 1:length(out)
    out(i) = sum(in(i:i+N-1))/N;
end
end