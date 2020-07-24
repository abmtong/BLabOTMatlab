function PhageGUIcrop_V3()
%PhageGUI: For viewing phage .mat files.

%Add paths
thispath = fileparts(mfilename('fullpath'));
addpath ( thispath)                      %PhageGUICrop
addpath ([thispath filesep 'Helpers'])        %Filename sorter
addpath ([thispath filesep 'StepFind_KV'])    %windowFilter
addpath ([thispath filesep 'PairwiseDist'])   %PWD
%Load settings file (or create one)
path = 'C:\Data';
file = 'phageMMDDYYN00.mat';
name = 'mmddyyN00';
if exist('GUIsettings.mat', 'file')
    load('GUIsettings.mat', 'path');
else
    c = 'Settings file for PhageGUI'; %#ok<*NASGU> - A lot of uicontrols will be unused, too - OK
    save('GUIsettings.mat', 'c');
end

%%Declare variables for static workspace - or just shove everything in a struct [less readable]
stepdata = [];
cropLines = cell(1,4);
stepLines = {[] []};
kvlines = {};
filtLine = [];
cropT = [];
conF = [];
timF = [];
forF = [];
fil = [];
dec = [];

stripes = gobjects(1);

%Construct figure
scrsz = get(0, 'ScreenSize');
%Default size is 3/4 of each dimension
fig = figure('Name', 'PhageGUIcrop', 'Position', [scrsz(3:4)/8 .75*scrsz(3:4)], 'Visible', 'off');

panaxs = uipanel('Position', [.1 0 .9 .95]);
panaxs.BackgroundColor = [1 1 1]; %make it white
mainAxis = axes(panaxs, 'Position', [.05 .31 .80 .68]);
mainRAxis = axes(panaxs, 'Position', [.85 .31 .14 .68]); 

hold(mainAxis,'on')
hold(mainRAxis,'on')
subAxis  = axes(panaxs, 'Position', [.05 .05 .80 .2]);
hold(subAxis, 'on')
subRAxisB= axes(panaxs, 'Position', [.85, .05, .14, .1]);
subRAxisT= axes(panaxs, 'Position', [.85, .15, .14, .1]);
hold(subRAxisT, 'on')
hold(subRAxisB, 'on')

linkaxes([mainAxis, subAxis], 'x')
linkaxes([mainAxis, mainRAxis], 'y')

%Top row of buttons
pantop = uipanel('Position', [0 .95 1 .05]);
loadFile = uicontrol(pantop, 'Units', 'normalized', 'Position', [ 0, 0, .1, 1], 'String', 'Load File', 'Callback',@loadFile_callback);
loadCrop = uicontrol(pantop, 'Units', 'normalized', 'Position', [.1, 0, .1, 1], 'String', 'Load Crop', 'Callback',@loadCrop_callback);
permCrop = uicontrol(pantop, 'Units', 'normalized', 'Position', [.2, 0, .075, 1], 'String', 'Crop', 'Callback',@permCrop_callback);
permCropT= uicontrol(pantop, 'Style', 'text', 'Units', 'normalized', 'Position', [.275, .5, .025, .5], 'String', 'CropNum', 'Callback',[]);
permCropB= uicontrol(pantop, 'Style', 'edit', 'Units', 'normalized', 'Position', [.275, 0, .025, .5], 'String', '1', 'Callback',@loadCrop_callback);
measLine = uicontrol(pantop, 'Units', 'normalized', 'Position', [.3, 0, .1, 1], 'String', 'Measure', 'Callback',@measLine_callback);
trimTrace= uicontrol(pantop, 'Units', 'normalized', 'Position', [.4, 0, .1, 1], 'String', 'Trim', 'Callback',@trimTrace_callback);
toWorksp = uicontrol(pantop, 'Units', 'normalized', 'Position', [.5, 0, .05, 1], 'String', 'ToWkspace' , 'Callback',@toWorksp_callback);
locNoise = uicontrol(pantop, 'Units', 'normalized', 'Position', [.55, 0, .05, 1], 'String', 'LocNoise' , 'Callback',@locNoise_callback);
customB1 = uicontrol(pantop, 'Units', 'normalized', 'Position', [.60, 0.5, .05, .5], 'String', 'But01', 'Callback',@custom01_callback);
customB1t= uicontrol(pantop, 'Style', 'edit', 'Units', 'normalized', 'Position', [.60, 0, .05, .5], 'String', '[2.5, 0]', 'Callback', []);
customB2 = uicontrol(pantop, 'Units', 'normalized', 'Position', [.65, .5, .05, .5], 'String', 'But02', 'Callback',@custom02_callback);
customB3 = uicontrol(pantop, 'Units', 'normalized', 'Position', [.65, 0 , .05, .5], 'String', 'But03', 'Callback',@custom03_callback);
trcNotes = uicontrol(pantop, 'Units', 'normalized', 'Position', [.7, 0, .2, 1], 'Style', 'text', 'String', 'Comment');
fixLimit = uicontrol(pantop, 'Units', 'normalized', 'Position', [.9, 0, .1, 1], 'String', 'Print' , 'Callback',@printFig_callback);

