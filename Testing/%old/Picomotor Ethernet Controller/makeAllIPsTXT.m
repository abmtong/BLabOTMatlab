function makeAllIPsTXT()
%Outputs every local IP, from startIP.001.001 to startIP.255.255
%To run, in cmd run:
%FOR /F %i IN (IPs.txt) DO ping %i -n 1 -w 15
%>>Not faster than matlab implementation. Need

%static first 2 
ip1 = 192;
ip2 = 168;
%search from 0 to these
ip3 = 255;
ip4 = 255;

fid = fopen('IPs.txt','w');
for i = 1:ip3
    for j = 1:ip4
        fprintf(fid,'%d.%d.%d.%d\n',ip1,ip2,i,j);
    end
end
fclose(fid);