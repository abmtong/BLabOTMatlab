function dat = testallcactuars()

%Fuse a KMM into itself until it hits max (4.5M XP)
%Test every permutation, assume 90/9/1 regular/great/amazing rate

%Do this recursively, I guess?

function out = fuse(curxp, history)
    if curxp > 45e5
        out = [];
        return
    end
    %regular
    reg = fuse(curxp + 1e5, [history .9]);
    %great
    gr = fuse(curxp * 1.5 + 1e5, [history .09]);
    %amazing
    am = fuse(curxp * 2 + 1e5, [history, .01]);
    
    outstr.xp = curxp;
    outstr.hst = history;
    outstr.len = length(history);
    outstr.prob = prod(history);
    outstr.rate = outstr.xp/outstr.len;
    out = [reg gr am outstr];
end

dat = fuse(1e5, 1);

rts = [dat.rate];
xps = [dat.xp];



%find best XP to stop at, by finding average rate at each XP weighted by probability, then go once more
U = unique(xps);
len = length(U);
avgr = zeros(1,len);
for i = 1:len
    snip = dat(U(i) == xps);
    ps = [snip.prob];
    rts = [snip.rate];
    avgr(i) = rts * ps' / sum(ps);
end

%plot rates at a given XP amount
figure, plot(U, avgr), hold on, plot(U, smooth(avgr, 10))

%if we fused one more time at a given xp, what's the expected xp?
    function xp = xpmult(curxp)
        gr = min(curxp*1.5, 45e5);
        am = min(curxp * 2, 45e5);
        xp = curxp * .9 + gr *.09 + am *.01 + 1e5;
    end
%XP per cactuar of the next cactuar
plot(U, xpmult(U)-U)

%smooth by binning instead
V = (2:45)*1e5;
avgrbin = zeros(1,44);
for i = 1:44
    snip = dat( V(i) > xps & V(i)-1e5 <= xps );
    ps = [snip.prob];
    rts = [snip.rate];
    avgrbin(i) = rts * ps' / sum(ps);
end
figure, plot(V, avgrbin), hold on,
plot(V, xpmult(V)-V)

%Point to stop is at the intersection of the [rate till now] and the [rate of next cactuar] lines
%Seems to be around 4M XP


end