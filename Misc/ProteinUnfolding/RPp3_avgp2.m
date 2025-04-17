function out = RPp3_avgp2(inst)
%After RPp3_avg, redo and just shift the... X-offset? DNA CL? lets do DNA CL

len = length(inst);

for i = 1:len
    %Get data
    tmp = inst(i);
    %Fix all but inst
    xw = tmp.xwlcft;
    xw(3) = nan; %This fixes everything except for DNA CL. There is probably a more efficient way of doing this but EH
    inst(i) = RPp3V2(tmp, struct('xwlcset', xw ) );
end


out = inst;

