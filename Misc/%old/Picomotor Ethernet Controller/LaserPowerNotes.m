%{
The New focus 8752 Ethernet Controller must be reset while ethernet-connected in order for it to get an IP
If we don't know the IP, find it on the router (Default login: admin/[blank]), or ping all local IPs with PingEmAll.m]
 Router likes to start at 192.168.0.100 and increment by 1

Control via telnet: open cmd, type
 telnet [ip]
 where [ip] is the ip address

Only one command:
 rel a1 # g
 # is the number of steps to take
 Note: Motor is open-loop, so +1 and -1 don't cancel

Controller can only move the motor plugged into the first slot - so swap wires if you need to move the other one
First HWplate controls total power, second controls trap's relative powers
%}