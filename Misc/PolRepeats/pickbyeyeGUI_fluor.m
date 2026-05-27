function pickbyeyeGUI_fluor(dat)
%Pick by eye 
%Based on RPpickbyeyeGUI
% For fluorescence crossing data

%Need to provide inst, the output of @procFran
if nargin < 1
    return
end

%Options
fil = 50; %Filtering amount
Fs=800; %Fsamp
rulerdat = [ 59 64 8]; %Ruler pause position, repeat period, num repeats
guidelines = [558 631 704]-16; %Guidelines, here Nuc Entry/Dyad/Exit
% guidelines = [ 756   829   902];

flint = 1e3; %Integration for fluorescence
fldsamp = 1e2; %Downsampling for fluorescence
flFs = 1e3; %Fluorescence Fsamp

%Declare variables
set = 1; %Index of current dataset, i.e. dat(set).drA(num)
num = 1; %Index of current file, i.e. dat(set).drA(num)
nset = length(dat);
lens = arrayfun(@(x) length(x.drA), dat);
len = lens(set);

%Add tf fields if they don't exist. Let's use convention that these == 1 if we want to keep them, so let's keep all by default
if ~isfield(dat, 'tfpick')
    for i = 1:nset
        dat(i).tfpick = true(1, lens(i));
    end
end

%Default button labels. Will show but1lab{1} if tfpbe1 == 0, {2} if == 1
but1lab = {'Un-Reject' 'Reject'};
but1blab = {'Mark Crossed' 'Mark Not Crossed'};
but1txt = { 'Rejected' 'Kept' };
but1btxt = { 'Not Crossed' 'Crossed Nuc' };

%Make figure
ssz = get(groot, 'ScreenSize');
fg = figure('Position', ssz + [ssz(3:4)/10 -ssz(3:4)/5], 'Color', [1 1 1], 'CloseRequestFcn', @(x,y)addwkspc([],[],1));
ax1a = subplot2(fg, [2 5], [1 3]); %RTH
ax1b = subplot2(fg, [2 5], [2 4]); %Fluor
ax2 = subplot2(fg, [1 5], [3 4]); %con-tim

hold(ax1a, 'on')
hold(ax1b, 'on')
hold(ax2, 'on')
linkaxes([ax1a, ax1b], 'x')

%Set labels
xlabel(ax2, 'Time (s)')
ylabel(ax2, 'Extension (bp)')
xlabel(ax1a, 'Extension (bp)')
ylabel(ax1a, 'RTH (s/bp)')
xlabel(ax1b, 'Extension (bp)')
ylabel(ax1b, 'Fluorescence (kHz)')


%UIcontrols. Put them in the empty quadrant, top-right
numtext = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.05, .925, .7, .075], 'String', '0/0', 'BackgroundColor', [.99 .99 .99], 'FontSize', 16 );
butlef0= uicontrol( 'Units', 'normalized', 'Position', [.8, .9, .1, .1],       'String', 'Dataset <<', 'Callback',@(x,y)cycleData(x,y,-2) );
butrig0= uicontrol( 'Units', 'normalized', 'Position', [.8+.1, .9, .1, .1],       'String', 'Dataset >>', 'Callback',@(x,y)cycleData(x,y,+2) );

uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.8, .1, .1, .05], 'String', 'RTH YLims', 'BackgroundColor', [.99 .99 .99], 'FontSize', 12 )
txtax2yl = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [.8, .15, .1, .05], 'String', '[ 0 3 ]', 'BackgroundColor', [.99 .99 .99], 'FontSize', 16 );
uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.8, .0, .1, .05], 'String', 'Fluor [Backg, Single]', 'BackgroundColor', [.99 .99 .99], 'FontSize', 12 )
txtax2y2 = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [.8, .05, .1, .05], 'String', '[ 50 140 ]', 'BackgroundColor', [.99 .99 .99], 'FontSize', 16 );

