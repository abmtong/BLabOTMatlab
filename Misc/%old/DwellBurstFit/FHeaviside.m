function out = FHeaviside(Params,t)
%A parametric function of Heaviside-like steps. Params = [[l]', [h]'] where l and h are column vectors of the lengths, heights of the segments. t is a vector of the x-values.

%Compare to K-V
%How to limit numSteps? Like KV: if adding a step doesnt remove enough?
%Theoretically a step should remove (DwellTime*BurstHeight)/2 deviation (straight through vs a step)

l=Params(:,1);
h=Params(:,2);
%Create vector of x positions of boundary points
x = zeros(length(l),1);
for i = 1:length(l)
    x(i+1) = sum(l(1:i));
end

out = zeros(1,length(t));
for i = 1:length(t)
    %Make sure t is within the bdy, else write 0
    if t(i) <= x(1)
        out(i) = 0;
    elseif t(i) >= x(end)
        out(i) = 0;
    else
        %Find the x boundary closest to the left of t
        ind = find(t(i) >= x,1,'last');
        out(i) = h(ind);
    end
end

end