function out = hmmpp_batch(goodsz)
%opens a bunch of HMM files, creates histogram

if nargin < 1
    goodsz = 10;
end


[f, p] = uigetfile('pHMM*.mat', 'MultiSelect', 'on');

if ~p
    return
end

if ~iscell(f)
    f = {f};
end


len = length(f);
pp = cell(1, len);

parfor i = 1:len
    pp{i} = hmmpp_one([p f{i}], goodsz);
end

%gather 
%first and last values of each ssz aren't reliable
crp = @(x) x(2:end-1);
%first and last two dwell times aren't good either
crp2 = @(x) x(2:end-2);

pp=[pp{:}];

sszs = cellfun(crp, {pp.ssz}, 'uni', 0);
dwts = cellfun(crp2, {pp.dwt}, 'uni', 0);
buts = cellfun(crp2, {pp.but}, 'uni', 0);

out.ssz = [sszs{:}];
out.dwt = [dwts{:}];
out.but = [buts{:}];


figure, 
subplot(3, 1, 1), hist(out.ssz, 100)
subplot(3, 1, 2), hist(out.dwt, 100)
subplot(3, 1, 3), hist(out.but, 100)










