function out = RPcheck(inst)
%Check RP results. Can be used at any point in the RP process : checks fieldnames for progress

fil = 10;

%For each trace..
len = length(inst);
for i = 1:len
    tmp = inst(i);
    figure('Name', sprintf('RPcheck %d', i), 'Color', [1 1 1]);
    %Plot the cycle (force-time)
    subplot(2,2,1), hold on
    title('Pulling cycle, Force-Time')
    xlabel('Time (pts)')
    ylabel('Force (pN)')
    plot(tmp.frc)
    
    %Exit if no ripind (pre-p2)
    if ~isfield(tmp, 'ripind')
        continue
    end
    %Vertical bars for rip + back location
    yl = ylim;
    plot( tmp.ripind *[1 1], yl, 'r', 'LineWidth', 1 )
    plot( tmp.retind *[1 1], yl, 'k', 'LineWidth', 1 )
    legend({'Data' 'Rip location' 'Retract start'})
    
    %Exit if no protein contour (pre-p3)
    if ~isfield(tmp, 'conpro')
        continue
    end
    %Plot XWLC fit
    xx = windowFilter(@mean, tmp.ext, [], fil);
    yy = windowFilter(@mean, tmp.frc, [], fil);
    ri = floor(tmp.ripind / 10);
    %fitfcn2 taken from p3
    fitfcn2 = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) + ((1:length(f)) > ri ) .* x0(7) .* XWLC(f-x0(5), x0(6),inf)  );
    xf = fitfcn2(tmp.xwlcft, yy);
    %Plot
    subplot(2,2,2), hold on
    title('Pulling cycle, Force-Ext')
    xlabel('Extension (nm)')
    ylabel('Force (pN)')
    plot(xx, yy)
    plot(xf, yy)
    legend({'Data' 'XWLC DNA+Protein fit'})
    
    %Plot protein contour
    subplot(2,2,3)
    cc = windowFilter(@mean, tmp.conpro, [], fil);
    plot(cc)
    title('Protein Contour Trace')
    xlabel('Time (pts)')
    ylabel('Protein Contour (nm)')
    legend({'Contour-time Trace'})
    yl = prctile(cc, [1 99]);
    ylim(yl) %Zoom y-axis to remove low force outliers
    
    %Plot but zoom to small region
    subplot(2,2,4)
    plot(tmp.conpro)
    ylim(yl)
    xlim( tmp.ripind + [-1 1] * 200 )
    title('Unfolding Transition Path')
    xlabel('Time (pts)')
    ylabel('Protein Contour (nm)')
    legend({'Contour-time Trace'})
    
    
end