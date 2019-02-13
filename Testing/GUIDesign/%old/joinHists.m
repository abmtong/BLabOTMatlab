function outP = joinHists(inP1, inP2)
%This is necessarily very messy, shelve for now

binsz = inP1(2,1) - inP1(1,1);
diff = round (inP1(1,1) - inP2(1,1)) / binsz;

p1stind = round(inP1(1)/binsz);
p1enind = round(inP1(end)/binsz);
p2stind = round(inP2(1)/binsz);
p2enind = round(inP2(end)/binsz);

if diff > 1e-5
    if diff > 0 %P1 > P2, P1 starts later
        en = max(p2stind, p2enind);
        len = en - p2stind + 1;
        outP = zeros(len, 3);
        outP(:,1) = linspace(p2stind:en);
        outP(