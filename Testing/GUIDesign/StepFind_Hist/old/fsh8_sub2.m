function Q = fsh8_sub2 (hei, beadPos, a, history, con)
Q  = zeros(hei);
l = length(history);

for j = 1:hei
    for k = 1:hei
        Q(j,k) = ((beadPos(j) + a(k))/(l+1) - con)^2; 
    end
end