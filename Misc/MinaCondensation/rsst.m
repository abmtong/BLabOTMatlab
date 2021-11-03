function rsst(intr, inraw)
%Tester

%1kHz ish, 
wtry = [0 5 10 20];

fg = figure;
ax1 = subplot2(fg, [3 1], 1);
ax2 = subplot2(fg, [3 1], 2);
ax3 = subplot2(fg, [3 1], 3);

hold(ax1, 'on')
hold(ax2, 'on')
hold(ax3, 'on')

for i = 1:length(wtry)
    tmp = rmShortSteps(intr, wtry(i));
    plot(ax1, tmp)
    [~, me] = tra2ind(tmp);
    tmp2 = abs(diff(me));
    plot(ax2, sort( tmp2 ), linspace(0,1,length(me)-1))

    %Weight step size by step size (to emph. longer steps)
    mx = max(tmp2);
    tmp3 = arrayfun(@(x) [x*ones(x, 1) ; zeros( mx - x, 1)], abs(tmp2), 'Un', 0);
    tmp3 = [tmp3{:}];
    tmp3 = tmp3(:)';
    tmp3(tmp3 == 0) = [];
    
    plot(ax3, sort( tmp3 ), linspace(0,1,length(tmp3)))
    

end

if nargin > 1
plot(ax1, inraw, 'Color', ones(1,3)*.7)
ax1.Children = ax1.Children([end 1:end-1 ]);
end


xlim( ax2, [0 100] )
xlim( ax3, [0 0100] )





