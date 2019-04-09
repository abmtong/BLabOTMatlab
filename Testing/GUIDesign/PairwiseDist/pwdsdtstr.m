function pwdsdtstr()

stme = 10;
stsd = 0;
stnoi = 5;
nstep = 20;
smfact = 100;

dwme = 50;

sts = randn(1,nstep) * stsd + stme;

dws = exprnd(dwme, 5, nstep);
dws = sum(dws, 1);
dws = round(dws);

tr = arrayfun(@(x,y) ones(1,x) * y, dws, cumsum(sts), 'uni', 0);
tr = [tr{:}];
tr = smooth(tr, smfact);

sumPWDV1b({tr})