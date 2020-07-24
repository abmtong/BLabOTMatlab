function cf_=FitVelocityDataToHillEquation_14Dec10(x,y,y_weight)
%CREATEFIT    Create plot of datasets and fits
%   CREATEFIT(X,Y,Y_WEIGHT)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1
%
% USE: cf_=FitVelocityDataToHillEquation_14Dec10(x,y,y_weight)

% Data from dataset "Filling 1":
%    X = x:
%    Y = y:
%    Weights = y_weight:
%
% This function was automatically generated on 15-Dec-2010 02:44:06

% Set up figure to receive datasets and fits
f_ = clf;
figure(f_);
set(f_,'Units','Pixels','Position',[473 113 688 485]);
legh_ = []; legt_ = {};   % handles and text for legend
xlim_ = [Inf -Inf];       % limits of x axis
ax_ = axes;
set(ax_,'Units','normalized','OuterPosition',[0 0 1 1]);
set(ax_,'Box','on');
axes(ax_); hold on;


% --- Plot data originally in dataset "Filling 1"
x = x(:);
y = y(:);
y_weight = y_weight(:);
h_ = line(x,y,'Parent',ax_,'Color',[0.333333 0 0.666667],...
    'LineStyle','none', 'LineWidth',1,...
    'Marker','.', 'MarkerSize',12);
xlim_(1) = min(xlim_(1),min(x));
xlim_(2) = max(xlim_(2),max(x));
legh_(end+1) = h_;
legt_{end+1} = 'Filling 1';

% Nudge axis limits beyond data limits
if all(isfinite(xlim_))
    xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
    set(ax_,'XLim',xlim_)
else
    set(ax_, 'XLim',[15.25, 1009.75]);
end


% --- Create fit "Hill Equation"
ok_ = isfinite(x) & isfinite(y) & isfinite(y_weight);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [0.59023023409645514 0.05692159475588543 ];
ft_ = fittype('Vmax*x/(x+Km)',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'Km', 'Vmax'});

% Fit this model using new data
cf_ = fit(x(ok_),y(ok_),ft_,'Startpoint',st_,'Weight',y_weight(ok_));

% Or use coefficients from the original fit:
if 0
    cv_ = { 24.658339854553841, 85.171642612806266};
    cf_ = cfit(ft_,cv_{:});
end

% Plot this fit
h_ = plot(cf_,'fit',0.95);
legend off;  % turn off legend from plot method call
set(h_(1),'Color',[1 0 0],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
legh_(end+1) = h_(1);
legt_{end+1} = 'Hill Equation';

% Done plotting data and fits.  Now finish up loose ends.
hold off;
leginfo_ = {'Orientation', 'vertical'};
h_ = legend(ax_,legh_,legt_,leginfo_{:}); % create and reposition legend
set(h_,'Units','normalized');
t_ = get(h_,'Position');
t_(1:2) = [0.693798,0.142911];
set(h_,'Interpreter','none','Position',t_);
xlabel(ax_,'');               % remove x label
ylabel(ax_,'');               % remove y label
