dec = 25;
int = 1;
wid = 25;
fil = @mean;

figure('Name','Filter Frameshift')
hold on
for i = int:int:dec
    plot(windowFilter(fil, guiT(i:end),wid,dec),windowFilter(fil, guiC(i:end),wid,dec))
end