butlef = uicontrol( 'Units', 'normalized', 'Position', [.8, .8, .1, .1],       'String', 'Trace <<', 'Callback',@(x,y)cycleData(x,y,-1) );
butrig = uicontrol( 'Units', 'normalized', 'Position', [.8+.1, .8, .1, .1],       'String', 'Trace >>', 'Callback',@(x,y)cycleData(x,y,+1) );
%Pick/cross
but1   = uicontrol( 'Units', 'normalized', 'Position', [.8, .7, .1, .05],       'String', but1lab{2}, 'Callback',@but1_cb );
but1b   = uicontrol( 'Units', 'normalized', 'Position', [.8, .75, .1, .05],       'String', but1blab{1}, 'Callback',@but1b_cb );
%
but2   = uicontrol( 'Units', 'normalized', 'Position', [.9, .75, .1, .05],       'String', 'Shift Up ^^', 'Callback',@but2_cb );
but3   =  uicontrol( 'Units', 'normalized', 'Position', [.9, .70, .1, .05],       'String', 'Shift Down vv', 'Callback',@but3_cb );
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
        if abs(d) > 1.5 %+/- 2 is change dataset. Also reset num here
            set =  mod( set-1+sign(d), nset ) + 1;
            len = lens(set);
            num = 1;
        else %+/- 1 is change num
            num = mod( num-1+sign(d), len ) + 1;
        end
        
        if isfield(dat, 'file')
            fnam = dat(set).file{num};
        else
            fnam = [];
        end
        
        if isfield(dat, 'cmt')
            cmt = dat(set).cmt{num};
        else
            cmt = [];
        end
        
        %Name figure
        fg.Name = sprintf('%s: %s', dat(set).nam , fnam);
        
        numtext.String = sprintf('Dataset %s: %s (%d/%d), Trace %d/%d: %s, %s\n%s', dat(set).nam, fnam, set, nset, num, len, but1txt{dat(set).tfpick(num) + 1}, but1btxt{dat(set).tfc(num) + 1}, cmt);
        %Get data
        ext = dat(set).drA{num};
        %Create time
        tim = (1:length(ext))/Fs;
        
        %Calculate individual and group RTHs. Use Crossers and Picks only
        [yy, xx] = sumNucHist( dat(set).drA( dat(set).tfc &  dat(set).tfpick ), struct('verbose', 0) );
        rthall = [xx(:) yy(:)];
        [yy, xx] = sumNucHist( dat(set).drA(num) , struct('verbose', 0));
        rth = [xx(:) yy(:)];
        
        %Plot the Con-Tim above, with guidelines
        cla(ax2)
        
        %Convert fluorescence to # Cy3s
        %Integrate fl, convert to Hz
        fl = windowFilter(@mean, double( dat(set).fl{num}.apd1 ), round(flint/2), 1) * ( round(flint/2)*2+1) * flFs / 1e3;
       
        %Get background, count per cy3 from text box. Maybe do this programmatically at some point later
        fllines = str2num(txtax2y2.String); %#ok<ST2NM>
        flnn = round( abs(fl-fllines(1))  / fllines(2) );
        
        %Match sampling via interp1
        tt = linspace(1, length(fl), length(ext)+1);
        tt = (tt(1:end-1)+tt(2:end) ) /2;
        nf = interp1( 1:length(fl), flnn, tt );
        nf = round(nf);
        
