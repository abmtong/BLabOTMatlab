function plotcal(fg, cal)
%plots a cal like in @ACalibrate given a figure and its calibration
%uses a lot of code from @ACalibrate and @Calibrate

%if one arg, plot in a new figure window
if nargin == 1
    cal = fg;
    scrsz = get(groot, 'ScreenSize');
    fg = figure('Name', cal.file, 'Position', [scrsz(3:4)*.2 scrsz(3:4)*.6]);
end

%Char arrays for naming structs
c1 = 'AB';
c2 = 'XY';
for i = 1:2
    I = c1(i);
    for j = 1:2
        J = c2(j);
        tmp = cal.([I J]);
        ax = axes(fg, 'Position',[-.45+0.5*i, 1.05-0.5*j,  0.43, 0.43]);
        loglog(ax, tmp.Fall, tmp.Pall, 'Color', .8 * [1 1 1])
        hold on
        loglog(ax, tmp.F, tmp.P, 'o', 'Color', tmp.opts.color);
        loglog(ax, tmp.F, Lorentzian(tmp.fit, tmp.F, tmp.opts), 'Color', 'k', 'LineWidth', 2),
        Pmin = min(tmp.P);
        Pmax = max(tmp.P);
        text(tmp.F(1),(Pmin^2*Pmax)^.33,...
            sprintf(' %s \n fc: %0.0fHz \n D: %0.3f\n al: %0.3f\n f3: %0.1f \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV \n r: %dnm Sum: %0.2fV wV: %0.2e \n ',tmp.opts.name,tmp.fit,tmp.a,tmp.k,tmp.a*tmp.k, tmp.opts.ra, tmp.opts.Sum, tmp.opts.wV),...
            'FontSize',12);
        %         sprintf(' %s \n \\itf_{c}\\rm: %0.0fHz \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV',opts.name,fit(1),a,k,a*k),...
        %         'FontSize',12);
        ax.XLim = [tmp.F(1)*.9, tmp.F(end)*1.1];
        ax.YLim = [Pmin*.9, Pmax*1.1];
    end
end