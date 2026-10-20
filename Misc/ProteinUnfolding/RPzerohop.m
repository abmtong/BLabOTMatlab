function out = RPzerohop(opts)

if nargin < 1
    opts = RPzerohopPopup;
end

%Filepicker is in p1
rpp1 = RPzerohopp1([], opts);
rpp2 = RPzerohopp2(rpp1, opts);
try
    rpp3 = RPzerohopp3(rpp2, opts);
catch E
    
end

out = rpp2;