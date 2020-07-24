function out = subdiff(n, k)

%ghetto subdiffusive behavior by having regular brownian motion smoothed to make dx's correlated

%nargout = 0 to plot MSD, to see the non-linearity (compare to subdiff(n, 1))

if nargin < 1
    n = 1e4;
end

if nargin < 2
    k = 100;
end

out = diff(smooth( cumsum(randn(1, n+1)) , k )');

if nargout < 1
    figure, loglog( msd( cumsum( out) ), 'o' )
end