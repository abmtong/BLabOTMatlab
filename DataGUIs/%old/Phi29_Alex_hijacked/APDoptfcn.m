function rsd = APDoptfcn(x0, lsrdata, mirdata, caldata, vtind, opts)

%x0 = [rA, rB];
%lsrdata = [AX AY BX BY] nx4
%mirdata = [MX MY] nx2
%caldata = [Fc, D] x [AX AY BX BY], = [cal.AX.fit(1:2); ...]
%vtind = [indsta indend]; nx2
%opts = others, in struct.


%Calculate a, k
a = zeros(1,4);
k = zeros(1,4);
r = [x0(1) x0 x0(2)]; %x0([ 1 1 2 2 ]);
for i = 1:4
    dC = 6*pi*opts.wV*r(i);
    D = opts.kT/dC;
    a(i) = sqrt(D/caldata(i,2));
    k(i) = 2*pi*dC*caldata(i,1);
end

%Calc F, X

bexts = bsxfun(@times, lsrdata, a);
frcs = bsxfun(@times, bexts, k);

%Calculate extension  = hypot( TrapX + BeadsX , TrapY + BeadsY) - Bead Radii
%                      (Mirror(V)  -offsetMir(V)) *convMir(nm/V)  + A(NV)*alphaA(nm/NV) - B(NV)*alphaB(nm/NV)
ext = hypot( (mirdata(:,1)-opts.offTrapX)*opts.convTrapX + bexts(:,1) - bexts(:,3), ...
             (mirdata(:,2)-opts.offTrapY)*opts.convTrapY + bexts(:,2) - bexts(:,4) )...
              - x0(1) - x0(2);
%Calculate total force = hypot( forX, forY ) using differential force (average of forces)
frc = hypot((frcs(:,3) - frcs(:,1))/2, ...
            (frcs(:,4) - frcs(:,2))/2);


%Convert XWLC
    function outXpL = XWLC(F, P, S, kT)
        %Simplification var.s
        C1 = F*P/kT;
        C2 = exp(nthroot(900./C1,4));
        outXpL = 4/3 ...
            + -4./(3.*sqrt(C1+1)) ...
            + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
            + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
            + F./S;
    end

con = ext ./ XWLC(frc, opts.dnaPL, opts.dnaSM, opts.dnakT) / opts.dnaBp;
con = double(con);

%only take real FCs - ones that are <1s
vtindl = vtind(:,2)-vtind(:,1);
vtind = vtind( vtindl < opts.Fsamp/2 ,:);

nind = size(vtind, 1);
win = .3 * opts.Fsamp; %amt of data on left and right
resid = cell(1, nind);

for i = 1:nind
    %fetch left, right snips
    stind = max(vtind(i,1) - win, 1);
    enind = min(vtind(i,2) + win, length(con));
    frcchk = frc(stind:enind) > 3; %minimum force, to avoid including tether break > infinite con. sections
    snip = con( (stind:enind) );
    snip = snip(frcchk)';
    x = 1:length(snip);
    pf = polyfit(x, snip, 1);
    %residual
    resid{i} = (snip - pf(1)*x - pf(2));
end

rsd = [resid{:}];
% rsd = sqrt(rsd);
%I kinda want to minmize linear absolute error ?

end