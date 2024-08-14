function [outf, outx, outfraw] = simpull()


opts.hlen = 3e3*.34; %Handle length, nm
opts.prng = 200; %Pull range, nm. Set negative to go reverse
opts.ripsz = 20; %Rip size, nm
opts.ripf = 10; %Rip force, pN
opts.vpull = 20; %Pull speed, nm/s
opts.noi = 0.2; %Noise at high force, pN. Will scale to lower forces
opts.dt = 1e-2; %dT
opts.trapk = 0.3; %pN/nm

%Setup variables
tpos = opts.hlen - opts.prng;
con = opts.hlen;

%Storage
nt = opts.prng*2/opts.vpull/opts.dt;
outx = zeros(1,nt);
outfraw = zeros(1,nt);

ripped = 0;

for i = 1:nt
    %Calculate force and extension
    [outfraw(i), outx(i)] = calcExt(tpos, con);
    
    %Move trap
    tpos = tpos + opts.vpull*opts.dt;
    
    %Check for rip
    if ~ripped && outfraw(i) > opts.ripf
        ripped = 1;
        con = con + opts.ripsz;
    end
end

%Add noise
%XWLCslope does a diff(), so need to add another value [just do 0.1 for now]
outf = outfraw + opts.noi * randn(1,nt) * 900 ./ XWLCslope([0.1 outfraw], 50, 900, 4.14);


figure, plot(outx, outfraw)
axis tight
ylim([0 30])

    function [frc, ext] = calcExt(tpos, con)
        %Calculate the force, extension given a trap position and contour [using lookup]
        
        %Trap pos = F * trapk*2 + ext(F)
        frc = lsqnonlin(@(x0) tpos - 2*x0/opts.trapk - con * XWLC(x0, 50, 900, 4.14), 5, 0.1, inf, optimoptions('lsqnonlin', 'Display', 'none'));
        ext = con * XWLC(frc, 50, 900, 4.14);
    end

end


