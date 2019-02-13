function PhageGUI_V2()
%PhageGUI, but now programmatic - GUIDE has bad limitations/bugs

%Add paths
thispath = fileparts(mfilename('fullpath'));
addpath (thispath)                     %PhageGUI
addpath ([thispath '\Helpers\'])       %Filename sorter
addpath ([thispath '\StepFind_KV\'])   %K-V stepfinder
addpath ([thispath '\StepFind_Hist\']) %Hist stepfinder

%Load settings file (or create one)
path = 'C:\Data';
file = 'phageMMDDYYN00.mat';
name = 'mmddyyN00';
if exist('GUIsettings.mat', 'file')
    load('GUIsettings.mat', 'path');
else
    c = 'Settings file for PhageGUI'; %#ok<*NASGU> - A lot of uicontrol handles will be unused, too - OK
    save('GUIsettings.mat', 'c');
end

%Declare variables for static workspace - or just shove everything in a struct
stepdata = [];
cropLines = {[] [] [] []};
stepLines = {[] []};
filtLine = [];
cropT = [];
con = [];
tim = [];
conF = [];
timF = [];
conFc = [];
timFc = [];
fil = [];
dec = [];
num = [];
patchl = [];
patchr = [];
histBins = 0:0.5:20;
histData.kv = {'kv histData', zeros(size(histBins))};
histData.hist = {'hist histData', zeros(size(histBins))};

%Construct figure
scrsz = get(0, 'ScreenSize');
%Default size is 3/4 of each dimension
fig = figure('Name', 'PhageGUI', 'Position', [scrsz(3:4)/8 .75*scrsz(3:4)], 'Visible', 'off');

%Size of border windows
panwid_top = 0.05;
panwid_left = 0.08; %Warning: if this is too small / window too narrow, slider goes up-down instead of left-right

panaxs = uipanel('Position', [panwid_left 0 1-panwid_left 1-panwid_top]);
mainAxis = axes('Parent', panaxs, 'Position', [.05 .31 .94 .68]);
hold(mainAxis,'on')
subAxis  = axes('Parent', panaxs, 'Position', [.05 .05 .94 .2]);
hold(subAxis, 'on')

%Top row of buttons
pantop = uipanel('Position', [0 1-panwid_top 1 panwid_top]);
loadFile = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [ 0, 0, .1, 1], 'String', 'Load File', 'Callback',@loadFile_callback);
loadCrop = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.1, 0, .1, 1], 'String', 'Load Crop', 'Callback',@loadCrop_callback);
stepKlVi = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.2, 0, .05, 1], 'String', 'Step K-V' , 'Callback',@stepKV_callback);
KlViFact = uicontrol('Parent', pantop, 'Style', 'edit', 'Units', 'normalized', 'Position', [.25 0 .05 .5], 'String', '5');
KlViFactT= uicontrol('Parent', pantop, 'Style', 'text', 'Units', 'normalized', 'Position', [.25 .5 .05 .5], 'String', 'K-V Penalty');
stepHist = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.3, 0, .1, 1], 'String', 'Step Hist', 'Callback',@stepHst_callback);
toWorksp = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.4, 0, .1, 1], 'String', 'To Workspace' , 'Callback',@toWorksp_callback);
tempCrop = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.5, 0, .05, 1], 'String', 'Temp Crop', 'Callback',@tempCrop_callback);
printFig = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.55, 0, .05, 1], 'String', 'Print', 'Callback',@printFig_callback);
customB1 = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.60, 0, .05, 1], 'String', 'But01', 'Callback',@custom01_callback);
customB2 = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.65, 0, .05, 1], 'String', 'But02', 'Callback',@custom02_callback);
permCrop = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.9, 0, .1, 1], 'String', 'Crop', 'Callback',@permCrop_callback);
trcNotes = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.7, 0, .2, 1], 'Style', 'text', 'String', 'Comment');

