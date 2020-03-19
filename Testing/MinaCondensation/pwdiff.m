function pwdiff(x)
%'pairwise' but for differences?
%Tallies diff between x(t) and x(t+n)

%max time offset
maxn = 100;
%max dx to keep
xlen = 100;
binsz = 1; 

out = zeros(xlen*2, maxn);

for i = 1:maxn
    tmp = x(1:end-i) - x(1+i:end);
    [~, tmpx, ~, tmpy] = nhistc(tmp, binsz);
    %Pad with +/-100 pts
    tmpx = [ ones(1, xlen) tmpx ones(1,xlen)]; %#ok<AGROW>
    tmpy = [ zeros(1, xlen) tmpy zeros(1,xlen)]; %#ok<AGROW>
    %Find where tmpx == 0
    indz = find(tmpx == binsz/2, 1);
    %Add flanking this index
    out(:,i) = tmpy(indz - xlen : indz + xlen-1);
end
x = (-maxn:maxn-1) + binsz/2;
y = 1:maxn;
figure, surf(y,x,out, 'EdgeColor', 'interp')



