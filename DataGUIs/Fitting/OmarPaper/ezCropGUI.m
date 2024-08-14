function ezCropGUI(inst)
%Crop by eye 
% Can pick normal crop, crop Fast, crop Slow, crop Superslow
%
%Based on RPpickbyeyeGUI


%Need to provide inst, the output of procFranp2
if nargin < 1
    return
end


Fs=1e3; %Keep in mind if you change the x unit, you need to change back to points when you crop
% Here just setting Fs so the guidelines for slope are right

%Just do one data
dat = inst(1);
len = length(dat.drA);

%Assign name to hold crop, add guideline
fn = {'crop' 'cropfast' 'cropslow' 'cropsuper'};
spds = [25 5 .5]; %Speeds for fast, slow, superslow

%Add crop field if it doesn't exist / is empty
for ii = 1:length(fn)
    if ~isfield(dat, fn{ii}) || isempty(dat.(fn{ii}))
        dat.(fn{ii}) = cell(1,len);
    end
end

%Declare variables
num = 1; %Index of current file

%Options
smcon = 10; %Smoothing option for contour-time

%Make figure
ssz = get(groot, 'ScreenSize');
fg = figure('Position', ssz + [ssz(3:4)/10 -ssz(3:4)/5], 'Color', [1 1 1], 'CloseRequestFcn', @(x,y)addwkspc([],[],1));
% ax1 = subplot2(fg, [2 2], 1);
ax2 = axes('Position', [.1 .15 .8 .7]);
% hold(ax1, 'on')
hold(ax2, 'on')
%Set labels
% xlabel(ax1, 'Extension (nm)')
% ylabel(ax1, 'Force (pN)')
xlabel(ax2, 'Time (pts)')
ylabel(ax2, 'Extension')

%UIcontrols. Put them in the empty quadrant, top-right
numtext = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [.45, .85, .1, .1], 'String', '0/0', 'Callback',@(x,y)cycleData(x,y,-1) );
butlef = uicontrol( 'Units', 'normalized', 'Position', [.35, .85, .1, .1],       'String', '<', 'Callback',@(x,y)cycleData(x,y,-1) ); %#ok<*NASGU>
butrig = uicontrol( 'Units', 'normalized', 'Position', [.55,  .85, .1, .1],       'String', '>', 'Callback',@(x,y)cycleData(x,y,+1) );
% but1   = uicontrol( 'Units', 'normalized', 'Position', [.15, .85, .20, .1],       'String', 'Crop Left', 'Callback',@but1_cb );
% but2   = uicontrol( 'Units', 'normalized', 'Position', [.65, .85, .20, .1],       'String', 'Crop Right', 'Callback',@but2_cb );

but2   = uicontrol( 'Units', 'normalized', 'Position', [.9, .85, .1, .1],       'String', 'Crop', 'Callback',@(x,y)but3_cb(x,y,1) );
but3   = uicontrol( 'Units', 'normalized', 'Position', [.9, .75, .1, .1],       'String', 'Crop Fast', 'Callback',@(x,y)but3_cb(x,y,2) );
but4   = uicontrol( 'Units', 'normalized', 'Position', [.9, .65, .1, .1],       'String', 'Crop Slow', 'Callback',@(x,y)but3_cb(x,y,3));
but5   = uicontrol( 'Units', 'normalized', 'Position', [.9, .55, .1, .1],       'String', 'Crop Superslow', 'Callback',@(x,y)but3_cb(x,y,4));


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
        num = mod( num-1+d, len ) + 1;
        %Name figure
        fg.Name = sprintf('Trace %02d', num);
        numtext.String = sprintf('%d/%d', num, len);
        %Get data
        con = dat.drA{num};
        %Plot
        cla(ax2)
        plot(ax2, windowFilter(@median, con, smcon, 1));
        if isfield(dat, 'pdd') && ~isempty(dat.pdd)
            plot(ax2, dat.pdd{num})
        end
        axis tight
        xl = xlim(ax2);
        yl = ylim(ax2);
        axis manual
        xlim( xl + diff(xl) * [-.05 .05] )
        ylim( yl + diff(yl) * [-.01 .01] )
        yl = ylim(ax2);
        
        %Add marker lines for current crop
        krgb = 'krgb';
        for i = 1:4
            if ~isempty(dat.(fn{i}){num})
                arrayfun(@(x) plot(ax2, x * [1 1], yl, krgb(i)), dat.(fn{i}){num});
            end
        end
        
        %Add slope guides
        rgb = 'rgb';
        for i = 1:length(spds)
            plot(xl, xl * spds(i) / Fs + con(1), rgb(i))
        end
        
        
    end

%     function but1_cb(~,~)
%         %ginput1 and set crop
%         [x, ~] = ginput(1);
%         x = max(round(x), 1);
%         if isempty(dat.(fn{1}){num})
%             dat.(fn{1}){num} = [x, length(dat.drA{num})];
%         else
%             dat.(fn{1}){num}(1) = x;
%         end
%         plot(ax2, x * [1 1], ylim(ax2), 'k')
%     end
% 
%     function but2_cb(~,~)
%         %ginput1 and set crop
%         [x, ~] = ginput(1);
%         x = min(round(x), length(dat.drA{num}));
%         if isempty(dat.(fn{1}){num})
%             dat.(fn{1}){num} = [1, x];
%         else
%             dat.(fn{1}){num}(2) = x;
%         end
%         plot(ax2, x * [1 1], ylim(ax2), 'k')
%     end

    function but3_cb(~,~,ind)
        %ginput2 and set crop
        [x, ~] = ginput(2);
        %Round and coerce x
        x = min(round(x), length(dat.drA{num}));
        x = max(x, 1);
        
        %Reject if selected left-right
        if x(1) > x(2)
            x = [];
        end
        
        %Save crop
        dat.(fn{ind}){num} = x;
        
        if ~isempty(x)
            %Add crop lines
            rgb = 'krgb';
            plot(ax2, x(1) * [1 1], ylim(ax2), rgb(ind))
            plot(ax2, x(2) * [1 1], ylim(ax2), rgb(ind))
        end
        
    end

    function addwkspc(~,~,tfclose)
        %Assign to workspace, on button press or on exit
        assignin('base', sprintf('RPpickGUI_%s', datestr(datetime('now'), 'HHMM')), dat)
        if tfclose
            delete(fg)
        end
    end

end