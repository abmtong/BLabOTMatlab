function visualizeHist(tr, dS, Sind, a, dt)
%Takes some intermediates in findStepHistV8 to visualize the algorithm (e.g. set a breakpoint at the end of findStepHistV8 to grab the var.s)
%Timing right now is done by breakpoints: Continue to advance by dt points.

if nargin < 5
    dt = 10;
end
figure('Name','Hist method visualizer')
%Time points every 10 pts
for t = dt:dt:length(dS)
    plot(tr), hold on;
    x = 1:t;
    for y = 1:64;
        col = [ floor(y/16) floor(rem(y,4)/4) rem(y,3) ] /4;
        con = zeros(1,t);
        ind = y + Sind(t) - 32;
        ind = min(ind, length(a));
        ind = max(ind, 1);
        con(t) = ind;
        for i = t-1:-1:1
            con(i) = dS(i,con(i+1));
        end
        con = a(con);
        line(x, con,'Color',col)
    end
    plot(tr)
    set(gca, 'XLim',[t-15 t+1]);
    set(gca, 'YLim',[tr(t)-15, tr(t)+15]);
    hold off
    %Sloppy, but put breakpoint here to control loop execution
end