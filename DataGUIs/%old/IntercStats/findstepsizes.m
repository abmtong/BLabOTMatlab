function out = findstepsizes(intf)

len = length(intf);
wid = 10;
out = zeros(1, wid/2+1);

for i = 1:10 %loop over every "reading frame"
    for j = 1:len/10-1
        %extract segment
        indsta = 10*(j-1)+i;
        inden = 10*j+i-1;
        %count num interc
        ni = sum(intf(indsta:inden));
        %update var
        out(ni+1) = out(ni+1)+1;
    end
end