%Left bar of text inputs, sliders, etc.
panlef = uipanel('Position',[0 0 panwid_left 1-panwid_top]);
fileSlider= uicontrol('Parent', panlef, 'Style', 'slider', 'Units', 'normalized', 'Position', [0 .9 1 .1], 'Callback', @fileSlider_callback);
txtSlider2= uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [0.15 .901 .7 .05], 'String', 'mmddyyN00');
segSlider = uicontrol('Parent', panlef, 'Style', 'slider', 'Units', 'normalized', 'Position', [0 .80 1 .1], 'Callback', @segSlider_callback);
txtSlider = uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [0.15 .802 .7 .05], 'String', '1');
clrGraph  = uicontrol('Parent', panlef, 'Units', 'normalized', 'Position', [0 .775 1 .025], 'String', 'Clear Graph', 'Callback', @clrGraph_callback);
filtFactT = uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [0 .75 .5 .025], 'String', 'Filter');
filtFact  = uicontrol('Parent', panlef, 'Style', 'edit', 'Units', 'normalized', 'Position', [0 .7 .5 .05], 'String', '[]', 'Callback', @refilter_callback);
deciFactT = uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [.5 .75 .5 .025], 'String', 'Decim.');
deciFact  = uicontrol('Parent', panlef, 'Style', 'edit', 'Units', 'normalized', 'Position', [.5 .7 .5 .05], 'String', '5', 'Callback', @refilter_callback);
traceTxt  = uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [0 .65 1 .05], 'String', '00bp/s, 00pts\n00-00pN');
histAxis.kv =    axes('Parent', panlef, 'Position', [.25 .05 .7 .25]);
histAxis.hist =  axes('Parent', panlef, 'Position', [.25 .35 .7 .25]);
clrHists  = uicontrol('Parent', panlef, 'Units', 'normalized', 'Position', [0 .625 1 .025], 'String', 'Clear Hists', 'Callback', @clrHists_callback);

%Load first file
loadFile_callback

fig.Visible = 'on';

