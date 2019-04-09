function xi = findStepHMMV1c_ccode_xi(tr, al, a, y, be, lb, ub, wid, sig)

%len = length(tr)
len = length(tr);
%lena = length(a)
lena = length(a);
%hei = length(y)
hei = length(y);

% xi = zeros(1, lena);
xi = zeros(1, lena);
% tempal = zeros(1,hei);
tempal = zeros(1,hei);
% tempbe = zeros(1,hei);
tempbe = zeros(1,hei);
% for t = 1:len-1
for t = 1:len-1
    %extract full alpha
    tempal = 0*tempal;
    tempal(lb(t):ub(t)) = al(t,1:wid(t));
    %extract full beta
    tempbe = 0*tempbe;
    tempbe(lb(t+1):ub(t+1)) = be(t+1,1:wid(t+1));
    %make full b
    tempb = normpdf(y, tr(t+1), sig);
    %make tempxi
    tempxi = zeros(1,lena);
    %for i = lb(t):ub(t)
    for i = lb(t):ub(t)
%         for j = lb(t+1):ub(t+1)
        for j = lb(t+1):ub(t+1)
            ind = j - i + 1;
            if ind > 0 && ind <= lena
                tempxi(ind) = tempxi(ind) + tempal(i) * a(ind) * tempb(j) * tempbe(j);
            end
        end
    end
%     xi = xi + tempxi / sum(tempxi);
    xi = xi + tempxi / sum(tempxi);
end