function [out, outraw] = anCondense_endpt(st, fns)
%Calculate the degree of compaction by taking the end 


ptwid = 100;

len = length(fns);
dat = cell(1,len);
for i = 1:len
    dat{i} = st.(fns{i}).lo;
end

%Set the endpt as the last X pts


outraw = cell(1,len);
for i = 1:len
    outraw{i} = cellfun(@(x) mean(x(end-ptwid:end)), dat{i});
end

%output [mean, sd, N]
out = [cellfun(@mean, outraw); cellfun(@std, outraw); cellfun(@length, outraw)]';