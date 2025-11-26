function TxPullV2GUI(inst)
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

%Declare variables
num = 1; %Index of current file

%Make figure
ssz = get(groot, 'ScreenSize');
fg = figure('Position', ssz + [ssz(3:4)/10 -ssz(3:4)/5], 'Color', [1 1 1], 'CloseRequestFcn', @(x,y)addwkspc([],[],1));
ax1 = axes(fg, 'Position', [.1 .1 .8 .7]);
% ax2 = subplot2(fg, [2 2], [2 4]);
hold(ax1, 'on')
% hold(ax2, 'on')
%Set labels
xlabel(ax1, 'Extension (nm)')
ylabel(ax1, 'Force (pN)')
% xlabel(ax2, 'Time (pts)')
% ylabel(ax2, 'Protein Contour (nm)')

%UIcontrols. Put them in the empty quadrant, top-right
numtext = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.1 .9 .1 .1], 'String', '0/0', 'Callback',@(x,y)cycleData(x,y,-1) );
xwlctext = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.4 .9 .4 .1], 'FontSize', 14', 'String', 'XWLC' );

butlef = uicontrol( 'Units', 'normalized', 'Position', [.2 .90 .1 .1],       'String', '<', 'Callback',@(x,y)cycleData(x,y,-1) );
butrig = uicontrol( 'Units', 'normalized', 'Position', [.3 .90 .1 .1],       'String', '>', 'Callback',@(x,y)cycleData(x,y,+1) );

%Reject controls
but1    = uicontrol( 'Units', 'normalized', 'Position', [.2 .80 .1 .1],  'String', 'Reject', 'Callback',@but1_cb );
but2   = uicontrol( 'Units', 'normalized', 'Position', [.3 .80 .1 .1], 'String', 'Un-reject', 'Callback',@but2_cb );

%Re-fit button + frng input box
but3   = uicontrol( 'Units', 'normalized', 'Position', [.65, .8, .1, .1],     'String', 'Refit XWLC', 'Callback',@(x,y)but3_cb );
txt3   = uicontrol( 'Style', 'edit', 'Units', 'normalized', 'Position', [.75, .8, .1, .1],     'String', '[1.5 2.5 5 50]' );



% but1y   = uicontrol( 'Units', 'normalized', 'Position', [.525, .65, .15, .1],     'String', but1lab{2}, 'Callback',@(x,y)but1_cb(x,y,1) );
% but2y   = uicontrol( 'Units', 'normalized', 'Position', [.525+.15, .65, .15, .1], 'String', but2lab{2}, 'Callback',@(x,y)but2_cb(x,y,1) );

% Backup uicontrols: in the top bar instead
% numtext = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.05, .90, .05, .05], 'String', '0/0', 'Callback',@(x,y)cycleData(x,y,-1) );
% butlef = uicontrol( 'Units', 'normalized', 'Position', [.1, .90, .05, .05],       'String', '<', 'Callback',@(x,y)cycleData(x,y,-1) );
% butrig = uicontrol( 'Units', 'normalized', 'Position', [.15, .90, .05, .05],       'String', '>', 'Callback',@(x,y)cycleData(x,y,+1) );
% but1   = uicontrol( 'Units', 'normalized', 'Position', [.25, .90, .25, .05],       'String', but1lab{2}, 'Callback',@but1_cb );
% but2   = uicontrol( 'Units', 'normalized', 'Position', [.60, .90, .25, .05],       'String', but2lab{2}, 'Callback',@but2_cb );

%Set some constants (options)
xl = [1.5 45]; %X lim for plotting
ff = xl(1):.1:xl(2);


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
        
        if isempty(dat(num).ext)
            cla(ax1)
            title(ax1, 'Empty data, skipping')
            return
        end
        
        xwlc = inst(num).xwlc(1:2);
        con = ext ./ XWLC(frc, xwlc(1), xwlc(2));
        
        %Filter
        fil = 100;
        ff = windowFilter(@mean, frc, [], fil);
        cf = windowFilter(@mean, con, [], fil);
        xf = windowFilter(@mean, ext, [], fil);
        
%         %Crop contour graph to highest force
%         [~, maxi] = max(ff);
        
        
        %Plot raw force-ext above
        cla(ax1)
        plot(ax1, xf, ff);
        %Maybe plot with time as color? code example below
