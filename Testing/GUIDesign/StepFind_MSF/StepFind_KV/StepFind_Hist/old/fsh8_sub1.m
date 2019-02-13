function [beadPos, history] = fsh8_sub1 (i, hei, a, histlen, dS)
    beadPos = zeros(1,hei);
    tmin = max(1,i-histlen+1);
    history = zeros(1, i-tmin+1);
    for j = 1:length(beadPos);
        %Fetch optimal path to a(j)
        history(1) = j;
        index = 1;
        for k = i-1:-1:tmin
            history(index+1) = dS(k, history(index));
            index = index + 1;
        end
        beadPos(j) = sum(a(history));
    end