%Left bar of text inputs
panlef = uipanel('Position',[0 0 .1 .95]);
panlef.BackgroundColor = [1 1 1]; %make it white
fileSlider= uicontrol(panlef, 'Style', 'slider', 'Units', 'normalized', 'Position', [0 .90 1 .1], 'Callback', @fileSlider_callback);
txtSlider = uicontrol(panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [.15 .901 .7 .05], 'String', '1');
clrGraph  = uicontrol(panlef,                  'Units', 'normalized', 'Position', [0 .875 1 .025], 'String', 'Clear Graph', 'Callback', @clrGraph_callback);

panFil = uipanel(panlef, 'Position', [0 .8 1 .075]);
filtFactT = uicontrol(panFil, 'Style', 'text', 'Units', 'normalized', 'Position', [0 .67 .5 .33], 'String', 'Filt Fact');
filtFact  = uicontrol(panFil, 'Style', 'edit', 'Units', 'normalized', 'Position', [0 .0 .5 .67], 'String', '10', 'Callback', @refilter_callback);
deciFactT = uicontrol(panFil, 'Style', 'text', 'Units', 'normalized', 'Position', [.5 .67 .5 .33], 'String', 'Dec Fact');
deciFact  = uicontrol(panFil, 'Style', 'edit', 'Units', 'normalized', 'Position', [.5 .0 .5 .67], 'String', '2', 'Callback', @refilter_callback);

panConMx= uipanel(panlef, 'Position', [0 .725 1 .075]);
conMinT = uicontrol(panConMx, 'Style', 'text', 'Units', 'normalized', 'Position', [0 .67 .5 .33], 'String', 'Y Min');
conMin  = uicontrol(panConMx, 'Style', 'edit', 'Units', 'normalized', 'Position', [0 .0 .5 .67], 'String', '0', 'Callback', @fixLimit_callback);
conMaxT = uicontrol(panConMx, 'Style', 'text', 'Units', 'normalized', 'Position', [.5 .67 .5 .33], 'String', 'Y Max');
conMax  = uicontrol(panConMx, 'Style', 'edit', 'Units', 'normalized', 'Position', [.5 .0 .5 .67], 'String', '4000', 'Callback', @fixLimit_callback);

panPlotX = uipanel(panlef, 'Position', [0 .65 1 .075]);
plotCal   = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [0  .5 .5 .5], 'String', 'Plot Cal', 'Callback', @plotCal_callback);
plotOff   = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [.5 .5 .5 .5], 'String', 'Plot Off', 'Callback', @plotOff_callback);
plotRaw   = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [0  0  .5 .5], 'String', 'Plot Raw', 'Callback', @plotRaw_callback);

radioKDF  = uibuttongroup(panlef,                       'Units', 'normalized', 'Position', [0 .55 1 .1 ], 'SelectionChangedFcn', @kdf_callback);
radioKDF1 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [0 .66 5 .34], 'String', 'No KDF', 'Callback', []);
radioKDF2 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [0 .33 1 .33], 'String', 'KDF Quick', 'Callback', []);
radioKDF3 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [0 .0  1 .33], 'String', 'KDF Full', 'Callback', []);
radioKDF4 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [.5 .66  .5 .34], 'String', 'K-V', 'Callback', []);
radioKDF2t= uicontrol(radioKDF, 'Style', 'edit', 'Units', 'normalized', 'Position', [.7 .33 .3 .33], 'String', '20', 'Callback', @kdf_callback);
radioKDF3t= uicontrol(radioKDF, 'Style', 'edit', 'Units', 'normalized', 'Position', [.7 0   .3 .33], 'String', '1', 'Callback', @kdf_callback);
radioKDF2.Value = true;

%Load first file
loadFile_callback

fig.Visible = 'on';

