function ForExtGUI_V2()
%ForceGUI, but now programmatic - GUIDE has bad limitations/bugs

%Add paths
thispath = fileparts(mfilename('fullpath'));
addpath (thispath)                     %ForExtGUI
addpath ([thispath '\Helpers\'])       %Filename sorter
addpath ([thispath '\ForceExt\'])      %XWLC
addpath ([thispath '\StepFind_KV\'])   %Filtering

%Load settings file (or create one)
path = 'C:\Data';
file = 'ForceExtensionMMDDYYN00.mat';
name = 'mmddyyN00';
if exist('GUIsettingsFX.mat', 'file')
    load('GUIsettingsFX.mat', 'path');
else
    c = 'Settings file for ForExtGUI'; %#ok<*NASGU> - A lot of uicontrol handles will be unused, too - OK
    save('GUIsettingsFX.mat', 'c');
end

%Declare variables for static workspace - or just shove everything in a struct
ContourData = [];
cropLines = {[] [] [] []};
fitLine = [];
filtLine = [];
filtLine2 = [];
cropT = [];
frc = [];
ext = [];
tim = [];
frcF = [];
extF = [];
timF = [];
frcFc = [];
extFc = [];
timFc = [];
fil = [];
dec = [];
xwlcData = {'xwlcData', zeros(1,3)}; %= {'name' [PL SM CL]}

%Construct figure
scrsz = get(0, 'ScreenSize');
%Default size is 3/4 of each dimension
fig = figure('Name', 'ForExtGUI', 'Position', [scrsz(3:4)/8 .75*scrsz(3:4)], 'Visible', 'off');

%Size of border windows
panwid_top = 0.05;
panwid_left = 0.08; %Warning: if this is too small / window too narrow, slider goes up-down instead of left-right

panaxs = uipanel('Position', [panwid_left 0 1-panwid_left 1-panwid_top]);
mainAxis = axes('Parent', panaxs, 'Position', [.05 .31 .94 .68]);
hold(mainAxis,'on')
subAxis  = axes('Parent', panaxs, 'Position', [.05 .05 .4 .2]);
hold(subAxis, 'on')
subAxis2  = axes('Parent', panaxs, 'Position', [.55 .05 .4 .2]);
hold(subAxis2, 'on')
%This sets the colormap, which dictates how the color of the line changes; see >>doc colormap
colormap cool

%Top row of buttons
pantop = uipanel('Position', [0 1-panwid_top 1 panwid_top]);
loadFile = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [ 0, 0, .1, 1], 'String', 'Load File', 'Callback',@loadFile_callback);
takeCrop = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.1, 0, .075, 1], 'String', 'Crop', 'Callback',@tempCrop_callback);
takeCropL= uicontrol('Parent', pantop, 'Style', 'text', 'Units', 'normalized', 'Position', [.175, .5, .025, .5 ], 'String', 'CropN');
takeCropT= uicontrol('Parent', pantop, 'Style', 'edit', 'Units', 'normalized', 'Position', [.175, 0, .025, .5 ], 'String', '1', 'Callback',@loadCrop_callback);
stepKlVi = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.2, 0, .05, 1], 'String', 'Fit XWLC' , 'Callback',@fitXWLC_callback);
frcRange = uicontrol('Parent', pantop, 'Style', 'edit', 'Units', 'normalized', 'Position', [.25 0 .05 .5], 'String', '[5 35]');
frcRangeT= uicontrol('Parent', pantop, 'Style', 'text', 'Units', 'normalized', 'Position', [.25 .5 .05 .5], 'String', 'Force Range');
stepHist = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.3, 0, .1, 1], 'String', 'Measure', 'Callback',@measure_callback);
toWorksp = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.4, 0, .1, 1], 'String', 'To Workspace' , 'Callback',@toWorksp_callback);
ensembFit= uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.5, 0, .05, 1], 'String', 'XWLC All', 'Callback',@ensembFit_callback);
printFig = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.55, 0, .05, 1], 'String', 'Print', 'Callback',@printFig_callback);
customB1 = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.60, 0, .05, 1], 'String', 'But01', 'Callback',@custom01_callback);
customB2 = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.65, 0, .05, 1], 'String', 'But02', 'Callback',@custom02_callback);
permCrop = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.9, 0, .1, 1], 'String', '[]', 'Callback',[]);
trcNotes = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.7, 0, .2, 1], 'Style', 'text', 'String', 'Comment');

