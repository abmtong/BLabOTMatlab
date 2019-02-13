function alignFCs(stepdata, inopts)

%extract raw data (normalized voltages), store in n / nc[ut]
n = [];
nc = [];
names = {'AX' 'AY' 'BX' 'BY'};
for i = 1:length(names)
    nm = names{i};
    n.(nm) = cellfun(@(x) x / stepdata.cal.(nm).k / stepdata.cal.(nm).a, stepdata.(['force' nm]), 'uni', 0);
    nc.(nm) = cellfun(@(x) x / stepdata.cal.(nm).k / stepdata.cal.(nm).a, stepdata.cut.(['force' nm]), 'uni', 0);
end

%choose new A/K/etc.

%For now guess that bead A is 20% bigger than expected
opts.aafact = 1.2^-.5;
opts.akfact = 1.2;
opts.bafact = 1;
opts.bkfact = 1;

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

%newExt ~= oldExt - (old bead ext) + (new bead ext) {the real is hypot'd with the Y-values, but we'll just ignore
% new - old) bead ext = bead ext * afact

oldbeadext = cellfun(@(x,y) x * stepdata.cal.AX.a - y * stepdata.cal.BX.a, n.AX, n.BX, 'uni', 0);
oldbeadext = cellfun(@(x,y) x * stepdata.cal.AX.a * opts.aafact - y * stepdata.cal.BX.a * opts.bafact, n.AX, n.BX, 'uni', 0)

oldf = 
newf = 

newext = 
stepdata.contour = ./ XWLC


%Calculate extension  = hypot( TrapX + BeadsX , TrapY + BeadsY) - Bead Radii
%                      (Mirror(V)  -offsetMir(V)) *convMir(nm/V)  + A(NV)*alphaA(nm/NV) - B(NV)*alphaB(nm/NV)
out.extension = hypot( (rawdat(5,:)-opts.offTrapX)*opts.convTrapX + cal.AX.a*dat.AX - cal.BX.a*dat.BX, ...
                       (rawdat(6,:)-opts.offTrapY)*opts.convTrapY + cal.AY.a*dat.AY - cal.BY.a*dat.BY )...
                       - opts.raA - opts.raB;
%Calculate total force = hypot( forX, forY ) using differential force (average of forces)
out.force = hypot((out.forceBX - out.forceAX)/2, ...
                  (out.forceBY - out.forceAY)/2);


%save as new stepdata
save('Phage010101N01test.mat', stepdata);

%plot new a/k/etc., or write to new /stepdata/ and handle like that
%{
Where does FC misalignment come up?
I assume it's because the force is misreported.
This could be due to a few reasons:
-Double tether, force recorded by tweezer is not the force felt by the tether
-Bead size is different, causing a difference in the calibration
--F = NV * a * k
--- a ~ sqrt(T/ra), k ~ ra, a*k ~ sqrt(T*ra)
-XWLC params are off: 

How to solve
-Find setup that straightens the chopped sections of FCs / puts them in line w/ adjacent FCs

Contour = ext / XpL = NV * a / XWLC(NV*a*k, XWLCparams{:});
> Effect on a and k separately IS important

%}