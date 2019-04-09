function st = findStepHMMV1c_ccode_vitterbi(tr, a, y, sig, lb2, ub2, wid2, maxwid2)

len = length(tr);
lena  = length(a);
hei = length(y);

vitdp = zeros(len-1, maxwid2); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
vitsc = normpdf(y, tr(1), sig).^2;
for t = 1:len-1
    tvitsc = zeros(1, wid2(t));
    tvitdp = zeros(1, wid2(t));
    for j = 1:wid2(t)
        tmp = zeros(1, wid2(t));
        for i = 1:wid2(t)
            ind = j - i + 1;
            if ind >= 1 && ind <= lena
                tmp(i) = a(ind) * vitsc(i) * ;
            end
        end
        [tvitsc(j), tvitdp(j)] = max(tmp);
    end
    vitsc = zeros(1,hei);
    vitsc(lb2(t):ub2(t)) = tvitsc;
    vitdp(t, 1:wid2(t)) = tvitdp + lb2(t) -1;
    vitsc = vitsc .* normpdf(y, tr(t+1), sig) / sum(vitsc); %renormalize, apply score
end

%assemble path via backtracking
st = zeros(1,len);
[~, st(len)] = max(vitsc);
for t = len-1:-1:1
    st(t) = vitdp(t,st(t+1)-lb2(t)+1);
end