%%Callbacks
    function loadFile_callback(~,~, f, p)
        if nargin < 4
            %Prompt the user to select a file
            [f, p] = uigetfile([path filesep 'phage*.mat'], 'MultiSelect','off','Pick a Phi29 Trace');
            if ~p %No file selected, do nothing
                return
            end
            file = f;
            path = p;
            save('GUIsettings.mat', 'path', '-append')
            %Format the slider
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
        else
            file = f;
            path = p;
        end
        %Load the file
        load([path file],'stepdata');
        name = file(6:end-4);
        cla(mainAxis)
        fig.Name = sprintf('PhageGUIcrop %s', name);
        
        %Load comment
        if isfield(stepdata,'comment')
            trcNotes.String = stepdata.comment;
        else
            trcNotes.String = '';
        end
        
        fileSlider.Value = find(cellfun(@(x) strcmp(x, file),fileSlider.String),1);
        txtSlider.String = sprintf('%s\n%d/%d', name, round(fileSlider.Value), fileSlider.Max);
        
        loadCrop.String = 'Load Crop';
        cropT = [];
        
        %Plot
        refilter_callback
        fixLimit_callback
        loadCrop_callback
        
    end

    function loadCrop_callback(~,~)
        cropT = [];
        %Create path of crop file
        cropstr = permCropB.String;
%         i = str2double(cropstr);
            if strcmp(cropstr,'1')
                cropstr = '';
            end
            cropfp = sprintf('%s\\CropFiles%s\\%s.crop', path, cropstr, name);
            fid = fopen(cropfp);
            if fid == -1
                loadCrop.String = 'Crop not found';
%                 fprintf('Crop not found for %s\n', name)
                return
            else
                loadCrop.String = 'Load Crop';
            end
            
            cropT = textscan(fid, '%f');
            fclose(fid);
            cropT = cropT{1};
            
            %Delete old lines
            if ~isempty(cropLines{1,1})
                cellfun(@delete, cropLines(1,:))
            end
            
            %Draw a line at the start/end crop bdys
            mainYLim = mainAxis.YLim;
            subYLim = subAxis.YLim;
            cropLines{1,1} = line(mainAxis,cropT(1) * [1 1], mainYLim, 'Color', 'r');
            cropLines{1,2} = line(mainAxis,cropT(2) * [1 1], mainYLim, 'Color', 'r');
            cropLines{1,3} = line(subAxis ,cropT(1) * [1 1], subYLim, 'Color', 'r');
            cropLines{1,4} = line(subAxis ,cropT(2) * [1 1], subYLim, 'Color', 'r');
            
            if mainAxis.XLim(1) > cropT(1)
                mainAxis.XLim = [cropT(1)-.5 mainAxis.XLim(2)];
            end
            if mainAxis.XLim(2) < cropT(2)
                mainAxis.XLim = [mainAxis.XLim(1) cropT(2)+0.5];
            end
        
    end

    function fileSlider_callback(~,~)
        file = fileSlider.String{round(fileSlider.Value)};
        loadFile_callback([], [], file, path)
    end

    function refilter_callback(~,~)
        %Filter
        fil = str2num(filtFact.String); %#ok<ST2NM>
        dec = str2double(deciFact.String);
        if ~isempty(fil) || dec ~= 1
            conF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.contour,'UniformOutput',0);
            timF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.time,'UniformOutput',0);
            forF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.force,'UniformOutput',0);
        else
            conF = stepdata.contour;
            timF = stepdata.time;
            forF = stepdata.force;
        end
        
        %Plot force on bottom. Don't use cla to keep current window.
        arrayfun(@delete,subAxis.Children)
        cellfun(@(x,y)plot(subAxis, x, y, 'Color', .7 * [1 1 1]), stepdata.time, stepdata.force)
        plotCell(subAxis, timF, forF)
        
        %Plot contour on top
        arrayfun(@delete,mainAxis.Children)
        %Hijacked for Moffit POV (1.25kHz raw data)
