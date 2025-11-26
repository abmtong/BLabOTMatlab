function RPp6_plot(outraw)

if length(outraw)>1
    arrayfun(@RPp6_plot, outraw)
    return
end

out = outraw.fit;
fitrow = 4; %Use this row for # display

figure('Name', sprintf('d=%0.2f+-%0.2f, k0=%0.2f+-%0.2f', out(fitrow,2), out(fitrow+1,2), out(fitrow,1), out(fitrow+1,1)) )
subplot(3,1,[1 2]), hold on
plot(outraw.fhist(:,1),outraw.fhist(:,2))
xl = xlim;
plot(outraw.ffit(:,1),outraw.ffit(:,2));
plot(outraw.ffit(:,1),outraw.ffit(:,3));
xlim(xl) %Set xlim to bins' xlim, as p3 will be over the whole force range
legend({'Rip force' 'MLE fit' 'Curve fit'})
xlabel('Force (pN)')
ylabel('Probability Density')

%Plot pull speed dist, to check
subplot(3,1,3), hold on
plot(outraw.rpullraw);
xlabel('Trace #');
ylabel('Pull Speed (nm/s)')
drawnow