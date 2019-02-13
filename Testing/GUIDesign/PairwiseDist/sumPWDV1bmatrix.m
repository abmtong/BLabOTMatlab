function sumPWDV1bmatrix(data, fils, pfils)

binsz = .1;
if nargin < 3
    pfils = [1 5 10] * .1/binsz;
    pfils = round(pfils);
end

if nargin < 2
    fils  = [10 20 30];
end


fg = figure('Name', sprintf('PWDmatrix %s', inputname(1)));
len = length(fils);
hei = length(pfils);
for i = 1:len
    for j = 1:hei
        sumPWDV1b(data, fils(i), binsz, pfils(j));
        tempfig = gcf;
        newax = copyobj(gca, fg);
        newax.Position = [(i-1)/len (j-1)/hei 1/len 1/hei];
        text(newax, newax.XLim(1), mean(newax.YLim), sprintf('[%d, %0.2f, %d]', fils(i), binsz, pfils(j)));
        xlim(newax, [0 40]);
        delete(tempfig);
    end
end