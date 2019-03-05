function [out, outfs] = calcVelocity(incell, maxsz, incellf)
%input: cell of things to linfit
%output: velocities, as a cell of arrays
%averages incellf (to get e.g. avg force) over the velocity region, outputs as similar to output

%consider using @phagepause instead (sgfilters whole trace, plots vel. dist



%could rewrite this as "does @fun to incell{i} chopped up into maxsz bits" - just change @polyfit to something generic

if nargin < 2
    maxsz = inf;
end

len = length(incell);
out = cell(1,len);
if nargin > 2 && nargout > 1
    outfs = cell(1,len);
end
for i = 1:len
    con = incell{i};
    n = length(con);
    if isinf(maxsz)
        tmp = polyfit(1:n, con, 1);
        out{i} = tmp(1);
    else
        m = floor(n/maxsz); %divide into m parts
        tmpout = zeros(1,m);
        if nargin > 2 && nargout > 1
            tmpoutf = zeros(1,m);
        end
        for j = 1:m
            cs = con( (j-1) * maxsz + 1 : j * maxsz );
            tmp = polyfit(1:maxsz, cs, 1);
            tmpout(j) = tmp(1);
            if nargin > 2 && nargout > 1
                tmpoutf(j) = mean( incellf{i}( (j-1) * maxsz + 1 : j * maxsz ));
            end
        end
        out{i} = tmpout;
        if nargin > 2 && nargout > 1
            outfs{i} = tmpoutf;
        end
    end
end