%%%%Callbacks
    function loadFile_callback(~,~, f, p)
        %Prompt the user to select a file
        if nargin<3
            [f, p] = uigetfile([path filesep 'phage*.mat'], 'MultiSelect','off','Pick a Phi29 Trace');
            if ~p; %No file selected, do nothing
                return
            end
            file = f;
            path = p;
            save('GUIsettings.mat', 'path', '-append')
            
            %Format the file slider
            d = dir([path filesep 'phage*.mat']);
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
        load([path file],'stepdata');
        name = file(6:end-4);
        cla(mainAxis)
        fig.Name = sprintf('PhageGUI %s', name);
        
        %Load comment
        if isfield(stepdata,'comment')
            trcNotes.String = stepdata.comment;
        else
            trcNotes.String = '';
        end
        
        %Format the segment slider
        len = length(stepdata.contour);
        segSlider.Visible = 'on';
        segSlider.Min = 1;
        segSlider.Max = len;
        segSlider.Value = 1;
        if len > 1
            segSlider.SliderStep = [1 10]./(len-1);
        else
            segSlider.Visible = 'off';
        end

        %Set the file slider
        fileSlider.Value = find(cellfun(@(x) strcmp(x, file),fileSlider.String),1);
        txtSlider2.String = sprintf('%s\n%d/%d', name, round(fileSlider.Value), fileSlider.Max);
        
        %Plot whole trace on bottom
        cla(subAxis)
        plotCell(subAxis, stepdata.time, stepdata.contour)
        tlim = [min(cellfun(@min, stepdata.time)) max(cellfun(@max, stepdata.time))];
        clim = [min(cellfun(@min, stepdata.contour)) max(cellfun(@max, stepdata.contour))];
        zoom out
        subAxis.XLim = tlim;
        subAxis.YLim = clim;
        zoom reset
        
        %Clear crop
        cropT = [];
        
        %Plot feedback cycle on top
        segSlider_callback
    end

    function loadCrop_callback(~,~)
        %Create path of crop file
        cropfp = sprintf('%s\\CropFiles\\%s.crop', path, name);
        fid = fopen(cropfp);
        if fid == -1
            fprintf('Crop not found for %s\n', name)
            return
        end
        
        ts = textscan(fid, '%f');
        fclose(fid);
        ts = ts{1};
        
        %Delete old lines
        if ~isempty(cropLines{1})
            cellfun(@delete, cropLines)
        end
        
        %Set tempCrop to the actual crop
        cropT = ts;
        
        %Draw a line at the start/end crop bdys
        mainYLim = mainAxis.YLim;
        subYLim = subAxis.YLim;
        cropLines{1} = line(mainAxis,ts(1) * [1 1], mainYLim);
        cropLines{2} = line(mainAxis,ts(2) * [1 1], mainYLim);
        cropLines{3} = line(subAxis ,ts(1) * [1 1], subYLim);
        cropLines{4} = line(subAxis ,ts(2) * [1 1], subYLim);
    end

    function segSlider_callback(~,~)
        num = round(segSlider.Value);
        txtSlider.String = sprintf('%d/%d',num, length(stepdata.time));
        
        con = stepdata.contour{num};
        tim = stepdata.time{num};
        
        if length(con) > 1
            linfit = polyfit(tim, con, 1);
        else
            linfit = 0;
        end
        frc = stepdata.force{num};
        traceTxt.String = sprintf('%0.1fbp/s, %dpts\n%0.1f-%0.1fpN',-linfit(1), length(con), min(frc), max(frc) );
        conF = windowFilter(@mean, con, str2num(filtFact.String), str2double(deciFact.String)); %#ok<ST2NM>
        timF = windowFilter(@mean, tim, str2num(filtFact.String), str2double(deciFact.String)); %#ok<ST2NM>
        
        %Plot, unfiltered in grey, filtered in rainbow
        cla(mainAxis)
        plot(mainAxis,tim,con,'Color',[0.7 0.7 0.7]);
        filtLine = plot(mainAxis,timF,conF,'Color',getColor(num));
        zoom out
        %if the two limits are equal [segment has only one point], xlim errors - add eps to one side
        tl = [tim(1) tim(end)+eps(tim(end))];
        cl = [min(con) max(con)+eps(max(con))];
        if any(isnan(cl))
            cl = [0 1];
        end
        xlim(mainAxis, tl)
        ylim(mainAxis, cl)
        zoom reset
        
        %Gray out the rest of the trace
        xl = subAxis.XLim;
        xsl = mainAxis.XLim;
        yl = subAxis.YLim;
        shadexl = [xl([1 1]) xsl([1 1])];
        shadey = yl([1 2 2 1]);
        shadexr = [xsl([2 2]) xl([2 2]) ];
        delete(patchl);
        delete(patchr);
        patchl = patch(subAxis, 'XData', shadexl, 'YData', shadey, 'FaceAlpha', .25);
        patchr = patch(subAxis, 'XData', shadexr, 'YData', shadey, 'FaceAlpha', .25);
        %         rectangle(subAxis, 'Position', [xl(1) yl(1) xsl(1)-xl(1) yl(2)-yl(1)], 'EdgeColor', 'none', 'FaceColor', [1 1 1 .25]);
        %         rectangle(subAxis, 'Position', [xsl(2) yl(1) xl(2)-xsl(2) yl(2)-yl(1)], 'EdgeColor', 'none', 'FaceColor', [1 1 1 .25]);
        fixLimit_callback
    end

    function fileSlider_callback(~,~)
        file = fileSlider.String{round(fileSlider.Value)};
        loadFile_callback([], [], file, path)
    end

    function refilter_callback(~,~)
        delete(filtLine)
        dec = str2double(deciFact.String);
        fil = str2num(filtFact.String); %#ok<ST2NM>
        timF = windowFilter(@mean, tim, fil, dec);
        %smooth with rlo(w)ess
        if strcmp(filtFact.String, 'rlowess')
            conF = smooth( con, dec, 'rlowess');
            conF = conF(dec:dec:end);
        elseif strcmp(filtFact.String, 'rloess')
            conF = smooth( con, dec, 'rloess');
            conF = conF(dec:dec:end);
        else
            conF = windowFilter(@mean, con, fil, dec);
        end
        filtLine = plot(mainAxis,timF,conF,'Color',getColor(num));
    end

    function stepKV_callback(~,~)
        stepFind(1)
    end

    function stepHst_callback(~,~)
        stepFind(2)
    end

    function toWorksp_callback(~,~)
        assignin('base','guiC',con);
        assignin('base','guiT',tim);
        assignin('base','guiCf',conF);
        assignin('base','guiTf',timF);
        assignin('base','guistepdata',stepdata);
        assignin('base','guiHists',histData);
        assignin('base','guiHistBins',histBins);
    end

    function clrGraph_callback(~,~)
        %Last entry in Children will be the trace (filtered and unfiltered) - delete the rest
        arrayfun(@delete, mainAxis.Children(1:end-1))
        refilter_callback
        
