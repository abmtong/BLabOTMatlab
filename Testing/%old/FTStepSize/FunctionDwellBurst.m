function out = FunctionDwellBurst(Params,t)
%A parametric function of connected line segments. Params = [[x0 l]', [y0 m]'] where x and m are column vectors of the lengths, slopes of the segments, and x0,y0 is the start point. t is a vector of the x-values.
%e.g. constrain slopes to be alternating 0 and negative to constrain to packaging, lengths to be long/short
%Noise: Maybe can filter it out?
%Probably won't be good, but let's see

%Compare to K-V
%How to limit numSteps? Like KV: if adding a step doesnt remove enough?
%Theoretically a step should remove (DwellTime*BurstHeight)/2 deviation (straight through vs a step)

x0 = Params(1,1);
y0 = Params(1,2);
l = Params(2:end,1);
m = Params(2:end,2);

%Create vector of x positions of boundary points
x = zeros(length(l)+1,1);
for i = 1:length(l)
    x(i+1) = sum(l(1:i));
end
%Offset each by the starting value
x = x + x0;

%Create vector of y positions of boundary points
y = zeros(length(l)+1,1);
for i = 1:length(l)
    y(i+1) = y(i) + l(i)*m(i);
end
%Offset each by the starting value
y = y + y0;

out = zeros(1,length(t));
for i = 1:length(t)
    %Make sure t is within the bdy, else write the bdy value
    if t(i) <= x(1)
        out(i) = y(1);
    elseif t(i) >= x(end)
        out(i) = y(end);
    else
        %Find the x boundary closest to the left of t
        ind = find(t(i) >= x,1,'last');
        %y = b + mx
        out(i) = y(ind) + m(ind)*(t(i)-x(ind));
    end
end

end