%         fulconF = cellfun(@(x)windowFilter(@mean, x, [], 2),stepdata.contour,'UniformOutput',0);
%         fulti mF = cellfun(@(x)windowFilter(@mean, x, [], 2),stepdata.time,'UniformOutput',0);
%         cellfun(@(x,y)plot(mainAxis, x, y, 'Color', [.7 .7 .7]), fultimF, fulconF, 'UniformOutput', false);
        %/Hijack
        cellfun(@(x,y)plot(mainAxis, x, y, 'Color', .7 * [1 1 1]), stepdata.time, stepdata.contour, 'UniformOutput', false);
        filtLine = plotCell(mainAxis, timF, conF);
        
        %If cut segments are saved, plot in gray
        if isfield(stepdata, 'cut')
            cconF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.cut.contour,'UniformOutput',0);
            ctimF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.cut.time,'UniformOutput',0);
            cforF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.cut.force,'UniformOutput',0);
            cellfun(@(x,y)plot(mainAxis,x,y,'Color',[.7 .7 .7]), stepdata.cut.time, stepdata.cut.contour)
            cellfun(@(x,y)plot(subAxis,x,y,'Color',[.7 .7 .7]), stepdata.cut.time, stepdata.cut.force)
            cellfun(@(x,y)plot(mainAxis,x,y,'Color',[.2 .2 .2]), ctimF, cconF)
            cellfun(@(x,y)plot(subAxis,x,y,'Color',[.2 .2 .2]), ctimF, cforF)
        end
        locNoise_callback
        kdf_callback
    end

    function kdf_callback(src,~)
        %don't refilter if we change a KDF filter option but that filter isn't selected
        if nargin> 1 && isequal(src, radioKDF2t) && ~radioKDF2.Value
            return
        end
        if nargin> 1 && isequal(src, radioKDF3t) && ~radioKDF3.Value
            return
        end
                %plot KDF if asked to
        cla(mainRAxis)
        cla(subRAxisT)
        cla(subRAxisB)
        %gather contour together, apply crop to con if exists
        if radioKDF2.Value || radioKDF3.Value
            cons = [conF{:}];
            tims = [timF{:}];
            loadCrop_callback
            if ~isempty(cropT)
                cons = cons(tims > cropT(1) & tims < cropT(2));
            end
            hbinsz = 0.1;
            if radioKDF2.Value
                %calc kdf by histcounts
                minc = floor(min(cons)/hbinsz);
                maxc = ceil(max(cons)/hbinsz);
                histx = (minc:maxc) * hbinsz;
                histy = histcounts(cons, histx);
                histxx = histx(1:end-1) + hbinsz/2;
                histy = smooth(histy, str2double(radioKDF2t.String) );
                plot(mainRAxis, histy, histxx, 'Color', 'b');
            elseif radioKDF3.Value
                %calc kdf, can either use a user-input gaussian width or one based on @estimateNoise (input then is a scale factor)
                [histy, histxx] = kdf(cons, hbinsz, str2double(radioKDF3t.String)); %estimateNoise(cons)/
                plot(mainRAxis, histy, histxx, 'Color', 'b');
                
                %kdf should be smooth, so use findpeaks to get peak locations for step size
                pkhei = findpeaks(double(histy), double(histxx));
                trhei = findpeaks(-double(histy), double(histxx));
                %Set MinPeakProminence to be the median peak difference
                medpk = median(pkhei);
                medtr = -median(trhei);
                mpp = (medpk - medtr) / 2;
                [pkhei, pkloc] = findpeaks(double(histy), double(histxx), 'MinPeakProminence', mpp);
                pkcen = (pkloc(1:end-1) + pkloc(2:end))/2;
                pkheis = mean([pkhei(1:end-1); pkhei(2:end)], 1);
                pkdsts = diff(pkloc);
                arrayfun(@(x,y,z)text(mainRAxis,y,x,sprintf('%0.2f',z), 'Clipping', 'on'), pkcen, pkheis, pkdsts)
                
                %plot lines peak-to-peak
                %             arrayfun(@(x1,x2,y1,y2) line(mainRAxis, [x1 x2], [y1 y2]), pkhei(1:end-1), pkhei(2:end), pkloc(1:end-1), pkloc(2:end))
                
                %plot lines from 0 to peak v1
                %             arrayfun(@(x,y) line(mainRAxis, [0 x], [y y]), pkhei, pkloc)
                
                %plot lines from 0 to peak as one long line (better for ui?)
                lx = [pkloc; pkloc; pkloc];
                lx = lx(:);
                ly = [zeros(size(pkhei)); pkhei; zeros(size(pkhei))];
                ly = ly(:);
                line(mainRAxis, ly, lx);
                
                %Calculate step size histogram
                
                sm=1;
                if sm %use 0.1 bin size, then smooth
                    binsz = .1;
                else %use f-d rule, gives large bins
                    binfd = iqr(pkdsts) * 2 * length(pkdsts)^(-1/3);
                    binsz = ceil(binfd * 10)/10;
                end
                
                xs = -10*binsz:binsz:21+binsz;
                xs = xs - binsz/2; %shift by binsz/2 bc step sizes might differ by eps
                cts = histcounts(pkdsts, xs);
                %plot on both subR axes
                xp = xs(1:end-1)+ binsz/2;
                if sm
                    ctss = smooth(cts, 5)';
                else
                    ctss = cts;
                end
                bar(subRAxisT, xp, ctss, 'EdgeColor', 'none')
                axis(subRAxisT, 'tight')
                bar(subRAxisB, xp, ctss, 'EdgeColor', 'none')
                axis(subRAxisB, 'tight')
                %on top, plot 0-5
                xlim(subRAxisT, [0 5])
                %on bottom, 0-20
                xlim(subRAxisB, [0 20])
                
                %Fit gaussian
                %                 gauss = @(x0, x) exp( -(x-x0(1)).^2 / 2 / x0(2) ) * x0(3);
                %                 lsqopts = optimoptions('lsqcurvefit');
                %                 lsqopts.Display = 'none';
                %                 lb = [0 0 0];
                %                 ub = [20 20 length(cts)];
                %                 fit = lsqcurvefit(gauss, [10 2 max(cts)], xp, cts, lb, ub, lsqopts);
                
                [fit, gauss] = fitgauss_iter2(xp(2:end-1), ctss(2:end-1), [-2 .5]);
                if isempty(gauss) %could not fit
                    return
                end
                cellfun(@(x)plot(subRAxisT, xp, gauss(x, xp)), fit);
                cellfun(@(x)plot(subRAxisB, xp, gauss(x, xp)), fit);
                %display fit stats as text.
                fitm = reshape([fit{:}], 3, [])';
                cellfun(@(x) text(subRAxisB, x(1), 1.1*gauss(x, x(1)), sprintf('%0.2f+-%0.2f', x(1), x(2)), 'HorizontalAlignment', 'left'), fit)
                cellfun(@(x) text(subRAxisT, x(1), 1.1*gauss(x, x(1)), sprintf('%0.2f+-%0.2f', x(1), x(2)), 'HorizontalAlignment', 'left'), fit)
                %                     text(subRAxisB, 20, mean(get(subRAxisB, 'ylim')), sprintf('gauss can''t be fit \n(probably too few N)'), 'HorizontalAlignment', 'right')
            end
            mainRAxis.XTickLabel = [];
        elseif radioKDF4.Value
            cellfun(@delete,kvlines)
            %For speed, apply K-V only if cropped
            if ~isempty(cropT)
                cf = cellfun(@(x,y) y(x > cropT(1) & x < cropT(2)), stepdata.time, stepdata.contour, 'Un', 0);
                tf = cellfun(@(x,y) y(x > cropT(1) & x < cropT(2)), stepdata.time, stepdata.time, 'Un', 0);
            else
                return
            end