%         %Delete text, pointing lines
%         len = length(mainAxis.Children);
%         toDel = false(1,len);
%         for i = 1:len
%             gobj = mainAxis.Children(i);
%             if isgraphics(gobj, 'Text')
%                 toDel(i)=true;
%             elseif isgraphics(gobj, 'Line') && length(gobj.XData) == 2;
%                 toDel(i)=true;
%             end
%         end
%         arrayfun(@delete, mainAxis.Children(toDel))
    end

    function clrHists_callback(~,~)
        structfun(@cla, histAxis)
        histData.kv = {'kv histData', zeros(size(histBins))};
        histData.hist = {'hist histData', zeros(size(histBins))};
    end

    function tempCrop_callback(~,~)
        [x, ~] = ginput(2);
        if x(1) < x(2) %lines picked left to right. = issorted(x)
            cropT = x;
        else %Clear temp crop
            cropT = [];
            fprintf('Temp Crop Removed')
        end
    end

    function permCrop_callback(~,~)
        [x, ~] = ginput(2);
        x = sort(x);
        cropfp = sprintf('%s\\CropFiles\\%s.crop', path, name);
        cropp = fileparts(cropfp);
        if ~exist(cropp, 'dir')
            mkdir(cropp)
        end
        fid = fopen(cropfp, 'w');
        fwrite(fid, sprintf('%f\n%f', x))
        fclose(fid);
        loadCrop_callback
    end

    function printFig_callback(~,~)
        print(fig, sprintf('.\\PhagePrtSc%s', datestr(now, 'yymmddHHMMSS')),'-dpng',sprintf('-r%d',96))
    end

