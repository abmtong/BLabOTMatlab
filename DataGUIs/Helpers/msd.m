function out = msd(dat)

%Calculate MSD, slow loop way
len = length(dat);
out = zeros(1,len);
for i = 1:len
    out(i) = sum((dat(i:len) - dat(1:len-i+1)).^2)/(len-i+1);
end