function TxPullGUI(inst)
%Pick by eye 
%Based on getResByHanGUI

%Need to provide inst, the output of @RP
if nargin < 1
    return
end

%Just rename inst for ... reasons
dat = inst;

%Add tf fields if they don't exist. Let's use convention that these == 1 if we want to keep them, so let's keep all by default
if ~isfield(dat, 'tfpbe1')
    [dat.tfpbe1] = deal(nan);
end

if ~isfield(dat, 'tfpbe2')
    [dat.tfpbe2] = deal(nan);
end
% Lets just use tfpbe1 as the marker... initialize as nan

%Declare variables
num = 1; %Index of current file

%Default button labels. Will show but1lab{1} if tfpbe1 == 0, {2} if == 1
but1lab = {'No LF' 'Has LF'};
but2lab = {'No HF' 'Has HF'};

%Make figure
ssz = get(groot, 'ScreenSize');
fg = figure('Position', ssz + [ssz(3:4)/10 -ssz(3:4)/5], 'Color', [1 1 1], 'CloseRequestFcn', @(x,y)addwkspc([],[],1));
ax1 = subplot2(fg, [2 2], 1);
ax2 = subplot2(fg, [2 2], [2 4]);
hold(ax1, 'on')
hold(ax2, 'on')
%Set labels
xlabel(ax1, 'Extension (nm)')
ylabel(ax1, 'Force (pN)')
xlabel(ax2, 'Time (pts)')
ylabel(ax2, 'Protein Contour (nm)')

%UIcontrols. Put them in the empty quadrant, top-right
numtext = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.525, .70, .15, .2], 'String', '0/0', 'Callback',@(x,y)cycleData(x,y,-1) );
butlef = uicontrol( 'Units', 'normalized', 'Position', [.525+.15, .75, .15, .2],       'String', '<', 'Callback',@(x,y)cycleData(x,y,-1) );
butrig = uicontrol( 'Units', 'normalized', 'Position', [.525+.3, .75, .15, .2],       'String', '>', 'Callback',@(x,y)cycleData(x,y,+1) );

but0    = uicontrol( 'Units', 'normalized', 'Position', [.525+.3, .55, .15, .2],  'String', 'Reject', 'Callback',@butn_cb );
but1n   = uicontrol( 'Units', 'normalized', 'Position', [.525, .55, .15, .1],     'String', but1lab{1}, 'Callback',@(x,y)but1_cb(x,y,0) );
but1y   = uicontrol( 'Units', 'normalized', 'Position', [.525, .65, .15, .1],     'String', but1lab{2}, 'Callback',@(x,y)but1_cb(x,y,1) );
but2n   = uicontrol( 'Units', 'normalized', 'Position', [.525+.15, .55, .15, .1], 'String', but2lab{1}, 'Callback',@(x,y)but2_cb(x,y,0) );
but2y   = uicontrol( 'Units', 'normalized', 'Position', [.525+.15, .65, .15, .1], 'String', but2lab{2}, 'Callback',@(x,y)but2_cb(x,y,1) );

% Backup uicontrols: in the top bar instead
% numtext = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.05, .90, .05, .05], 'String', '0/0', 'Callback',@(x,y)cycleData(x,y,-1) );
% butlef = uicontrol( 'Units', 'normalized', 'Position', [.1, .90, .05, .05],       'String', '<', 'Callback',@(x,y)cycleData(x,y,-1) );
% butrig = uicontrol( 'Units', 'normalized', 'Position', [.15, .90, .05, .05],       'String', '>', 'Callback',@(x,y)cycleData(x,y,+1) );
% but1   = uicontrol( 'Units', 'normalized', 'Position', [.25, .90, .25, .05],       'String', but1lab{2}, 'Callback',@but1_cb );
% but2   = uicontrol( 'Units', 'normalized', 'Position', [.60, .90, .25, .05],       'String', but2lab{2}, 'Callback',@but2_cb );

%Set some constants (options)
xl = [1.5 45]; %X lim for plotting
fcen = 7; %Force to zero at

%XWLC params. Estimate with TxPull_XWLC, e.g.
handletype = 2;
switch handletype
    case 1
        xwlc = [48 1340]; %For 4kb handles
        fprintf('Using XWLC guess for 4kb handle expt\n')
    case 2
        xwlc = [55 397]; %For 2kb handles
        fprintf('Using XWLC guess for 2kb handle expt\n')
end
%Load first data
cycleData([],[],0)

    function cycleData(~,~,d)
        %Change to the next data, +1 or -1 depending on d
        num = mod( num-1+d, length(dat) ) + 1;
        
        fg.Name = sprintf('Trace %s%s', dat(num).name);
        numtext.String = sprintf('%d/%d', num, length(dat));
        
        %Get data
        ext = dat(num).ext;
        frc = dat(num).frc;
        
        if isfield(inst, 'xwlc')
            xwlc = inst(num).xwlc(1:2);
        end
        con = ext ./ XWLC(frc, xwlc(1), xwlc(2));
        
        %Filter
        ff = windowFilter(@mean, frc, [], 100);
        cf = windowFilter(@mean, con, [], 100);
        xf = windowFilter(@mean, ext, [], 100);
        
        %Crop contour graph to highest force
        [~, maxi] = max(ff);
        
        
        %Plot raw force-ext above
        cla(ax1)
        plot(ax1, xf, ff);
        %Maybe plot with time as color? code example below
%         surface(mainAxis, [timF;timF],[frcF;frcF],zeros(2,length(timF)),[timF;timF], 'edgecol', 'interp');
        axis(ax1, 'tight')
        
        %Plot contour-force below
        cla(ax2)
        plot(ax2, ff(1:maxi), cf(1:maxi) );
        
        %Set lims
        xlim(ax2, xl)
        %Dynamic y-lim based on crossing pt of y=fcen
        y0 = cf(find(ff > fcen, 1, 'first'));
        if isempty(y0)
            %Fallback, just set to median
            y0 = median(cf);
        end
        ylim(ax2, y0 + [-30 30])
        
        
%         %Set button strings
%         but1.String = but1lab{ dat(num).tfpbe1 + 1 };
%         but2.String = but2lab{ dat(num).tfpbe2 + 1 };
        
        %Set title for ax2 based on tfpbe
        nameFigure;
    end

    function but1_cb(~,~,tf)
        %Set as tfpbe1
        dat(num).tfpbe1 = tf;
        nameFigure
    end

    function but2_cb(~,~,tf)
        %Set as tfpbe2
        dat(num).tfpbe2 = tf;
        nameFigure
    end

    function butn_cb(~,~)
        %Reject = set nan
        dat(num).tfpbe2 = nan;
        dat(num).tfpbe2 = nan;
        nameFigure
    end

    function nameFigure()
        %State nucleosome state based on tfpbe1/2
        t1 = dat(num).tfpbe1;
        t2 = dat(num).tfpbe2;
        
        outcomes = { 'Bare DNA' 'Tet' 'Hex' 'Nuc' };
        if ~isnan(t1) && ~isnan(t2)
            str = outcomes{ t1 + t2*2 +1};
        else
            str = 'Not assigned / Rejected';
        end
        
        %Name figure
        title(ax2, str)
        
    end

    function addwkspc(~,~,tfclose)
        %Assign to workspace, on button press or on exit
        assignin('base', sprintf('RPpickGUI_%s', datestr(datetime('now'), 'HHMM')), dat)
        if tfclose
            delete(fg)
        end
    end

end