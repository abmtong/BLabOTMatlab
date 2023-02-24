function out = simPID(inOpts)

opts.pidvals = [1e-3 1e-5 0]; %PID values
opts.ssz = 10; %Step size, do a +x then a -x step
opts.dw = 1e3; %Pts per step

%
opts.trapsep = 1400; %nm, traps - bead diameters
opts.tcontour = 4000*.34; %nm
opts.trapk = 0.5; %pN/nm
opts.xwlcparams = {50 700}; %PL SM
opts.verbose = 1;

%Create PID value


