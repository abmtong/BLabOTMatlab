function [p, t, df] = stuttest( meanx, meany, sdx, sdy, nx, ny, sdxy)
if nargin<7
    sdxy = sqrt( ((nx-1)*sdx^2 + (ny-1)*sdy^2) / (nx+ny-2) );
end

t = (meanx-meany) / sdxy / sqrt(1/nx + 1/ny);
df = nx+ny-2;

p = 2*tcdf(-abs(t),df);