%Left bar of text inputs, sliders, etc.
panlef = uipanel('Position',[0 0 panwid_left 1-panwid_top]);
fileSlider= uicontrol('Parent', panlef, 'Style', 'slider', 'Units', 'normalized', 'Position', [0 .9 1 .1], 'Callback', @fileSlider_callback);
txtSlider2= uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [0.15 .901 .7 .05], 'String', 'mmddyyN00');
clrGraph  = uicontrol('Parent', panlef, 'Units', 'normalized', 'Position', [0 .775 1 .025], 'String', 'Clear Graph', 'Callback', @clrGraph_callback);
filtFactT = uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [0 .85 .5 .025], 'String', 'Filter');
filtFact  = uicontrol('Parent', panlef, 'Style', 'edit', 'Units', 'normalized', 'Position', [0 .8 .5 .05], 'String', '[]', 'Callback', @refilter_callback);
deciFactT = uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [.5 .85 .5 .025], 'String', 'Decim.');
deciFact  = uicontrol('Parent', panlef, 'Style', 'edit', 'Units', 'normalized', 'Position', [.5 .8 .5 .05], 'String', '25', 'Callback', @refilter_callback);
traceTxt  = uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [0 .65 1 .05], 'String', '00bp/s, 00pts');
datTable  = uitable  ('Parent', panlef, 'Units', 'normalized', 'Position', [-.1 .35 1.1 .25], 'Data', zeros(8,1), 'RowName', {'Last' 'PL' 'SM' 'CL' 'OffX' 'Avg' 'PL' 'SM' 'CL' 'OffX'}, 'ColumnName', '');
clrHists  = uicontrol('Parent', panlef, 'Units', 'normalized', 'Position', [0 .625 1 .025], 'String', 'Clear Data', 'Callback', @clrHists_callback);
plotCal   = uicontrol('Parent', panlef,                  'Units', 'normalized', 'Position', [0 .3 .5 .05], 'String', 'Plot Cal', 'Callback', @plotCal_callback);
plotOff   = uicontrol('Parent', panlef,                  'Units', 'normalized', 'Position', [.5 .3 .5 .05], 'String', 'Plot Off', 'Callback', @plotOff_callback);

%Load first file
loadFile_callback

fig.Visible = 'on';

%%%%Callbacks
    function loadFile_callback(~,~, f, p)
        %Prompt the user to select a file
        if nargin<3
            [f, p] = uigetfile([path filesep 'ForceExtension*.mat'], 'MultiSelect','off','Pick a Phi29 Trace');
            if ~p; %No file selected, do nothing
                return
            end
            file = f;
            path = p;
            save('GUIsettingsFX.mat', 'path', '-append')
            
            %Format the file slider
            d = dir([path filesep 'ForceExtension*.mat']);
            d = {d.name};
            len = length(d);
            %Sort, so it's by day then by N##
            d = sort_phage(d);
            fileSlider.Min = 1;
            fileSlider.Max = len;
            fileSlider.String = d;
            fileSlider.Enable = 'on';
            if len ==1
                fileSlider.Enable = 'off';
            else
                fileSlider.SliderStep = [1 10] ./ (len-1);
            end
        else %Called from fileSlider_callback
            file = f;
            path = p;
        end
        
        %Load the file
        load([path file],'ContourData');
        name = file(15:end-4);
        cla(mainAxis)
        fig.Name = sprintf('ForExtGUI %s', name);
        
        %Load comment
        if isfield(ContourData,'comment')
            trcNotes.String = ContourData.comment;
        else
            trcNotes.String = '';
        end

        %Set the file slider
        fileSlider.Value = find(cellfun(@(x) strcmp(x, file),fileSlider.String),1);
        txtSlider2.String = sprintf('%s\n%d/%d', name, round(fileSlider.Value), fileSlider.Max);
        
        %Load var.s into figure
        tim = ContourData.time(:)';
        frc = ContourData.force(:)';
        ext = ContourData.extension(:)';
        
        %Plot F-X on bottom
        plotandlim(subAxis, ext, frc, 'Color', [.7 .7 .7])
        
        %Clear crop
        cropT = [];
        
        %Plot F-T on top
        plotandlim(mainAxis, tim, frc, 'Color', [.7 .7 .7])
        
        cla(subAxis2)
        
        %Plot filtered in color
        refilter_callback
        
        %display XWLC if already calc'd
        ind = find(strcmp(name, xwlcData(:,1)));
        if ind
            datTable.Data(1:5) = [1 xwlcData{ind, 2}];
        else
            datTable.Data(1:5) = zeros(1,5);
        end
        
        locNoise_callback()
        
        loadCrop_callback
    end

    function tempCrop_callback(~,~)
        cellfun(@delete, cropLines)
        %Select crop
        [x, ~] = ginput(2);
        cropT = sort(x(:,1));
        cropstr = takeCropT.String;
        if cropstr == '1';
            cropstr = [];
        end
        cropfp = sprintf('%s\\CropFiles%s\\%s.crop', path, cropstr, name);
        cropp = fileparts(cropfp);
        if ~exist(cropp, 'dir')
            mkdir(cropp)
        end
        if ~issorted(x)
            if exist(cropfp, 'file')
                fprintf('Deleted crop%s for %s\n', cropstr, name)
                delete(cropfp)
            end
            return
        end
        fid = fopen(cropfp, 'w');
        fwrite(fid, sprintf('%f\n%f', x));
        fclose(fid);
        loadCrop_callback
    end

    function loadCrop_callback(~,~)
        cropstr = takeCropT.String;
        i = str2double(cropstr);
        if cropstr == '1'
            cropstr = '';
        end
        cropfp = sprintf('%s\\CropFiles%s\\%s.crop', path, cropstr, name);
        fid = fopen(cropfp);
        if fid == -1
