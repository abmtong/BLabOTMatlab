function out = hmmpp_one(pf, goodsz)
load(pf, 'fcdata')
if isfield(fcdata, 'hmmfinished')
    ind = fcdata.hmmfinished;
else
    return
end
if ind == 0
    ind = length(fcdata.hmm);
elseif ind == -1
    out = [];
    return
end
out = hmmlo_postprocessV2(fcdata.hmm(ind).fit, goodsz);