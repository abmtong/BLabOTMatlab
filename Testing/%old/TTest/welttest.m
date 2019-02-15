function [p, t, df]= welttest( meanx, meany, sdx, sdy, nx, ny)

t = (meanx-meany) / sqrt(sdx^2/nx + sdy^2/ny);

df = (sdx^2/nx + sdy^2/ny)^2 / ((sdx^4/nx^2/(nx-1) + sdy^4/ny^2/(ny-1)));
p = 2*tcdf(-abs(t),df);