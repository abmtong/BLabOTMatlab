function out = calcVelocity(incell, maxsz)
%input: cell of things
%output: velocities, as a cell of matricies

if nargin < 2
    maxsz = inf;
end

len = length(incell);
out = cell(1,len);
for i = 1:len
    con = incell{i};
    n = length(con);
    if isinf(maxsz)
        tmp = polyfit(1:n, con, 1);
        out{i} = tmp(1);
    else
        m = floor(n/maxsz); %divide into m parts
        tmpout = zeros(1,m);
        for j = 1:m
            cs = con( (j-1) * maxsz + 1 : j * maxsz );
            tmp = polyfit(1:maxsz, cs, 1);
            tmpout(j) = tmp(1);
        end
        out{i} = tmpout;
    end
end


