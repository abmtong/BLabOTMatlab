function out = hmmlo_postprocess(intr, goodsz)
%joins steps that HMM has cut in half
%requires preknowledge of the step size (e.g. from PWD)

if nargin < 2
    goodsz = 10;
end

[in, me] = tra2ind(intr); %consider in = tra2ind(intr); me = ind2mea(in, con); instead for less granular step sizes

%get dwell times between steps
dwts = diff(in);
%first, last dwell times aren't meaningful
%only remove last dwell time for now
dwts = dwts(2:end-1);

%get step sizes
mns = diff(me); 

%allocate new stuff
newdw = zeros(size(dwts));
newme = zeros(size(dwts));

%find steps that seem whole (step + either adjacent step hurts (gets farther from goodsz))
len = length(newme);
iswhole = false(1,len);
for i = 1:len
    if i > 2
        iswhole(i) = abs( mns(i) + mns(i-1) - goodsz ) >= abs(mns(i) - goodsz) ;
    end
    if i < len
        iswhole(i) = iswhole(i) && abs( mns(i) + mns(i+1) - goodsz ) >= abs(mns(i) - goodsz) ;
    end
end

%extract full steps and the dwell times corresponding to those steps
fullmes = mns(iswhole);
mns(iswhole) = [];
fulldws = dwts(iswhole(2:end));
dws(iswhole(2:end)) = [];


%of remaining, find pairs of step sizes that go together



