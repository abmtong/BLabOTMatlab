function out = analyzeCalibrations(inNums)
len = size(inNums,1);

aal = zeros(1,2*len);
aka = zeros(1,2*len);
bal = zeros(1,2*len);
bka = zeros(1,2*len);

for i = 1:len
    load(sprintf('C:/Data/Analysis/081717/cal081717N%02d.mat',inNums(i,1)));
    aal(2*i-1) = cal.alphaAX;
    aka(2*i-1) = cal.kappaAX;
    bal(2*i-1) = cal.alphaBX;
    bka(2*i-1) = cal.kappaBX;
    load(sprintf('C:/Data/Analysis/081717/cal081717N%02d.mat',inNums(i,2)));
    aal(2*i) = cal.alphaAX;
    aka(2*i) = cal.kappaAX;
    bal(2*i) = cal.alphaBX;
    bka(2*i) = cal.kappaBX;
end

out.aal = aal;
out.aka = aka;
out.bal = bal;
out.bka = bka;