%%%%Helpers
    function plotCell(ax, x, y)
        for i = 1:length(x)
            plot(ax, x{i}, y{i}, 'Color', getColor(i))
        end
    end

    function outColor = getColor(i)
        col0 = 2/3; %blue
        dcol = .1; %10 color cycle, enough to tell apart & slider fast-move is 10 segments
        h = mod(col0 + (i-1)*dcol,1); %Color wheel
        s = 1; %1 for bold colors, .25 for pastel-y colors
        v = .6; % too high makes yellow difficult to see, too low and everything is muddy
        outColor = hsv2rgb( h, s, v);
    end

    function stepFind(option)
        conFc = conF;
        timFc = timF;
        %If a tempCrop exists, apply it
        if ~isempty(cropT);
            cropind = timF >= cropT(1) & timF < cropT(2);
            if any(cropind)
                conFc = conF(cropind);
                timFc = timF(cropind);
            end
        end
        
        if length(conFc) < 100
            fprintf('Segment too small, skipping\n')
            return
        end
        
        switch option
            case 2
                [stepInd, stepMea] = findStepHistV7e(conFc, 0.1, [], [], dec);
                color = [0.5 0 0];
                sgn = -1;
                fn = 'kv';
            otherwise %K-V
                [stepInd, stepMea] = AFindStepsV4(conFc, single(round(str2double(KlViFact.String))));
                color = [0 0 0.5];
                sgn = 1;
                fn = 'hist';
        end
        
        %Create the stepping line and plot it
        len = length(stepInd);
        indX =[1 reshape([2:len-1;2:len-1],1,[]) len]; %This creates [1 2 2 3 3 4 4 ... len-1 len-1 len]
        indY = reshape([1:len-1; 1:len-1],1,[]); %This creates [1 1 2 2 3 3 4 4 5 5... len-1 len-1]
        lineX = timFc(stepInd(indX));
        lineY = stepMea(indY);
        %Remove old lines
        if ~isempty(stepLines{option})
            delete(stepLines{option})
        end
        stepLines{option} = line(mainAxis, lineX, lineY, 'Color', color);
        
        %Indicate step sizes on graph
        %Define how long we want the step size-indicating lines to be
        dt = .01;
        dc = 10;
        for i = 1:length(stepInd)-2;
            line(mainAxis, double(timFc(stepInd(i+1))*[1 1] + sgn*[0 dt]), double(stepMea(i+1)) * [1 1] + sgn*[0 dc], 'Color', color)
            text(mainAxis, double(timFc(stepInd(i+1))+sgn*dt), double(stepMea(i+1))+ sgn*dc, sprintf('%0.1f',stepMea(i)-stepMea(i+1)), 'Cli', 'on')
        end
        
        %Update Histogram
        stsz = -diff(stepMea);
        sthst = zeros(size(histBins));
        %Bin the step sizes
        for i = 1:length(histBins)-1
            sthst(i) = sum( stsz >= histBins(i) & stsz < histBins(i+1) );
        end
        %Add to histData, if new (else replace)
        histnam = sprintf('%sS%02d',name,num);
        ind = find(strcmp(histnam, histData.(fn)(:,1)));
        if ind
            histData.(fn){ind, 2} = sthst;
        else %Not found, append to end
            histData.(fn)(end+1,:) = {histnam sthst};
        end
        %Sum segment data
        histlen = length(histData.(fn)(:,2));
        histy = zeros(size(histBins));
        for i = 1:histlen
            histy = histy + histData.(fn){i,2};
        end
        %Plot
        barh(histAxis.(fn), histBins, histy);
        histAxis.(fn).YLim = histBins([1 end]);
    end

    function fixLimit_callback(~,~)
        tlim1 = [stepdata.time{num}(1) stepdata.time{num}(end)+eps(1e5)];
        tlim2 = [stepdata.time{1}(1) stepdata.time{end}(end)];
        clim1 = [grabmin(stepdata.contour{num}, stepdata.force{num}), grabmax(stepdata.contour{num}, stepdata.force{num})+eps(1e5)];
        clim2 = [min(cellfun(@grabmin, stepdata.contour, stepdata.force)), max(cellfun(@grabmax, stepdata.contour, stepdata.force))];
        if length(clim1) ~= 2
            clim1 = [0 6000];
        end
        if length(clim2) ~= 2
            clim2 = [0 6000];
        end
        zoom out
        xlim(mainAxis, tlim1)
        xlim(subAxis, tlim2)
        ylim(mainAxis, clim1)
        ylim(subAxis, clim2)
        zoom reset
    end

    function m = grabmin(c, f)
        m = double(min(c(f>5)));
        if isempty(m)
            m = 1e4;
        end
    end

    function m = grabmax(c, f)
        m = double(max(c(f>5)));
        if isempty(m)
            m = 0;
        end
    end

    function custom01_callback(~,~)
        select = 0;
        customB1.String = 'PWD';
        addpath('C:\Users\Alexander Tong\Box Sync\Year 2 Semester 2\Res\MATLAB\Testing\GUIDesign\PairwiseDist');
        fils  = [3 5 10 20];
        binsz = .1;
        pfils = [1 3 5 10] * .1/binsz;
        pfils = round(pfils);
        
        
        if ~select
            conpwd = con;
        else
            %plot PWD in separate window
            a = ginput(2);
            a = a(1:2);
            a = sort(a);
            conpwd = con(tim < a(2) & tim > a(1));
        end
        fg = figure('Name', 'PGUI PWDs');
        len = length(fils);
        hei = length(pfils);
        for i = 1:len
            for j = 1:hei
                sumPWDV1b(conpwd, fils(i), binsz, pfils(j));
                tempfig = gcf;
                tempax = gca;
                newax = copyobj(gca, fg);
                newax.Position = [(i-1)/len (j-1)/hei 1/len 1/hei];
                text(newax, newax.XLim(1), mean(newax.YLim), sprintf('[%d, %0.2f, %d]', fils(i), binsz, pfils(j)));
                xlim(newax, [0 30]);
                delete(tempfig);
            end
        end
    end

    function custom02_callback(~,~)
        customB2.String = 'PWDV2';
        sumPWDV2(con, .5);
        return
        a = ginput(2); %#ok<UNRCH>
        a = a(1:2);
        a = sort(a);
        sumPWDV2(con(tim < a(2) & tim > a(1)), 0.5, .05);
        
        
    end
end