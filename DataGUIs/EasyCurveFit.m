function out = EasyCurveFit(ob)

%Pass the object of the curve. Uses gco, then plot on gca by default.

if nargin < 1
    ob = gco;
    if ~isa(ob, 'matlab.graphics.chart.primitive.Line')
        ob = get(gca, 'Children');
        ob = ob(find(isa(ob, 'matlab.graphics.chart.primitive.Line'),1,'last'));
        if isempty(ob)
            return
        end
    end
end

opts = ezCurveFitOpts;

ax = get(ob, 'Parent');
%Get x/ydata of object
xx = ob.XData;
yy = ob.YData;

%Do cropping, if requested
switch opts.xlim.typ
    case 'All'
        xl = [-inf inf];
    case 'Current view'
        xl = ax.XLim;
    case 'Custom'
        xl = opts.xlim.opt;
        %Check if ok
        if ~issorted(xl) || numel(xl) <2
            warning('Invalid custom xlim, using all');
            xl = [-inf inf];
        end
    otherwise
        warning('Invalid xlim %s, using all');
        xl = [-inf inf];
end
ki = xx >= xl(1) & xx <= xl(2);
xx = xx(ki);
yy = yy(ki);

if isempty(xx)
    warning('Found no points after cropping.')
    return
end

%Create model fcn
%Make function handles. Each function depends on 2 parameters and maybe scaling, so up to 3 params each
%{'None' 'Linear' 'Gaussian' 'Exponential' 'Gamma'};
fhnon = @(x0,x) zeros(size(x));
fhlin = @(x0,x) x * x0(1) + x0(2);
fhgau = @(x0,x) normpdf(x, x0(1), x0(2)) * x0(3);
fhexp = @(x0,x) exp(-x0(1)*x) * x0(3);
fhgam = @(x0,x) exp(-x0(1)*x).*x.^(x0(2)-1) * x0(3); %Ignore normalization because we have scaling
%Gather to one array
fcnhs = {fhnon fhlin fhgau fhexp fhgam};
fhs = fcnhs([opts.fcn.Fcnv]); %Ugly, but so be it
fitfcn = @(x0,x) fhs{1}(x0(1:3),x) + fhs{2}(x0(4:6), x) + fhs{3}(x0(7:9),x);

%Bounds and guesses
lb = cell(1,3);
ub = cell(1,3);
xg = cell(1,3);
for j = 1:3
    switch opts.fcn(j).Fcn
        case 'None'
            lb{j} = [0 0 0];
            ub{j} = [0 0 0];
            xg{j} = [0 0 0];
        case 'Linear'
            lb{j} = [opts.fcn(j).opt1(1) opts.fcn(j).opt2(1) 0];
            ub{j} = [opts.fcn(j).opt1(2) opts.fcn(j).opt2(2) 0];
            xg{j} = [polyfit(xx,yy,1) 0];
        case 'Gaussian'
            lb{j} = [opts.fcn(j).opt1(1) opts.fcn(j).opt2(1) -inf];
            ub{j} = [opts.fcn(j).opt1(2) opts.fcn(j).opt2(2) inf];
            [my, yi] = max(yy);
            xg{j} = [xx(yi) range(xx)/4  my];
        case 'Exponential'
            lb{j} = [opts.fcn(j).opt1(1) 0 -inf];
            ub{j} = [opts.fcn(j).opt1(2) 0 inf];
            [~, yi] = min( abs(yy - (min(yy)+max(yy))/2) ); %Guess : 50% crossing point
            xg{j} = [xx(yi) 0  max(yy)];
        case 'Gamma'
            lb{j} = [opts.fcn(j).opt1(1) opts.fcn(j).opt2(1) -inf];
            ub{j} = [opts.fcn(j).opt1(2) opts.fcn(j).opt2(2) inf];
            [~, yi] = min( abs(yy - (min(yy)+max(yy))/2) ); %Guess : 50% crossing point
            xg{j} = [xx(yi) 2  max(yy)];
        otherwise
            warning('Invalid function %s, using None', opts.fcn(j).Fcn);
    end
end

%Fit
outfit = lsqcurvefit(fitfcn, [xg{:}], xx, yy, [lb{:}], [ub{:}], optimoptions('lsqcurvefit', 'Display', 'off'));

