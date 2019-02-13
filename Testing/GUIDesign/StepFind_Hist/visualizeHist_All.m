function visualizeHist_All(tr, dS, Sind, a, dt)
%Takes some intermediates in findStepHistV8 to visualize the algorithm (e.g. set a breakpoint at the end of findStepHistV8 to grab the var.s)
%Timing right now is done by breakpoints: Continue to advance by dt points.

hei = length(a);
wid = length(dS);

if nargin < 5
    dt = 10;
end
figure('Name','Hist method visualizer')
%Time points every 10 pts
for t = dt:dt:wid
    plot(tr), hold on;
    x = 1:t;
    con = zeros(1,t);
    for y = 1:hei
        col = [ floor(rem(y,16)/16) floor(rem(y,4)/4) rem(y,3) ] /4;
        con(t) = y;
        for i = t-1:-1:1
            con(i) = dS(i,con(i+1));
        end
        con = a(con);
        line(x, con,'Color',col)
    end
    plot(tr)
    set(gca, 'XLim',[t-20 t+1]);
    set(gca, 'YLim',[tr(t)-30, tr(t)+30]);
    hold off
    drawnow
    %Right now timed by processor speed - can do breakpoint/wait()/etc. to control speed
end