function out = RPpass(inOpts)

opts = [];
if nargin > 0 
    opts = handleOpts(opts, inOpts);
end

p1out = RPpass_p1([],opts);
p2out = RPpass_p2(p1out,opts);
p2out = RPpass_p2_xwlc(p2out, opts);
p3out = RPpass_p3(p2out,opts);

out = p2out;