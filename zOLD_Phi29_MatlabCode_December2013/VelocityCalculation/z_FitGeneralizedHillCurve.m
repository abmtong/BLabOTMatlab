function cf_=FitGeneralizedHillCurve(x,y,StDev, StErr)
%CREATEFIT    Create plot of datasets and fits
%   CREATEFIT(X,Y,WEIGHT)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1


% Data from dataset "y vs. x with Weight":
%    X = x:
%    Y = y:
%    Weights = Weight:
%
% This function was automatically generated on 17-Sep-2010 01:00:41
RelStErr = StErr./y; %relative standard error
%Weight = ones(size(RelStErr));
Weight = 1./(RelStErr.^2);
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


% --- Plot data originally in dataset "y vs. x with Weight"
x = x(:);
y = y(:);
Weight = Weight(:);
h_ = line(x,y,'Parent',ax_,'Color',[0.333333 0 0.666667],...
    'LineStyle','none', 'LineWidth',1,...
    'Marker','.', 'MarkerSize',12);
xlim_(1) = min(xlim_(1),min(x));
xlim_(2) = max(xlim_(2),max(x));
legh_(end+1) = h_;
legt_{end+1} = 'y vs. x with Weight';

% Nudge axis limits beyond data limits
if all(isfinite(xlim_))
    xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
    set(ax_,'XLim',xlim_)
else
    set(ax_, 'XLim',[0.099999999999999645, 1009.9]);
end


% --- Create fit "fit 1"
ok_ = isfinite(x) & isfinite(y) & isfinite(Weight);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs', ...
        'Ignoring NaNs and Infs in data' );
end
st_ = [10 10 0.5 ];
ft_ = fittype('Vmax*(x.^n)./(x.^n+Km^n)',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'Km', 'Vmax', 'n'});

% Fit this model using new data
cf_ = fit(x(ok_),y(ok_),ft_,'Startpoint',st_,'Weight',Weight(ok_));

% Or use coefficients from the original fit:
if 0
    cv_ = { 32.655528181888712, 92.445134357122086, 0.74226746758935125};
    cf_ = cfit(ft_,cv_{:});
end

% Plot this fit
h_ = plot(cf_,'fit',0.95);
%errorbar(x,y,StDev,'.','Color',[0.7 0.7 0.7]);
errorbar(x,y,StErr,'.k');
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
xlabel(ax_,'');               % remove x label
ylabel(ax_,'');               % remove y label
