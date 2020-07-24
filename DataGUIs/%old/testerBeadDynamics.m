%guiC is the contour
range = 5:40;
tot = zeros(1,range(end));
for dec = range

fil2 = round(100/dec);

cf = windowFilter(@mean, guiC, floor(dec/2), dec);

[~,~,tr] = findStepHistV7d(cf);

dQ = zeros(1,10);
for i = 1:10
    dQ(i) = sum ( ( cf - windowFilter(@mean, tr, i) ).^2 );
end
[~, ind] = min(dQ);
tot(dec) = ind * dec;

trf = windowFilter(@mean, tr, fil2);
trf2 = windowFilter(@mean, tr, ind);
figure; plot(cf), hold on, plot(trf),plot(trf2), hold off

end
tot