%             wid = str2double(radioKDF2t.String);
%             pf = single(str2double(radioKDF3t.String));
            wid = 5;
            pf = single(5);
            cf = cellfun(@(x)windowFilter(@mean, x, [], wid), cf, 'un',0);
            tf = cellfun(@(x)windowFilter(@mean, x, [], wid), tf, 'un',0);
            %Remove empty
            cf(cellfun(@isempty,cf)) = [];
            tf(cellfun(@isempty,tf)) = [];
            
            [~, ~, trs, sszs] = BatchKV(cf, pf, 500, 0);
            kvlines = cellfun(@(x,y)plotkv(mainAxis, x, y, 'LineWidth', 1, 'Color', 'r'),tf,trs, 'Un',0);
            %Calculate step size histogram
            binsz = .1;
            xs = -1:0.1:21;
            xs = xs - binsz/2; %shift by binsz/2 bc step sizes might differ by eps
            cts = histcounts(sszs, xs);
            %plot on both subR axes
            xp = xs(1:end-1)+ binsz/2;
            ctss = smooth(cts, 5)';
%             ctss = cts;
            bar(subRAxisT, xp, ctss, 'EdgeColor', 'none')
            axis(subRAxisT, 'tight')
            bar(subRAxisB, xp, ctss, 'EdgeColor', 'none')
            axis(subRAxisB, 'tight')
            %on top, plot 0-5
            xlim(subRAxisT, [0 5])
            %on bottom, 0-20
            xlim(subRAxisB, [0 20])
        end
    end

    function toWorksp_callback(~,~)
        assignin('base','guiCf',conF);
        assignin('base','guiTf',timF);
        assignin('base','guistepdata',stepdata);
        assignin('base','guicropT',cropT);
    end

    function clrGraph_callback(~,~)
        %Delete all lines, text objects
        len = length(mainAxis.Children);
        %Is it faster to grab all of mainAxis.Children and index the reference?~~~~~~~~~~~~~
        toDel = false(1,len);
        for i = 1:len
            gobj = mainAxis.Children(i);
            if isgraphics(gobj, 'Text')
                toDel(i)=true;
            elseif isgraphics(gobj, 'Line') && length(gobj.XData) == 2;
                toDel(i)=true;
            end
        end
        arrayfun(@delete, mainAxis.Children(toDel))
    end

    function measLine_callback(~,~)
        [x, y] = ginput(2);
        dx = abs(diff(x));
        dy = abs(diff(y));
        
        line(x,y)
        text(x(end),y(end),sprintf('(dx,dy,m) = (%0.2f, %0.2f, %0.2f)\n',dx,dy,dy/dx), 'Clipping', 'on')
    end

    function permCrop_callback(~,~)
        cropstr = permCropB.String;
        if strcmp(cropstr,'1')
            cropstr = '';
        end
        [x, ~] = ginput(2);
        %If crop is ended by pressing enter, skip cropping
        if length(x) ~= 2
            return
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

    function trimTrace_callback(~,~)
        [x,~] = ginput(2);
        x = sort(x);
        
        if length(x) ~= 2
            return
        end
        
        ln1 = line([1 1]*x(1), [0 1e4]);
        ln2 = line([1 1]*x(2), [0 1e4]);
        drawnow
        switch questdlg('Trim here?','Trim?','Yes','No', 'No');
            case 'Yes'
                %Find index of first greater than start, last less than end
                cellfind = @(ce) (find(ce > x(1),1));
                cellfind2 = @(ce) (find(ce < x(2),1, 'last'));
                inds = cellfun(cellfind, stepdata.time, 'UniformOutput', false); 
                inds2 = cellfun(cellfind2, stepdata.time, 'UniformOutput', false);
                %Act on every field that is a cell
                fnames = fieldnames(stepdata);
                %Probably better to reverse j and k loops, but negligible performance difference
                for j = 1:length(fnames)
                    if iscell(stepdata.(fnames{j}))
                        temp = stepdata.(fnames{j});
                        for k = length(inds):-1:1 %process in reverse so cell removal, e.g. a(3) = [], doesn't disrupt indicies
                            %Check that there exists a min and a max - i.e. is within inds
                            st = inds{k};
                            en = inds2{k};
                            if ~isempty(st) && ~isempty(en)
                                temp2 = temp{k};
                                ln = length(temp2);
                                %Check for entire removal
                                if st ==1 && en == ln
                                    temp(k) = [];
                                    continue
                                    %Check for middle removal (both indicies not at bdy - then need to segment in two)
                                elseif st ~= 1 && en ~= ln
                                    left = temp2(1:st);
                                    right = temp2(en:end);
                                    temp = [temp(1:k-1) {left right} temp(k+1:end)];
                                    %Half removal
                                else
                                    temp2(st:en) = [];
                                    temp{k} = temp2;
                                end
                            end
                        end
                        stepdata.(fnames{j}) = temp;
                    end
                end
                %Remove cut bits that no longer are necessary
                if isfield(stepdata, 'cut')
                    fnames = fieldnames(stepdata.cut);
                    keepind = ~cellfun(@(x) any(x<stepdata.time{1}(1) | x>stepdata.time{end}(end)), stepdata.cut.time);
                    for j = 1:length(fnames)
                        stepdata.cut.(fnames{j}) = stepdata.cut.(fnames{j})(keepind);
                    end
                end
                
