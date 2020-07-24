function TetherSim_phagedbl()

opts = [];

con1 = 1e4;
con2 = 1200;
dcon = 1;
n = 100;

opts.ext1 = 1300;
opts.ext2 = 1300;
opts.dext = 1;
opts.verbose = 0;

outex = zeros(1,n);
outfr = zeros(1,n);
for i = 1:n
    opts.tcontour1 = con1;
    opts.tcontour2 = con2;
    [outfr(i), outex(i)] = TetherSim_double(opts); %ok this is very poor bc xwlc g
    con1 = con1 - dcon;
    con2 = con2 - dcon;
end
figure, subplot(2,1,1), plot(outfr,'o'), subplot(2,1,2), plot(outex,'o')