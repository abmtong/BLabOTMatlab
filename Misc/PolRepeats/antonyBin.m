function [y, x] = antonyBin(iny, binsz)

%Bins by drawing a segment between adjacent points, and this segment is what gets binned
% Useful(?) for having a tiny binsize but you dont want zero bins (e.g. if you're going to take the log of the count)
% Maybe you could linear interp at ~10-100x and then bin that instead?

%Create bins
x = (floor(min(iny)/binsz):ceil(max(iny)/binsz)) * binsz;

%Easier if we have these offset xs
xlo = x(1:end-1);
xhi = x(2:end);

%Store result in y
y = zeros(size(xlo));


for i = 2:length(iny);
    %Get segment index. Helpful if these are sorted, so do so
    tmp = sort(iny(i-1:i));
    lo = tmp(1);
    hi = tmp(2);
    %Handle if lo == hi
    if lo == hi
        %Add one to this bin
        ind = find( xlo <= lo, 1, 'last' );
        y(ind) = y(ind)+1;
        continue
    end
    %Create this vector f(z) = [binsz binsz binsz binsz ... mod(z,binsz), 0 0 0]; where f(i) is the bin where x is 'in'
    flo = min(max(xlo, lo), xhi) - xlo;
    fhi = min(max(xlo, hi), xhi) - xlo;
    
    %Then ( f(hi) - f(lo) ) / (f(hi) - f(lo)) is the binning to add
    y = y + (fhi - flo) / sum(fhi - flo);
end
x = (xhi + xlo) /2;