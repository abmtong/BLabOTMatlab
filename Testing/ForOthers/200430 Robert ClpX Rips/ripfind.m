function out = ripfind(inx, opts)
%For ClpX unwinding
%Finds a rip by looking for large jumps in dx


opts.np = 10; %Max rip time, pts
opts.ripthr = 5; %Minimum rip size

np = opts.np;

dx = inx(1+np:end)-inx(1:end-np);



%Debug: Plot

