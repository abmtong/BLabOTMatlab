function out = PingEmAll()
%Pings all local IPs

%start of IPs
ip1 = 192;
ip2 = 168;

%IP timeout, in ms
timeout = 15; %Ethernet should ping by this time, out of 100 pings: avg 3ms, max 8ms

%[ping IP -n 1] will return:
%{
Pinging IP with 32 bytes of data:
Request timed out.
Ping statistics for IP:
Packets: Sent = 1, Recieved = 0, Lost = 1 (100% Loss),

<if successful>
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
%}
%Parse the end-1 char: comma = failure, s = success

%Which IPs to search over
ip3 = 100;
ip4 = 100;
%Store output
res = cell(ip3+1,ip4+1);
%Each ping takes ~0.5s, even with small timeout
fprintf('Search will take up to %0.2fm/number of threads\n',0.5*(ip3+1)*(ip4+1)/60);

parfor i = 1:(ip3+1)
    fprintf('Starting %d.%d.%d.x\n',ip1,ip2,i);
    startT = tic;
    for j = 1:(ip4+1)
        %ping IP -n NumTries -w Timeout(ms)
        cmd = sprintf('ping %d.%d.%d.%d -n 1 -w %d',ip1,ip2,i,j,timeout);
        [~, temp] = dos(cmd);
        temp = temp(end-1);
        res{i,j} = temp;
        if temp == 's'
            fprintf('Success: %s\n', cmd)
        end
    end
    fprintf('%d.%d.%d.x took %0.2fs\n',ip1,ip2,i,toc(startT))
end

[c, ~, ia] = unique(res(:));
in = find(c == 's', 1);
inds = find(ia == in);

[rr, cc] = ind2sub([ip3 ip4], inds);
out = [rr-1,cc-1];