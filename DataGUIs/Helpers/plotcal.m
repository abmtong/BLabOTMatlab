function plotcal(fg, cal)
%plots a cal like in @ACalibrate given a figure and its calibration
%uses a lot of code from @ACalibrate and @Calibrate

%if one arg, plot in a new window
if nargin == 1
    cal = fg;
    scrsz = get(groot, 'ScreenSize');
    if isfield(cal.opts, 'lortype')
        lorstr = num2str(cal.opts.lortype);
    else
        lorstr = '3(?)';
    end
    fg = figure('Name', sprintf('%s Calibration, lortype %s',cal.file,lorstr), 'Position', [scrsz(3:4)*.2 scrsz(3:4)*.6]);
end

%Check if this cal has saved plots, otherwise just plot a table with cal options
if isfield(cal.AX, 'Fall')
    %Char arrays for naming structs
    c1 = 'AB';
    c2 = 'XY';
    for i = 1:2
        I = c1(i);
        for j = 1:2
            J = c2(j);
            tmp = cal.([I J]);
            if isempty(tmp.F) %Skip empty cals
                continue
            end
            ax = axes(fg, 'Position',[-.45+0.5*i, 1.05-0.5*j+.1,  0.43, 0.33]);
            loglog(ax, tmp.Fall, tmp.Pall, 'Color', .8 * [1 1 1])
            hold on
            loglog(ax, tmp.F, tmp.P, 'o', 'Color', tmp.opts.color);
            loglog(ax, tmp.F, Lorentzian(tmp.fit, tmp.F, tmp.opts), 'Color', 'k', 'LineWidth', 2),
            Pmin = min(tmp.P);
            Pmax = max(tmp.P);
            if isfield(cal.opts, 'lortype')
                if cal.opts.lortype == 5
                    text(tmp.F(1),(Pmin^2*Pmax)^.33,...
                        sprintf(' %s \n fc: %0.0fHz \n D: %0.3f\n al: %0.3f\n [f0 g0 f1 g1]: [%0.1f %0.1f %0.1f %0.1f] \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV \n r: %dnm Sum: %0.2fV wV: %0.2e \n ',tmp.opts.name,tmp.fit,tmp.a,tmp.k,tmp.a*tmp.k, tmp.opts.ra, tmp.opts.Sum, tmp.opts.wV),...
                        'FontSize',12);
                else
                    text(tmp.F(1),(Pmin^2*Pmax)^.33,...
                        sprintf(' %s \n fc: %0.0fHz \n D: %0.3f\n al: %0.3f\n f3: %0.1f \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV \n r: %dnm Sum: %0.2fV wV: %0.2e \n ',tmp.opts.name,tmp.fit,tmp.a,tmp.k,tmp.a*tmp.k, tmp.opts.ra, tmp.opts.Sum, tmp.opts.wV),...
                        'FontSize',12);
                end
            else %assume lortype = 3
                text(tmp.F(1),(Pmin^2*Pmax)^.33,...
                    sprintf(' %s \n fc: %0.0fHz \n D: %0.3f\n al: %0.3f\n f3: %0.1f \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV \n r: %dnm Sum: %0.2fV wV: %0.2e \n ',tmp.opts.name,tmp.fit,tmp.a,tmp.k,tmp.a*tmp.k, tmp.opts.ra, tmp.opts.Sum, tmp.opts.wV),...
                    'FontSize',12);
            end
            %         sprintf(' %s \n \\itf_{c}\\rm: %0.0fHz \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV',opts.name,fit(1),a,k,a*k),...
            %         'FontSize',12);
            ax.XLim = [tmp.F(1)*.9, tmp.F(end)*1.1];
            ax.YLim = [Pmin*.9, Pmax*1.1];
            
            %plot residual
            ax2 = axes(fg, 'Position', [-.45+0.5*i, 1.05-0.5*j,  0.43, 0.10]);
            ax2.XScale = 'log';
            hold on
            box on
            line(ax2, [tmp.F(1), tmp.F(end)], [1 1], 'LineWidth', 2, 'Color', 'k');
            %         semilogx(ax2, tmp.Fall, Lorentzian(tmp.fit, tmp.Fall', tmp.opts) ./ tmp.Pall','Color', .8*[1 1 1] );
            semilogx(ax2, tmp.F, (Lorentzian(tmp.fit, tmp.F, tmp.opts) ./ tmp.P).^-1, 'o', 'Color', tmp.opts.color );
            ax2.XLim = [tmp.F(1)*.9, tmp.F(end)*1.1];
            linkaxes([ax ax2], 'x');
            ax2.YLim = [.9 1.1];
        end
        
    end
else
    %Just plot a table of detector + Al/Ka/etc.
    colnms = {'Trap A' 'Trap B'};
    rownms = {'X fc' 'X D' 'X alpha' 'X kappa' 'X al*ka' ...
           '' 'Y fc' 'Y D' 'Y alpha' 'Y kappa' 'Y al*ka'};
    tbldat = [ cal.AX.fit(1) cal.AX.fit(2) cal.AX.a cal.AX.k cal.AX.a*cal.AX.k ...
             0 cal.AY.fit(1) cal.AY.fit(2) cal.AY.a cal.AY.k cal.AY.a*cal.AY.k;...
               cal.BX.fit(1) cal.BX.fit(2) cal.BX.a cal.BX.k cal.BX.a*cal.BX.k ...
             0 cal.BY.fit(1) cal.BY.fit(2) cal.BY.a cal.BY.k cal.BY.a*cal.BY.k]';
    tbl = uitable(fg, 'Position', [10 10 fg.Position(3:4)], 'Data', tbldat, 'ColumnName', colnms, 'RowName', rownms );
    tbl.Position(3:4) = tbl.Extent(3:4);
    fg.Position(3:4) = tbl.Extent(3:4)+20;
end