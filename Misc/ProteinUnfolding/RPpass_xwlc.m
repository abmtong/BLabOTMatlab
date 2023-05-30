function out = RPpass_xwlc(fppull, fppass, inOpts)

opts = [];
if nargin >= 3 
    opts = handleOpts(opts, inOpts);
end

%Select pulling file

%Set up RP opts
rpo.pulltrim = 0; %There are only a few pullings, so take all of them
pxout = RP(fppull,rpo);

%Get median XWLC stats
xwlcft = median( reshape( [pxout.xwlcft], 7, [] ), 2)';

%Set protien WLC to 0.6
xwlcft(end-1) = 0.6;

%And then do RPpass
opts.xwlcft = xwlcft;
opts.conmeth = 2; %Use XWLC

p1out = RPpass_p1(fppass,opts);
p2out = RPpass_p2(p1out,opts);
p3out = RPpass_p3(p2out,opts);

out = p2out;