function outscale = scalecontour(inTim, inCon, dt, mirexts, wlcparams)

%wlcparams should be [mean force, p.len, s.mod] 
if nargin < 4
    wlcparams = [45 50 700];
end
if length(wlcparams) ~= 3
    error('wlcparams needs to be [force pl sm]')
end
        
if nargin < 3
    error('need more params')
end

slp = polyfit(inTim, inCon, 1);

%dconreal = nm/bp * avg spd (bp/s) * time(s)
dconreal = .34 * -slp(1) * dt; 

%pass two mirexts or three
%dcontheo = mirext(nm) / XWLC(xpL)
dcontheo = mean(-diff(mirexts)) / XWLC(wlcparams(1), wlcparams(2), wlcparams(3));

%scale the by theo over real
outscale = dcontheo / dconreal;