%         surface(mainAxis, [timF;timF],[frcF;frcF],zeros(2,length(timF)),[timF;timF], 'edgecol', 'interp');
        axis(ax1, 'tight')
        
        %Plot XWLC Fits
        plot(ax1, XWLC(ff, dat(num).xwlc(1), dat(num).xwlc(2)) * dat(num).xwlc(3), ff )
        plot(ax1, XWLC(ff, dat(num).xwlc(1), dat(num).xwlc(2)) * (dat(num).xwlc(3)+ dat(num).xwlc(4)), ff )
        plot(ax1, XWLC(ff, dat(num).xwlc(1), dat(num).xwlc(2)) * (dat(num).xwlc(3)+ dat(num).xwlc(5)), ff )
        
%         %Plot HF Rips
%         plot( dat(num).hfx, dat(num).hfs, 'o');
%         %And text annotation
%         for i = 1:length(dat(num).hfx )
%             text(dat(num).hfx(i), dat(num).hfs(i), sprintf('%0.1f pN', dat(num).hfs(i) ))
%             
%         end
        
        
        %Plot fit sections
        for i = 1:length( dat(num).fitii )
            ind = min( dat(num).fitii(i)/ fil, length(ff) );
            plot( xf(ind) * [1 1], [0 ff(ind)] )
            
        end
        
        %Plot total LF/HF sizes
        ripcon = dat(num).xwlc(3:5);
        ripsz = [ripcon(2) ripcon(3)-ripcon(2)];
        xw = @(x)XWLC(x, dat(num).xwlc(1),dat(num).xwlc(2));
        text( xw(4) * ripcon(1) , 4 , sprintf('%0.2f nm', ripsz(1) ) );
        text( xw(10) * (ripcon(1) + ripcon(2)) , 10 , sprintf('%0.2f nm', ripsz(2) ) );
        
        %Plot XWLC params
        xwlctext.String = sprintf('%0.1f nm, %0.1f pN, %0.1f nm, %0.1f nm, %0.1f nm', dat(num).xwlc);
        
%         %Set lims
%         xlim(ax2, xl)
%         %Dynamic y-lim based on crossing pt of y=fcen
%         y0 = cf(find(ff > fcen, 1, 'first'));
%         if isempty(y0)
%             %Fallback, just set to median
%             y0 = median(cf);
%         end
%         ylim(ax2, y0 + [-30 30])
%         
%         
% %         %Set button strings
% %         but1.String = but1lab{ dat(num).tfpbe1 + 1 };
% %         but2.String = but2lab{ dat(num).tfpbe2 + 1 };
        
        %Set title for ax2 based on tfpbe
        nameFigure;
    end

    function but1_cb(~,~)
        %Set as tfpbe1
        dat(num).tfpbe1 = 0;
        nameFigure
    end

    function but2_cb(~,~)
        %Set as tfpbe2
        dat(num).tfpbe1 = 1;
        nameFigure
    end
    
    function but3_cb(~,~)
       %Get new frng
       fr = str2num( txt3.String );
       %Fit
       tmp = fitNuc( dat(num), fr, 0 );
       
       %Should be able to just overwrite
       dat(num) = tmp;
       
        %Reload file
        cycleData([],[],0)
        
%            %Save fit
%     inst(i).xwlc = ft;
%     inst(i).ftrsd = res123;
%     inst(i).con = inst(i).ext ./ XWLC( inst(i).frc, ft(1), ft(2) );
%     inst(i).fitii = [i1 i2 i3 i3b i4b i4]*fil;
       
    end

%     function butn_cb(~,~)
%         %Reject = set nan
%         dat(num).tfpbe2 = nan;
%         dat(num).tfpbe2 = nan;
%         nameFigure
%     end

    function nameFigure()        
%         outcomes = { 'Bare DNA' 'Tet' 'Hex' 'Nuc' };
%         if ~isnan(t1) && ~isnan(t2)
%             str = outcomes{ t1 + t2*2 +1};
%         else
%             str = 'Not assigned / Rejected';
%         end
        str = { 'Rejected' 'Accepted'};
        %Name figure
        title(ax1, str{ dat(num).tfpbe1 +1})
        
    end

    function addwkspc(~,~,tfclose)
        %Assign to workspace, on button press or on exit
        assignin('base', sprintf('RPpickGUI_%s', datestr(datetime('now'), 'HHMM')), dat)
        if tfclose
            delete(fg)
        end
    end

end