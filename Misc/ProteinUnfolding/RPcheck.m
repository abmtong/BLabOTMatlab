function RPcheck(inst)
%Check RP results. Can be used at any point in the RP process : checks fieldnames for progress

fil = 100;
dsamp = 1;
ripwid = 1000;

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
    plot(windowFilter(@median,tmp.frc,fil,dsamp))
    
    %Exit if no ripind (pre-p2)
    if ~isfield(tmp, 'ripind')
        continue
    end
    %Vertical bars for rip + back location
    yl = ylim;
    tfr = [0 0 0]; %Rip, Ret, Ref plotted
    if ~isempty(tmp.ripind)
        plot( tmp.ripind *[1 1], yl, 'r', 'LineWidth', 1 )
        tfr(1) = 1;
    end
    if ~isempty(tmp.retind)
        plot( tmp.retind *[1 1], yl, 'k', 'LineWidth', 1 )
        tfr(2) = 1;
    end
    
    if isfield(tmp, 'refind') && ~isempty(tmp.refind)
        plot( tmp.refind *[1 1], yl, 'g', 'LineWidth', 1 )
        tfr(3) = 1;
    end
    lgn = {'Data' 'Rip location' 'Retract start' 'Zip location'};
    
    legend(lgn(logical([1 tfr])))
    %Exit if no protein contour (pre-p3)
    if ~isfield(tmp, 'conpro')
        continue
    end
    %Plot XWLC fit
    if isfield(tmp, 'xwlcft')
        xx = windowFilter(@median, tmp.ext, fil, dsamp);
        yy = windowFilter(@median, tmp.frc, fil, dsamp);
        ri = floor(tmp.ripind / dsamp);
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
    end
    %Plot protein contour
    ax3=subplot(2,2,3);
    hold on
    cc = windowFilter(@median, tmp.conpro, fil, dsamp);
    plot(cc)
    if isfield(tmp, 'xwlcft')
        yl = tmp.xwlcft(end) * [-.2, 1.4] ;
    else
        yl = [0 40];
    end

    ylim(yl);
    if isfield(tmp,'ripind')
        plot( floor(tmp.ripind / dsamp ) * [1 1], yl, 'r');
        xl = floor(tmp.ripind / dsamp ) + [-ripwid ripwid]/dsamp;
        xlim(xl)
    end
    
    title('Unfolding Transition ')
    xlabel('Time (pts)')
    ylabel('Protein Contour (nm)')
    legend({'Contour-time Trace'})
%     yl = prctile(cc, [1 99]);
%     %For bad processing, yl might be NaN. Let yl be 'okay'
%     if any(isnan(yl))
%         yl = [0 100];
%     end
%     ylim(yl) %Zoom y-axis to remove low force outliers
    
    %Plot refold: Just copy plot 3 with different xlim
    ax4 = subplot(2,2,4);
    hold on
    copyobj(ax3.Children, ax4);
    ylim(yl);
    if isfield(tmp,'refind')
        plot( floor(tmp.refind / dsamp ) * [1 1], yl, 'g');
        xl = floor(tmp.refind / dsamp ) + [-ripwid ripwid]/dsamp;
        xlim(xl)
    end
%     plot(cc)
%     ylim(yl)
%     if isfield(tmp, 'refind') && ~isempty(tmp.refind)
%         xlim( tmp.ripind + [-1 1] * 200 )
%     end
    title('Refolding Transition')
    xlabel('Time (pts)')
    ylabel('Protein Contour (nm)')
    legend({'Contour-time Trace'})
    
    
end