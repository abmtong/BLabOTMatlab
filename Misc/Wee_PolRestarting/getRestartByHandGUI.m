function getRestartByHandGUI(inst)

%getResByHan but now with a persistent GUI

%Think of it kind of like a measure gui?


%Declare variables
dat = []; %Will hold the data in dat, has fields {f, c, fa, fb, name [trace], ind [crop inds], islong [censoring], frc [force]}
num = 1; %Index of current file
cropLines = [];

%Options
sm = 10; %Smoothing options
% ywid = 200;

if nargin
    dat = inst;
end

%Make figure
ssz = get(groot, 'ScreenSize');
fg = figure('Position', ssz + [ssz(3:4)/10 -ssz(3:4)/5], 'CloseRequestFcn', @(x,y)addwkspc([],[],1));
ax1 = subplot2(fg, [3 1], [1 2]);
ax2 = subplot2(fg, [3 1], 3);
linkaxes([ax1, ax2], 'x')
hold(ax2,'on');

%UIcontrols
numtext = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.05, .90, .05, .05],       'String', '0/0', 'Callback',@(x,y)cycleData(x,y,-1) );
%Make buttons
butlef = uicontrol( 'Units', 'normalized', 'Position', [.1, .90, .05, .05],       'String', '<', 'Callback',@(x,y)cycleData(x,y,-1) );
butrig = uicontrol( 'Units', 'normalized', 'Position', [.15, .90, .05, .05],       'String', '>', 'Callback',@(x,y)cycleData(x,y,+1) );
butcrop= uicontrol( 'Units', 'normalized', 'Position', [.25, .90, .05, .05],       'String', 'Crop', 'Callback',@cropit );
butcens= uicontrol( 'Units', 'normalized', 'Position', [.30, .90, .05, .05],       'String', 'Censor', 'Callback',@censorit );


%If no inst passed, select files
if isempty(dat)
    [f, p] = uigetfile('D:\Data\%OthersData\Wee_Misincorporation\Data\*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    infp = cellfun(@(x) fullfile(p, x), f, 'Un', 0);
    
    %And load them
    for i = 1:length(infp)
        sd = load(infp{i});
        sd = sd.stepdata;
        fr = smooth([sd.force{:}], sm)';
        cn = smooth([sd.contour{:}],sm)';
        fa = smooth([sd.forceAX{:}],sm)';
        fb = smooth(-[sd.forceBX{:}],sm)';
        [~, nam, ~] = fileparts(infp{i});
        dat = [dat struct('nam', nam, 'f', fr, 'c', cn, 'a', fa, 'b', fb, 'ind', zeros(0,2), 'islong', [], 'frc', [], 'cmt', sd.comment)]; %#ok<AGROW>
    end
end

%Load first data
cycleData([],[],0)


    function cycleData(~,~,d)
        %Change to the next data, +1 or -1 depending on d
        num = mod( num-1+d, length(dat) ) + 1;
        %Extract trace from dat
        fg.Name = sprintf('%s - %s', dat(num).nam, dat(num).cmt);
        numtext.String = sprintf('%d/%d', num, length(dat));
        c = dat(num).c;
        fax = dat(num).a;
        fbx = dat(num).b;
        %Plot the trace above, force X below
        cla(ax1)
        cla(ax2)
        plot(ax1, c);
        drawnow
        axis tight
        plot(ax2, fax);
        plot(ax2, fbx);
        wid = length(c);
        xlim([0 wid*1.05])
        
        plotCrop
        
        %Maybe call crop automatically if there isn't one?
    end

    function plotCrop(~,~)
        delete(cropLines)
        %Check if a crop exists, if so, plot
        if ~isempty(dat(num).ind)
            xx = dat(num).ind;
            l1 = line(ax1, xx(1) * [1 1], ylim(ax1));
            l3 = line(ax2, xx(1) * [1 1], ylim(ax2));
            %If the right edge is censored, plot the line as red
            if dat(num).islong;
                l2 = line(ax1, xx(2) * [1 1], ylim(ax1), 'Color', 'r');
                l4 = line(ax2, xx(2) * [1 1], ylim(ax2), 'Color', 'r');
            else
                l2 = line(ax1, xx(2) * [1 1], ylim(ax1));
                l4 = line(ax2, xx(2) * [1 1], ylim(ax2));
            end
            cropLines = [l1 l2 l3 l4];
        end
        
    end

    function cropit(~,~)
        %Crop it
        [a, ~] = ginput(2);
        a = round(a);
        a = max(a,1);
        %Choose reverse to ignore/remove (i.e. ambiguous)
        if ~issorted(a)
            dat(num).islong = [];
            dat(num).ind = [];
            dat(num).frc = [];
        else %Assign crop
            %If a point is chosen after the end, acknowledge
            if a(2) > length(dat(num).c)
                a(2) = length(dat(num).c);
                dat(num).islong = 1;
            else
                dat(num).islong = 0;
            end
            dat(num).frc = mean( dat(num).f(a(1):a(end)) );
            dat(num).ind = a;
        end
        plotCrop
    end

% %Crops to just change one end
%     function cropleft(~,~)
%         
%         plotCrop
%     end
% 
%     function cropright(~,~)
%         
%         plotCrop
%     end

%Add a manual censoring toggle, for e.g. broken tethers
    function censorit(~,~)
        dat(num).islong = ~dat(num).islong;
        plotCrop
    end

    function addwkspc(~,~,tfclose)
        %Assign to workspace, on button press or on exit
        assignin('base', sprintf('grbh%s', datestr(datetime('now'), 'HHMM')), dat)
        if tfclose
            delete(fg)
        end
    end

end