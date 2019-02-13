function [beadPos, history] = fsh8_sub1v2 (i, hei, a, histlen, dS)
tmin = max(1,i-histlen+1);
history = zeros(hei, i-tmin+1);
a = a';
    %Fetch optimal path to a(j)
    history(:,1) = 1:hei;
    index = 1;
    for k = i-1:-1:tmin
        history(:,index+1) = dS(k, history(:,index));
        index = index + 1;
    end
    beadPos = sum(a(history), 2);