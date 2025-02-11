function ezFactGUI(inst)
%Pick by eye 
%Based on getResByHanGUI

%Need to provide inst, the output of @RP
if nargin < 1
    return
end

%Just rename inst for ... reasons
dat = inst(1);
len = length(dat.drA);

%Add tf fields if they don't exist. Let's use convention that these == 1 if we want to keep them, so let's keep all by default
if ~isfield(dat, 'tfpbe')
    dat.tfpick = ones(1, len);
end

%Declare variables
num = 1; %Index of current file
Fs= 1e3;
per = 64; %Ruler periodicity

%Button labels
but0lab = {'Shift down' 'Shift up'};
but1lab = {'Reject' 'Keep'};
but2lab = {'Crop early' 'Crop end'};

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

but0n    = uicontrol( 'Units', 'normalized', 'Position', [.525+.3, .55, .15, .1],  'String', but0lab{1}, 'Callback',@(x,y)but0_cb(x,y,-1) );
but0y    = uicontrol( 'Units', 'normalized', 'Position', [.525+.3, .65, .15, .1],  'String', but0lab{2}, 'Callback',@(x,y)but0_cb(x,y,+1) );
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
yruler = 59 + (0:7)*per; %RulerAlign y-values
ynuc = [558 631 704]-16; %Nucleosome region


%Load first data
cycleData([],[],0)

    function cycleData(~,~,d)
        %Change to the next data, +1 or -1 depending on d
        num = mod( num-1+d, length(dat.drA) ) + 1;
        
        fg.Name =  ''; %sprintf('Trace %s%s', dat(num).name);
        numtext.String = sprintf('%d/%d', num, length(dat.drA));
        
        %Get data
        ext = dat.drA{num};
%         frc = dat.drA(num).frc;
        tim = (1:length(ext)) / Fs;
        
        if isfield(inst, 'xwlc')
            xwlc = inst(num).xwlc(1:2);
        end
%         con = ext ./ XWLC(frc, xwlc(1), xwlc(2));
        con = [];
        
        %Filter
        tf = windowFilter(@mean, tim, [], 100);
%         cf = windowFilter(@mean, con, [], 100);
        xf = windowFilter(@mean, ext, [], 100);
        
        %Crop contour graph to highest force
        [~, maxi] = max(tf);
        
        
        %Plot ext above
        cla(ax1)
        plot(ax1, tf, xf);
        %Add ruler pause locations
        arrayfun(@(x) plot(ax1, tf([1 end]), x * [1 1], 'b'), yruler)
        arrayfun(@(x) plot(ax1, tf([1 end]), x * [1 1], 'g'), ynuc)
        axis(ax1, 'tight')
        
        
        
        %Plot zoom of nuc below
        cla(ax2)
        icr = find(xf > ynuc(1), 1, 'first');
        if isempty(icr)
            return
        end
        tf = tf(icr:end);
        xf = xf(icr:end);
        plot(ax2, tf, xf);
        %Add ruler pause locations
        arrayfun(@(x) plot(ax2, tf([1 end]), x * [1 1], 'g'), ynuc)
        axis(ax2, 'tight')
        
        
    end

    function but1_cb(~,~,tf)
        %Set tfpbe
        dat.tfpick(num) = tf;
%         nameFigure
    end

    function but2_cb(~,~,tf)
        %Crop
        x = ginput(1);
        x = x(1);
        tim = (1:length(dat.drA{num})) / Fs;
        
        if tf
            %Crop end
            ki = tim <= x;
            dat.drA{num} = dat.drA{num}(ki);
        else
            %Crop early
            ki = tim >= x;
            dat.drA{num} = dat.drA{num}(ki);
        end
        cycleData([],[],0);
        
    end

    function but0_cb(~,~, shiftdir)
        %Shift up/down
        dat.drA{num} = dat.drA{num} + per * shiftdir;
        cycleData([],[],0);
    end



    function addwkspc(~,~,tfclose)
        %Assign to workspace, on button press or on exit
        assignin('base', sprintf('RPpickGUI_%s', datestr(datetime('now'), 'HHMM')), dat)
        if tfclose
            delete(fg)
        end
    end

end