%                 switch questdlg('Edit comment?','Comment?','Yes','No', 'No');
%                     case 'Yes'
%                         resp = inputdlg('Comment', 'Enter new comment', [1,80], {trcNotes.String});
%                         if ~isempty(resp)
%                             trcNotes.String = resp{1};
%                             stepdata.comment = trcNotes.String;
%                         end
%                 end
                save([path file], 'stepdata')
                loadFile_callback([], [], file, path)
            case 'No'
                delete(ln1)
                delete(ln2)
        end
    end

    function fixLimit_callback(~,~)
        tlim = [stepdata.time{1}(1) stepdata.time{end}(end)];
%         clim = [min(cellfun(@min, stepdata.contour)), max(cellfun(@max, stepdata.contour))];
        flim = [min(cellfun(@min, stepdata.force)), max(cellfun(@max, stepdata.force))];
%         clim = [2500 5000];
        cmin = max(str2double(conMin.String), min(cellfun(@grabmin, stepdata.contour, stepdata.force)));
        cmax = min(str2double(conMax.String), max(cellfun(@grabmax, stepdata.contour, stepdata.force)));
        clim = [cmin cmax];
        if length(clim) ~= 2
            clim = [0 6000]; %fallback if it messes up
        end
        zoom(mainAxis, 'out')
        zoom(subAxis, 'out')
        
        xlim(mainAxis, tlim)
        try
            ylim(mainAxis, clim)
        catch
            ylim(mainAxis, [0 1e4])
        end
        ylim(subAxis, flim)
        zoom(mainAxis, 'reset')
        zoom(subAxis, 'reset')
        
    end

    function m = grabmin(c, f)
        m = double(min(c(f>1)));
        if isempty(m)
            m = 1e4;
        end
    end

    function m = grabmax(c, f)
        m = double(max(c(f>1)));
        if isempty(m)
            m = 0;
        end
    end

    function locNoise_callback(~,~)
        %Plot the local noise levels every so-and-so points
        netlen = sum(cellfun(@length, stepdata.time));
        if netlen > 1e5
            noiwin = round(netlen/1e2);
        else
            noiwin = 500;
        end
        szs = cellfun(@length, stepdata.time);
        szs = floor(szs/noiwin);
        for i = 1:length(stepdata.time)
