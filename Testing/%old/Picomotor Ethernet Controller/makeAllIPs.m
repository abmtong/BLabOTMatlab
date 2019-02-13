function makeAllIPs()
%Outputs every local IP, from startIP.001.001 to startIP.255.255
%Requires a starting shortcut that is to 192.168.001.001 (leading 0s important)
%Err wait, this makes 65k files, all of which need to be opened

for i = 1:2 %255 for all
    for j = 1:2
        fname = sprintf('IP%03d-%03d.url',i,j);
        fid = fopen(fname, 'w+');
        fprintf(fid,'[InternetShortcut]\nURL=http://192.168.%d.%d/',i,j);
        fclose(fid);
    end
end