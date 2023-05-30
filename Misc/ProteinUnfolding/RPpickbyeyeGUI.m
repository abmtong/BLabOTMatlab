function RPpickbyeyeGUI(inst)
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
    [dat.tfpbe1] = deal(1);
end
if ~isfield(dat, 'tfpbe2')
    [dat.tfpbe2] = deal(1);
end

%Declare variables
num = 1; %Index of current file

%Options
smfx = 50; %Smoothing option for F-X
smcon = 10; %Smoothing option for contour-time
ymark = [0 9 18 40]; %Draw lines on these contour locations
conxwid = [-1000 400]; %Number of points to plot around rip

%Default button labels. Will show but1lab{1} if tfpbe1 == 0, {2} if == 1
but1lab = {'Un-Reject (Bad cycle)' 'Reject (Bad cycle)'};
but2lab = {'Un-Reject (Cherrypick)' 'Reject (Cherrypick)'};

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
but1   = uicontrol( 'Units', 'normalized', 'Position', [.525, .55, .20, .2],       'String', but1lab{2}, 'Callback',@but1_cb );
but2   = uicontrol( 'Units', 'normalized', 'Position', [.525+.25, .55, .20, .2],       'String', but2lab{2}, 'Callback',@but2_cb );

% Backup uicontrols: in the top bar instead
% numtext = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.05, .90, .05, .05], 'String', '0/0', 'Callback',@(x,y)cycleData(x,y,-1) );
% butlef = uicontrol( 'Units', 'normalized', 'Position', [.1, .90, .05, .05],       'String', '<', 'Callback',@(x,y)cycleData(x,y,-1) );
% butrig = uicontrol( 'Units', 'normalized', 'Position', [.15, .90, .05, .05],       'String', '>', 'Callback',@(x,y)cycleData(x,y,+1) );
% but1   = uicontrol( 'Units', 'normalized', 'Position', [.25, .90, .25, .05],       'String', but1lab{2}, 'Callback',@but1_cb );
% but2   = uicontrol( 'Units', 'normalized', 'Position', [.60, .90, .25, .05],       'String', but2lab{2}, 'Callback',@but2_cb );

%Load first data
cycleData([],[],0)

    function cycleData(~,~,d)
        %Change to the next data, +1 or -1 depending on d
        num = mod( num-1+d, length(dat) ) + 1;
        %Name figure
        if isfield(dat, 'file')
            fg.Name = sprintf('Cycle %03d (%s)', num, dat(num).file);
        else
            fg.Name = sprintf('Cycle %03d', num);
        end
        numtext.String = sprintf('%d/%d', num, length(dat));
        %Get data
        ext = dat(num).ext;
        frc = dat(num).frc;
        con = dat(num).conpro;
        %Plot the F-X trace above, with fits
        cla(ax1)
        plot(ax1, windowFilter(@mean, ext, smfx, 1), windowFilter(@mean, frc, smfx, 1));
        ff = linspace( 2, max(frc), 100 ); %Hard code minimum F for XWLC
        xwlcft = dat(num).xwlcft;
        plot(ax1, XWLC(ff, xwlcft(1), xwlcft(2)) * xwlcft(3) , ff );
        plot(ax1, XWLC(ff, xwlcft(1), xwlcft(2)) * xwlcft(3) + XWLC(ff, xwlcft(6), inf) * xwlcft(7) , ff );
        legend(ax1, {'F-X data' 'DNA Fit' 'DNA+Protein fit'})
        axis tight
        %And the contour below
        cla(ax2)
        plot(ax2, (1:length(con))-dat(num).ripind , windowFilter(@mean, con, smcon, 1));
        axis tight
        xl = xlim(ax2);
        %Add marker lines for start/end
        arrayfun(@(x) plot(ax2, xl, x * [1 1], 'k'), ymark)
        %Zoom to around rip location
        xlim( conxwid );
        
        %Set button strings
        but1.String = but1lab{ dat(num).tfpbe1 + 1 };
        but2.String = but2lab{ dat(num).tfpbe2 + 1 };
        
        
    end

    function but1_cb(~,~)
        %Negate tfpbe1 and set string
        dat(num).tfpbe1 = ~dat(num).tfpbe1;
        but1.String = but1lab{ dat(num).tfpbe1 + 1 };
    end

    function but2_cb(~,~)
        %Negate tfpbe2 and set string
        dat(num).tfpbe2 = ~dat(num).tfpbe2;
        but2.String = but2lab{ dat(num).tfpbe2 + 1 };
    end

    function addwkspc(~,~,tfclose)
        %Assign to workspace, on button press or on exit
        assignin('base', sprintf('RPpickGUI_%s', datestr(datetime('now'), 'HHMM')), dat)
        if tfclose
            delete(fg)
        end
    end

end