%             cfil = stepdata.contour{i} - smooth(stepdata.contour{i},125)';
            for j = 1:szs(i)
                %Estimate noise, annotate with text
                ran = (j-1)*noiwin+1:j*noiwin;
                textt = double(mean(stepdata.time{i}(ran([1 end]))));
                textc = double(mean(stepdata.contour{i}(ran)));
%                 textv = std(cfil(ran));
                textv = sqrt(estimateNoise(stepdata.contour{i}(ran), [], 2));
                if j == 1
                    pfit = @(x)polyfit(1:length(x), x, 1);
                    textvel = pfit(stepdata.contour{i});
                    textvel = -textvel(1) * 2500;
                    text(mainAxis, textt, textc+20, sprintf('%0.2f, %0.1fv',textv, textvel), 'Rotation', 90, 'Clipping', 'on')
                else
                    text(mainAxis, textt, textc+20, sprintf('%0.2f',textv), 'Rotation', 90, 'Clipping', 'on')
                end
            end
        end
    end

    function plotCal_callback(~,~)
        if isfield(stepdata, 'cal')
            plotcal(stepdata.cal);
        end
    end

    function plotOff_callback(~,~)
        if isfield(stepdata, 'off')
            plotoff(stepdata.off);
        end
    end

    function plotRaw_callback(~,~)
        plotraw(stepdata)
        xlim(mainAxis.XLim)
    end

    function custom01_callback(~,~)
        %{
        customB1.String = 'ConSec';
        a = ginput(2);
        a = sort(a(1:2));
        %find feedback cycle
        tstart = a(1);
        tend = a(2);
        inds = cellfun(@(x) ~isempty(find(x>tstart,1)) , stepdata.time);
        fcyc = find(inds,1);
        guiConSec = stepdata.contour{fcyc}( stepdata.time{fcyc} > tstart & stepdata.time{fcyc} < tend );
        assignin('base', 'guiConSec', guiConSec);
        %}

        customB1.String = 'AspectRatio';
        xl = mainAxis.XLim;
        yl = mainAxis.YLim;
        %Aspect ratio is 80px = 5bp, 50px = 200ms -> 1bp for 64ms on a square axis
        %Keep 
        yr = diff(yl);
        
        %get axes size from sizes of containing panels
        fgps = fig.Position(3:4);
        pnsz = panaxs.Position(3:4);
        axsz = mainAxis.Position(3:4);
        axdim = fgps.*pnsz.*axsz;
        %Moffit: 1bp for 0.064s; Group Meeting: 15bp per .200s = .013
        xr = yr * .03 * axdim(1)/axdim(2);
        mainAxis.XLim = xl(1) + [0 xr];
        cellfun(@(x)set(x,'LineWidth',1.5), filtLine)
        
        
        xl = mainAxis.XLim;
        yl = mainAxis.YLim;
        args = str2num(customB1t.String); %#ok<ST2NM>
        ssz = args(1);
        soff = args(2);
        liney = soff:ssz:1e4;
        lineycrop = liney(liney > yl(1) & liney < yl(2));
        
        %make 2.5 2.5 2.5 1.1 steps
        if length(args) > 2
            ssz = -args(3);
            lineycrop = [lineycrop' lineycrop'+ssz lineycrop'+2*ssz lineycrop'+3*ssz];
            lineycrop = lineycrop(:)';
        end
        
        xl2 = mainRAxis.XLim;
        
        delete(stripes);
        stripes = gobjects(2, length(lineycrop));
        for i = 1:length(lineycrop)
            stripes(1,i) = line(mainAxis,  xl, lineycrop(i) * [1 1], 'LineStyle', ':', 'Color', [1 1 1]*0);
            stripes(2,i) = line(mainRAxis, xl2, lineycrop(i) * [1 1], 'LineStyle', ':', 'Color', [1 1 1]*0);
        end
        
    end

    function custom02_callback(~,~)
        addpath([thispath '\PairwiseDist']); %PWD code
        customB2.String = 'Take PWD';
        %plot PWD in separate window
        a = ginput(2);
        a = a(1:2);
        a = sort(a);
        cropfcn = @(x, y, z) x(y>z(1) & y<z(2) ); %cropfcn(con, tim, a) = con(tim>a(1) & tim<a(2))
        concrop = cellfun(@(x,y)cropfcn(x,y,a), stepdata.contour, stepdata.time, 'uni', 0);