%         plot(ax2, windowFilter(@median, tim, fil, 1), windowFilter(@median, ext, fil, 1));
        tf = windowFilter(@median, tim, fil, 1);
        xf = windowFilter(@median, ext, fil, 1);
        surface(ax2, [tf; tf], [xf; xf], [nf; nf], 'EdgeColor', 'interp')
        
        
        nfl = 2; %Number of fluorophores max
        ax2.CLim = [0 2];
        cmap = [zeros(nfl+1, 1) linspace(0,1,nfl+1)', zeros(nfl+1,1)];
        colormap(ax2, cmap);
        
        
        %Guidelines for pauses
        for ii = 1:rulerdat(3)
            plot(ax2, [0 tim(end)] , (rulerdat(1) + rulerdat(2) * (ii-1)) * [1 1], 'k', 'LineWidth', 1)
        end
        %Nuc Entry/Dyad/Exit
        for ii = 1:length(guidelines)
            plot(ax2, [0 tim(end)] , guidelines(ii) * [1 1]);
        end
        
        axis(ax2, 'tight')
        
        %Plot RTHs
        cla(ax1a)
        plot(ax1a, rth(:,1), rth(:,2), 'LineWidth', 2)
        plot(ax1a, rthall(:,1), rthall(:,2), 'k', 'LineWidth', 2)
        
        %Plot fluorescence-extension
        cla(ax1b)
        flx = double( dat(set).drA{num} );
%         fl = double( dat(set).fl{num}.apd1 );
        
        %Integrate fl, convert to Hz
%         fl = windowFilter(@mean, fl, round(flint/2), 1) * flint * flFs / 1e3;
        
        %Filter extension to match
        extfil = round(length(flx)/length(fl) * flint /2);
        flx = windowFilter(@mean, flx, extfil, 1);
        
        %Match sampling via interp1
        tt = linspace(1, length(flx), length(fl)+1);
        tt = (tt(1:end-1)+tt(2:end) ) /2;
        flx = interp1( 1:length(flx), flx, tt );
        
        %Downsample
        fl = fl(1:fldsamp:end);
        flx = flx(1:fldsamp:end);
        
        plot(ax1b, flx, fl, 'o');
        
        %Add fluorescence guidelines (dotted)
%         maxmin = [min(flx) max(flx)];
        maxmin = [min(guidelines) max(guidelines)] + [-10 10];
        for j = 0:nfl
            plot(ax1b, maxmin, fllines(1) + j*fllines(2) * [1 1], 'k--')
        end
        
        
        legend(ax1a, {'Trace RTH' 'Average RTH'}, 'Location', 'southeast')
        
        axis(ax1a, 'tight')
        
        %Set lims
        xlim(ax1a, [ min(guidelines) max(guidelines)] + [-10 10]);
        
        ylim(ax1a, str2num(txtax2yl.String)); %#ok<ST2NM>
        
        ylim(ax2, [ min(guidelines) max(guidelines)] + [-10 10]);
        
        %Set button strings
        but1.String = but1lab{ dat(set).tfpick(num) + 1 };
        but1b.String = but1blab{ dat(set).tfc(num) + 1 };
    end

    function but1_cb(~,~)
        %Negate tfpbe1 and set string
        dat(set).tfpick(num) = ~dat(set).tfpick(num);
        but1.String = but1lab{ dat(set).tfpick(num) + 1 };
        cycleData([],[],0)
    end

    function but1b_cb(~,~)
        %Negate tfpbe1 and set string
        dat(set).tfc(num) = ~dat(set).tfc(num);
        but1b.String = but1lab{ dat(set).tfpick(num) + 1 };
        cycleData([],[],0)
    end

    function but2_cb(~,~)
        %Shift up. Shift... just drA? raw too? Raw might be different size, so don't do this
%         dat(set).raw{num} = dat(set).raw{num} + rulerdat(2);
        dat(set).drA{num} = dat(set).drA{num} + rulerdat(2);
        cycleData([],[],0)
    end

    function but3_cb(~,~)
        %Shift down. 
%         dat(set).raw{num} = dat(set).raw{num} - rulerdat(2);
        dat(set).drA{num} = dat(set).drA{num} - rulerdat(2);
        cycleData([],[],0)
    end

    function addwkspc(~,~,tfclose)
        %Assign to workspace, on button press or on exit
        assignin('base', sprintf('RepPickGUI_%s', datestr(datetime('now'), 'HHMM')), dat)
        if tfclose
            delete(fg)
        end
    end

end