%             takeCrop.String = 'Crop not found';
            return
        end
        
        ts = textscan(fid, '%f');
        fclose(fid);
        ts = ts{1};
        cropT = ts;
        
        %Delete old lines
        if ~isempty(cropLines{1,1})
            cellfun(@delete, cropLines(1,:))
        end
        %Draw a line at the start/end crop bdys
        mainYLim = mainAxis.YLim;
        subYLim = subAxis.YLim;
        cropLines{1} = line(mainAxis,cropT(1) * [1 1], mainYLim);
        cropLines{2} = line(mainAxis,cropT(2) * [1 1], mainYLim);
        cropLines{3} = line(subAxis ,cropT(1) * [1 1], subYLim);
        cropLines{4} = line(subAxis ,cropT(2) * [1 1], subYLim);
    end

    function measure_callback(~,~)
        [x, y] = ginput(2);
        dx = abs(diff(x));
        dy = abs(diff(y));
        
        pt1 = find(tim>x(1), 1);
        pt2 = find(tim>x(2), 1);
        if ~isempty(pt1) && ~isempty(pt2)
            
            
        end
        
        line(x,y)
        text(x(end),y(end),sprintf('(dx,dy,m) = (%0.2f, %0.2f, %0.2f)\n',dx,dy,dy/dx), 'Clipping', 'on')
    end

    function fileSlider_callback(~,~)
        file = fileSlider.String{round(fileSlider.Value)};
        loadFile_callback([], [], file, path)
    end

    function refilter_callback(~,~)
        delete(filtLine)
        delete(filtLine2)
        dec = str2double(deciFact.String);
        fil = str2num(filtFact.String); %#ok<ST2NM>
        timF = windowFilter(@mean, tim, fil, dec);
        extF = windowFilter(@mean, ext, fil, dec);
        frcF = windowFilter(@mean, frc, fil, dec);
        filtLine = surface(mainAxis, [timF;timF],[frcF;frcF],zeros(2,length(timF)),[timF;timF], 'edgecol', 'interp');
        filtLine2 = surface(subAxis, [extF;extF],[frcF;frcF],zeros(2,length(extF)),[timF;timF], 'edgecol', 'interp');
    end
    
    function toWorksp_callback(~,~)
        assignin('base','guiF',frc);
        assignin('base','guiX',ext);
        assignin('base','guiT',tim);
        assignin('base','guiFf',frcF);
        assignin('base','guiXf',extF);
        assignin('base','guiTf',timF);
        assignin('base','guiFfc',frcFc);
        assignin('base','guiXfc',extFc);
        assignin('base','guiTfc',timFc);
        assignin('base','guiConData',ContourData);
        assignin('base','guiXWLC',xwlcData);
    end

    function clrGraph_callback(~,~)
        loadFile_callback([],[],file,path)
    end

    function fitXWLC_callback(~,~)
        if isempty(cropT)
            return
        end
        
        indc = timF > cropT(1) & timF < cropT(2);
        frcFc = frcF(indc);
        extFc = extF(indc);
        timFc = timF(indc);
        flim = str2num(frcRange.String); %#ok<ST2NM>
        opts.loF = flim(1);
        opts.hiF = flim(2);
        
%         opts.inGuess = [30 500 4000];
        
        %Do fitting
        xwlcfit = fitForceExt(extFc, frcFc, opts, 0);
        
        %Add to xwlcData, if new (else replace)
        ind = find(strcmp(name, xwlcData(:,1)));
        if ind
            xwlcData{ind, 2} = xwlcfit ./ [1 1 1000 1];
        else %Not found, append to end
            xwlcData(end+1,:) = {name xwlcfit ./ [1 1 1000 1]};
        end
        
        %Plot residual, fit