%         concrop = [concrop{:}];
        concrop = concrop(~cellfun(@isempty, concrop));
        
        fils  = [3 5 10 25];
        binsz = .1;
        pfils = [1 5 10] * .1/binsz;
        pfils = round(pfils);
        
        %plot PWD in separate window
        fg = figure('Name', 'PGUI PWDs');
        len = length(fils);
        hei = length(pfils);
        for i = 1:len
            for j = 1:hei
                sumPWDV1b(concrop, fils(i), binsz, pfils(j));
                tempfig = gcf;
                tempax = gca;
                newax = copyobj(gca, fg);
                newax.Position = [(i-1)/len (j-1)/hei 1/len 1/hei];
                text(newax, newax.XLim(1), mean(newax.YLim), sprintf('[%d, %0.2f, %d]', fils(i), binsz, pfils(j)));
                xlim(newax, [0 30]);
                delete(tempfig);
            end
        end
        
        %assignin
        [pwd, pwdx] =  sumPWDV1b(concrop,10,0.1,5); close(gcf);
        ain.x = pwdx;
        ain.y = pwd;
        ain.con = concrop;
        ain.name = name;
        ain.time = a;
        assignin('base', 'guiPWD', ain)
    end

    function custom03_callback(~,~)
        
        %{
        customB3.String = 'GetBacktracks';
        a = ginput(4); %select left, start bt, end bt, right
        %get relevant numbers
        %extract left to right
        cropt = a([1 4]);
        %extract backtrack stats
        btt = a([2 3]);
        btc = a([2 3], 2);
        
        %extract from guistepdata
        cropfcn = @(x, y, z) x(y>z(1) & y<z(2) ); %cropfcn(con, tim, a) = con(tim>a(1) & tim<a(2))
        concrop = cellfun(@(x,y)cropfcn(x,y,cropt), stepdata.contour, stepdata.time, 'uni', 0);
        frccrop = cellfun(@(x,y)cropfcn(x,y,cropt), stepdata.force, stepdata.time, 'uni', 0);
        timcrop = cellfun(@(x,y)cropfcn(x,y,cropt), stepdata.time, stepdata.time, 'uni', 0);
        keepind = ~cellfun(@isempty, concrop);
        
        stepback.con = concrop(keepind);
        stepback.tim = timcrop(keepind);
        stepback.frc = frccrop(keepind);
        stepback.t = cropt;
        stepback.sb = [btt(:) btc(:)];
        %save
        sbpath = sprintf('%s\\Backtracks\\', path);
        if ~isdir(sbpath)
            mkdir(sbpath)
        end
        save(sprintf('%s\\Backtracks\\phBT%sS%0.2f.mat', path, name, btt(1)), 'stepback')
        
        pan on
        %}
        

        customB3.String = 'ScaleFCs';
        str = permCropB.String;
        if strcmp(str, '1')
            str = '';
        end
        tmp = FCrescale([path file], str);
        if ~isempty(tmp)
            stepdata = tmp;
            refilter_callback
        end
        %{
        
        customB3.String = 'Recalc Contour';
        %XWLC fcn
        function outXpL = XWLC(F, P, S, kT)
            %Simplification var.s
            C1 = F*P/kT;
            C2 = exp(nthroot(900./C1,4));
            outXpL = 4/3 ...
                + -4./(3.*sqrt(C1+1)) ...
                + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
                + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
                + F./S;
        end
        
        %}
        
        %Recalc XWLC
        %DNA: PL=50, SM=700,nm/bp = 0.34
        %GheD: 30, 1200
        %RNA: 60 , 400, 0.27
        %One on new: 43, 845
        %Hyb?
        %'XWLC PL(nm), 50D 40R 35H' 'XWLC SM(pN), 700D 450R 500H' 'kT (pN nm)' 'Rise/bp (nm/bp)'...
        %Psor30: 50 500; 4% incr.
        %Psor100: 45 370; 8% incr.
%         pl = 40;
%         sm = 700;
%         npb = 0.34;
%         stepdata.contour = cellfun(@(x,y) x ./ XWLC(y, pl, sm, 4.14)./ npb, stepdata.extension, stepdata.force, 'uni', 0);
%         stepdata.cut.contour = cellfun(@(x,y) x ./ XWLC(y, pl, sm, 4.14)./ npb, stepdata.cut.extension, stepdata.cut.force, 'uni', 0);
%         refilter_callback
    end

    function printFig_callback(~,~)
        print(fig, sprintf('.\\PhagePrtSc%s', datestr(now, 'yymmddHHMMSS')),'-dpng',sprintf('-r%d',96))
    end

%%%%Helpers
    function varargout = plotCell(ax, x, y)
        %Wrote this before I could write:
        %out = cellfun(@(xx,yy) plot(ax, xx, yy), x, y, 'Un', 0);
        %But this one handles color, too, so ok
        out = cell(1,length(x));
        for i = 1:length(x)
            out{i} = plot(ax, x{i}, y{i}, 'Color', getColor(i));
        end
        if nargout
            varargout{1} = out;
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
end