%Add fit
hold(ax, 'on')
outob = plot(ax, xx, fitfcn(outfit, xx), 'Color', 'k', 'LineWidth', 1);

out.ob = outob;
out.ft = outfit;
out.fcn = fitfcn;

end

function out = ezCurveFitOpts()
%Create a popup to choose what analysis method + options to use
%Returns an options struct that is passed to @easyAnalyze

%Make the figure
pxx = 600;
txty = 20;
nrows = 11; %Update this to how many rows used below
pxy = txty*nrows;
boxsz = [pxx,pxy];
%Use this fcn so we can count rows from the top instead of from the bottom
rx = @(x) pxy - x * txty;
%Get screensize so we can center this figure in the screen
ssz = get(0, 'ScreenSize');
ssz = ssz(3:4);
%Need ssz >= boxsz
ssz = max(boxsz, ssz);
fg = figure('Name', 'EasyCurveFit Options', 'Position', [(ssz-boxsz)/2 boxsz]);
col = [0 100 300 400]; %Column positions, we're gonna do [Text Box   Text Box]

%Add stuff to the figure

%Rows 1-3: What function to fit, and the bounds for the params (for now, 2 params max. per.)
optFcn = {'None' 'Linear' 'Gaussian' 'Exponential' 'Gamma'};
params = {{} {'Slope' 'Intercept'} {'Mean' 'SD'} {'Mean'} {'Mean' 'k'}};
%Row 1: Choose first function to fit.
dropFcnL(1)= uicontrol(fg, 'Style', 'text'     , 'Position', [col(1) rx(1) 100 txty], 'String', 'Fit function 1: ', 'HorizontalAlignment', 'right', 'FontSize', 12);
dropFcn(1) = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(2) rx(1) 200 txty], 'String', optFcn, 'Callback', @(x,y)dropFcn_cb(x,y,1));
%Row 2: First function's options
txtFcn1L(1)= uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(2) 100 txty], 'String', ' ', 'HorizontalAlignment', 'right');
txtFcn1(1) = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(2) 200 txty], 'String', ' ');
txtFcn2L(1)= uicontrol(fg, 'Style', 'text', 'Position', [col(3) rx(2) 100 txty], 'String', ' ', 'HorizontalAlignment', 'right');
txtFcn2(1) = uicontrol(fg, 'Style', 'edit', 'Position', [col(4) rx(2) 200 txty], 'String', ' ');

%Row 3: Choose second function to fit.
dropFcnL(2)= uicontrol(fg, 'Style', 'text'     , 'Position', [col(1) rx(3) 100 txty], 'String', 'Fit function 2: ', 'HorizontalAlignment', 'right', 'FontSize', 12);
dropFcn(2) = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(2) rx(3) 200 txty], 'String', optFcn, 'Callback', @(x,y)dropFcn_cb(x,y,2));
%Row 4: options
txtFcn1L(2)= uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(4) 100 txty], 'String', ' ', 'HorizontalAlignment', 'right');
txtFcn1(2) = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(4) 200 txty], 'String', ' ');
txtFcn2L(2)= uicontrol(fg, 'Style', 'text', 'Position', [col(3) rx(4) 100 txty], 'String', ' ', 'HorizontalAlignment', 'right');
txtFcn2(2) = uicontrol(fg, 'Style', 'edit', 'Position', [col(4) rx(4) 200 txty], 'String', ' ');

%Row 5: Choose third function to fit.
dropFcnL(3)= uicontrol(fg, 'Style', 'text'     , 'Position', [col(1) rx(5) 100 txty], 'String', 'Fit function 3: ', 'HorizontalAlignment', 'right', 'FontSize', 12);
dropFcn(3) = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(2) rx(5) 200 txty], 'String', optFcn, 'Callback', @(x,y)dropFcn_cb(x,y,3));
%Row 6: options
txtFcn1L(3)= uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(6) 100 txty], 'String', ' ', 'HorizontalAlignment', 'right');
txtFcn1(3) = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(6) 200 txty], 'String', ' ');
txtFcn2L(3)= uicontrol(fg, 'Style', 'text', 'Position', [col(3) rx(6) 100 txty], 'String', ' ', 'HorizontalAlignment', 'right');
txtFcn2(3) = uicontrol(fg, 'Style', 'edit', 'Position', [col(4) rx(6) 200 txty], 'String', ' ');

