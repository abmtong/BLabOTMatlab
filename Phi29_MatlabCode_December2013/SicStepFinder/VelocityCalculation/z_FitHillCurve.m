function cf_=FitHillCurve(xdata,ydata,Label)
%CREATEFIT    Create plot of datasets and fits
%   CREATEFIT(XDATA,YDATA)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1


% Data from dataset "10kb":
%    X = xdata:
%    Y = ydata:
%    Unweighted
%
% This function was automatically generated on 24-Aug-2010 17:52:53

% Set up figure to receive datasets and fits
f_ = clf;
figure(f_);
set(f_,'Units','Pixels','Position',[473 113 688 485]);
legh_ = []; legt_ = {};   % handles and text for legend
xlim_ = [Inf -Inf];       % limits of x axis
ax_ = axes;
set(ax_,'Units','normalized','OuterPosition',[0 0 1 1]);
set(ax_,'Box','on');
grid(ax_,'on');
axes(ax_); hold on;


% --- Plot data originally in dataset "10kb"
xdata = xdata(:);
ydata = ydata(:);
h_ = line(xdata,ydata,'Parent',ax_,'Color',[0.333333 0 0.666667],...
    'LineStyle','none', 'LineWidth',1,...
    'Marker','.', 'MarkerSize',12);
xlim_(1) = min(xlim_(1),min(xdata));
xlim_(2) = max(xlim_(2),max(xdata));
legh_(end+1) = h_;
legt_{end+1} = Label;

% Nudge axis limits beyond data limits
if all(isfinite(xlim_))
    xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
    set(ax_,'XLim',xlim_)
else
    set(ax_, 'XLim',[0.049999999999999822, 504.94999999999999]);
end


% --- Create fit "fit 1"
ok_ = isfinite(xdata) & isfinite(ydata);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [10 10 1 ];
ft_ = fittype('Vmax*(x.^n)./(x.^n+Km^n)',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'Km', 'Vmax', 'n'});

% Fit this model using new data
cf_ = fit(xdata(ok_),ydata(ok_),ft_,'Startpoint',st_);

% Or use coefficients from the original fit:
if 0
    cv_ = { 45.415129108242617, 98.471774642647048, 0.78891592135661415};
    cf_ = cfit(ft_,cv_{:});
end

% Plot this fit
h_ = plot(cf_,'fit',0.95);
legend off;  % turn off legend from plot method call
set(h_(1),'Color',[1 0 0],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
legh_(end+1) = h_(1);
legt_{end+1} = 'fit 1';

% Done plotting data and fits.  Now finish up loose ends.
hold off;
leginfo_ = {'Orientation', 'vertical', 'Location', 'NorthEast'};
%h_ = legend(ax_,legh_,legt_,leginfo_{:});  % create legend
%set(h_,'Interpreter','none');
xlabel('ATP Concentration (uM)');               % remove x label
ylabel('Velocity (bp/sec)');               % remove y label
title(Label);