%         fitx = xwlcfit(3) * .34 * ForceExt_XWLC_Wikipedia(frcFc, xwlcfit(1),xwlcfit(2)) + xwlcfit(4);
        fitx = xwlcfit(3) * .34 * XWLC(frcFc, xwlcfit(1),xwlcfit(2), [], 3) + xwlcfit(4);
        extresid = extFc - fitx;
        delete(fitLine)
        fitLine = plot(subAxis, fitx, frcFc, 'Color', 'k', 'LineWidth', 1);
        xlim(subAxis, [min(extFc), max(extFc)])
        %Make Y-lim either 2*resid(in fit range) or (resid all), whichever is smaller
        yl = [-1 1] * min(max(abs(extresid)), 2*max(abs(extresid(frcFc > flim(1) & frcFc < flim(2)))));
        cla(subAxis2)
        xl = [min(frcFc), max(frcFc)];
        plot(subAxis2, frcFc, extresid, 'o')
        %0 line
        plot(subAxis2, xl, [0 0], 'Color', 'k', 'LineWidth', 1)
        %line at loF, hiF
        if xl(1) < flim(1)
            plot(subAxis2, flim(1) * [1 1], yl, 'Color', 'k', 'LineWidth', 1)
        end
        if xl(2) > flim(2)
            plot(subAxis2, flim(2) * [1 1], yl, 'Color', 'k', 'LineWidth', 1)
        end
        plot(subAxis2, xl, [0 0], 'Color', 'k', 'LineWidth', 1)
        xlim(subAxis2, xl);
        ylim(subAxis2, yl);
        
        %Average XWLC data
        len = size(xwlcData, 1);
        dat = zeros(1,4);
        for i = 2:len
            dat = dat + xwlcData{i,2};
        end
        dat = dat / (len-1);
        %Update table
        datTable.Data = [0; (xwlcfit ./ [1 1 1000 1])'; len-1; dat';];
    end

    function ensembFit_callback(~,~)
        cropstr = takeCropT.String;
        if cropstr == '1'
            cropstr = '';
        end
        [exts, frcs] = getFCs_fx(cropstr, path);
        dec = str2double(deciFact.String);
        fil = str2num(filtFact.String); %#ok<ST2NM>
        exts = exts(~cellfun(@isempty, frcs));
        frcs = frcs(~cellfun(@isempty, frcs));
        
        exts = cellfun(@(x)windowFilter(@mean, x, fil, dec), exts, 'uni', 0);
        frcs = cellfun(@(x)windowFilter(@mean, x, fil, dec), frcs, 'uni', 0);
        
        %Open a figure and plot the traces, so you can delete ones you don't want; then fit XWLC
        figure('CloseRequestFcn', @crf_cb, 'Name', 'Delete outliers then close figure to fit XWLC')
        hold on
        cellfun(@scatter, exts, frcs)
        function crf_cb(~,~)
            ax=gca;
            fg = gcf;
            axc = ax.Children;
            ex = {axc.XData};
            fr = {axc.YData};
            delete(fg)
            frcrng = str2num(frcRange.String); %#ok<ST2NM>
            fitForceExt_ensemble_v2(ex, fr, struct('loF', frcrng(1), 'hiF', frcrng(2)), 1);
        end
    end

    function locNoise_callback(~,~)
        %Plot the local noise levels every so-and-so points
        netlen = length(frc);
        if netlen > 1e5
            noiwin = 2e3;
        else
            noiwin = 1e3;
        end
        szs = floor(netlen/noiwin);
        
        for j = 1:szs
            %Estimate noise, annotate with text
            ran = (j-1)*noiwin+1:j*noiwin;
            textt = double(mean(tim(ran([1 end]))));
            textc = double(mean(frc(ran)));
            %                 textv = std(cfil(ran));
            textv = sqrt(estimateNoise(ext(ran), [], 2));
            text(mainAxis, textt, textc+2, sprintf('%0.2f',textv), 'Rotation', 90, 'Clipping', 'on')
            
        end
        
    end

    function clrHists_callback(~,~)
        xwlcData = xwlcData(1,:);
        datTable.Data = 0* datTable.Data;
    end

    function printFig_callback(~,~)
        print(fig, sprintf('.\\ForExtPrtSc%s', datestr(now, 'yymmddHHMMSS')),'-dpng',sprintf('-r%d',96))
    end

%%%%Helpers
    function plotandlim(ax, x, y, varargin)
        cla(ax)
        plot(ax, x, y, varargin{:})
        xl = [min(x) max(x)];
        yl = [min(y) max(y)];
        zoom out
        ax.XLim = xl;
        ax.YLim = yl;
        zoom reset
    end

    function plotCal_callback(~,~)
        if isfield(ContourData, 'cal')
            plotcal(ContourData.cal);
        end
    end

    function plotOff_callback(~,~)
        if isfield(ContourData, 'off')
            plotoff(ContourData.off);
        end
    end
        
    function custom01_callback(~,~)
        %Remove this one
        customB1.String = 'RmXWLC';
        ind = find(strcmp(name, xwlcData(:,1)));
        if ind
            xwlcData(ind,:) = [];
            datTable.Data(1:4) = [-1 0 0 0];
        end
    end

    function custom02_callback(~,~)
        
        
    end
end