%Row 7: Fitting bdys
xbdytype = {'All', 'Current view', 'Custom'};
xbdyFcnL = uicontrol(fg, 'Style', 'text'     , 'Position', [col(1) rx(7) 100 txty], 'String', 'X Boundary: ', 'HorizontalAlignment', 'right', 'FontSize', 12);
xbdyFcn  = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(2) rx(7) 200 txty], 'String', xbdytype, 'Callback', @dropBdy_cb);
%Row 8: Fitting bdy options
txtxbdyL = uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(8) 100 txty], 'String', ' ', 'HorizontalAlignment', 'right');
txtxbdy  = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(8) 200 txty], 'String', ' ');

%Row 9/10/11: OK to exit, plus blurb
txtButOK  = uicontrol(fg, 'Style', 'pushbutton', 'Position', [col(4)+100 rx(11) 100 txty*3], 'String', 'Ok', 'Callback', @(~,~)uiresume(fg));
% txtBlurb  = uicontrol(fg, 'Style', 'text', 'Position', [0 rx(11) col(4)+100 txty*3], 'String', 'Comment');

%Wait for person to press the OK button, which calls uiresume
uiwait(fg)

%If exited with X, fg is deleted, so exit
if ~isgraphics(fg)
    out = [];
    return
end

%Then grab, return output
for i = 3:-1:1
    tmp.Fcn = optFcn{dropFcn(i).Value};
    tmp.Fcnv = dropFcn(i).Value;
    tmp.opt1 = str2num(txtFcn1(1).String); %#ok<*ST2NM>
    tmp.opt2 = str2num(txtFcn2(1).String);
    out.fcn(i) = tmp;
end
out.xlim.typ = xbdytype{xbdyFcn.Value};
out.xlim.opt = str2num(txtxbdy.String);

%And we're done
delete(fg)

%Callbacks
    function dropFcn_cb(src,~,ind)
        switch src.Value
            case 1 %None
                txtFcn1L(ind).String = '';
                txtFcn1(ind).String = '';
                txtFcn2L(ind).String = '';
                txtFcn2(ind).String = '';
                txtFcn1(ind).Enable = 'off';
                txtFcn2(ind).Enable = 'off';
            case 2 %Linear
                txtFcn1L(ind).String = 'Slope';
                txtFcn1(ind).String = '[-inf inf]';
                txtFcn2L(ind).String = 'Intercerpt';
                txtFcn2(ind).String = '[-inf inf]';
                txtFcn1(ind).Enable = 'on';
                txtFcn2(ind).Enable = 'on';
            case 3 %Gaussian
                txtFcn1L(ind).String = 'Mean';
                txtFcn1(ind).String = '[-inf inf]';
                txtFcn2L(ind).String = 'SD';
                txtFcn2(ind).String = '[-inf inf]';
                txtFcn1(ind).Enable = 'on';
                txtFcn2(ind).Enable = 'on';
            case 4 %Exponential
                txtFcn1L(ind).String = 'Mean';
                txtFcn1(ind).String = '[-inf inf]';
                txtFcn2L(ind).String = '';
                txtFcn2(ind).String = '';
                txtFcn1(ind).Enable = 'on';
                txtFcn2(ind).Enable = 'off';
            case 5 %Gamma
                txtFcn1L(ind).String = 'Mean';
                txtFcn1(ind).String = '[-inf inf]';
                txtFcn2L(ind).String = 'Shape';
                txtFcn2(ind).String = '[0 inf]';
                txtFcn1(ind).Enable = 'on';
                txtFcn2(ind).Enable = 'on';
            otherwise
                warning('Invalid fit function case %d', src.Value)
        end
        
    end

    function dropBdy_cb(src,~)
        switch src.Value
            case 1 %All
                txtxbdyL.String = '';
                txtxbdy.String = '';
                txtxbdy.Enable = 'off';
            case 2 %Current view
                txtxbdyL.String = '';
                txtxbdy.String = '';
                txtxbdy.Enable = 'off';
            case 3 %Custom
                txtxbdyL.String = 'X Limits:';
                txtxbdy.String = '[-inf inf]';
                txtxbdy.Enable = 'on';
            otherwise
                warning('Invalid x boundary case %d', src.Value)
        end
        
    end

end

