function ElRoGUI()
%PhageGUI, but now programmatic - GUIDE has bad limitations/bugs

%Add paths
thispath = fileparts(mfilename('fullpath'));
addpath ( thispath)                      %PhageGUICrop
% addpath ([thispath filesep 'Helpers'])        %Filename sorter
% addpath ([thispath filesep 'StepFind_KV'])    %windowFilter
% addpath ([thispath filesep 'PairwiseDist'])   %PWD
%Load settings file (or create one)
path = 'C:\Data';
file = 'A001.mat';
name = 'A001';
if exist('GUIsettings.mat', 'file')
    load('GUIsettings.mat', 'path');
else
    c = 'Settings file for PhageGUI'; %#ok<*NASGU> - A lot of uicontrols will be unused, too - OK
    save('GUIsettings.mat', 'c');
end

%Declare variables for static workspace - or just shove everything in a struct [less readable]
eldata = [];
cropLines = cell(1,4);
stepLines = {[] []};
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
fig = figure('Name', 'ElRoGUI', 'Position', [scrsz(3:4)/8 .75*scrsz(3:4)], 'Visible', 'off');

panaxs = uipanel('Position', [.1 0 .9 .95]);
panaxs.BackgroundColor = [1 1 1]; %make it white
mainAxis = axes(panaxs, 'Position', [.05 .31 .80 .68]);
mainRAxis = axes(panaxs, 'Position', [.85 .31 .14 .68]); 
hold(mainAxis,'on')
hold(mainRAxis,'on')
subAxis  = axes(panaxs, 'Position', [.05 .05 .80 .2]);
hold(subAxis, 'on')
subRAxis = axes(panaxs, 'Position', [.85, .05, .14, .2]);
subRAxisB= axes(panaxs, 'Position', [.85, .05, .14, .1]);
subRAxisT= axes(panaxs, 'Position', [.85, .15, .14, .1]);
hold(subRAxisT, 'on')
hold(subRAxisB, 'on')
subRAxisB.Position = subRAxisB.Position + [1 0 0 0];
subRAxisT.Position = subRAxisT.Position + [1 0 0 0];

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
customB1t= uicontrol(pantop, 'Style', 'edit', 'Units', 'normalized', 'Position', [.60, 0, .05, .5], 'String', '[0.33, 0]', 'Callback', []);
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
filtFact  = uicontrol(panFil, 'Style', 'edit', 'Units', 'normalized', 'Position', [0 .0 .5 .67], 'String', '20', 'Callback', @refilter_callback);
deciFactT = uicontrol(panFil, 'Style', 'text', 'Units', 'normalized', 'Position', [.5 .67 .5 .33], 'String', 'Dec Fact');
deciFact  = uicontrol(panFil, 'Style', 'edit', 'Units', 'normalized', 'Position', [.5 .0 .5 .67], 'String', '5', 'Callback', @refilter_callback);

panConMx= uipanel(panlef, 'Position', [0 .725 1 .075]);
conMinT = uicontrol(panConMx, 'Style', 'text', 'Units', 'normalized', 'Position', [0 .67 .5 .33], 'String', 'Y Min');
conMin  = uicontrol(panConMx, 'Style', 'edit', 'Units', 'normalized', 'Position', [0 .0 .5 .67], 'String', '-100', 'Callback', @fixLimit_callback);
conMaxT = uicontrol(panConMx, 'Style', 'text', 'Units', 'normalized', 'Position', [.5 .67 .5 .33], 'String', 'Y Max');
conMax  = uicontrol(panConMx, 'Style', 'edit', 'Units', 'normalized', 'Position', [.5 .0 .5 .67], 'String', '100', 'Callback', @fixLimit_callback);

panPlotX = uipanel(panlef, 'Position', [0 .65 1 .075]);
plotCal   = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [0  .5 .5 .5], 'String', 'Plot Ang Hist', 'Callback', @plotCal_callback);
plotOff   = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [.5 .5 .5 .5], 'String', 'Calc Cal/Prot', 'Callback', @plotOff_callback);
plotRaw   = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [0  0  .5 .5], 'String', 'Swap Rots', 'Callback', @plotRaw_callback);
plotForce = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [.5  0  .5 .5], 'String', 'Plot Force', 'Callback', @plotForce_callback);


radioKDF  = uibuttongroup(panlef,                       'Units', 'normalized', 'Position', [0 .55 1 .1 ], 'SelectionChangedFcn', @kdf_callback);
radioKDF1 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [0 .66 1 .34], 'String', 'No KDF', 'Callback', []);
radioKDF2 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [0 .33 1 .33], 'String', 'KDF Quick', 'Callback', []);
radioKDF3 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [0 .0  1 .33], 'String', 'KDF Full', 'Callback', []);
radioKDF2t= uicontrol(radioKDF, 'Style', 'edit', 'Units', 'normalized', 'Position', [.7 .33 .3 .33], 'String', '5', 'Callback', @kdf_callback);
radioKDF3t= uicontrol(radioKDF, 'Style', 'edit', 'Units', 'normalized', 'Position', [.7 0   .3 .33], 'String', '.1', 'Callback', @kdf_callback);
radioKDF2.Value = true;

checkboxs = uibuttongroup(panlef,                       'Units', 'normalized', 'Position', [0 .4 1 .15 ], 'SelectionChangedFcn', []);
cboxall   = uicontrol(checkboxs, 'Style', 'checkbox',   'Units', 'normalized', 'Position', [0 .75 1 .25], 'String', 'All Files', 'Value', true, 'Callback', []);
cboxfix   = uicontrol(checkboxs, 'Style', 'checkbox',   'Units', 'normalized', 'Position', [0 .5 .5 .25], 'String', 'Fixed', 'Callback', []);
cboxstep   = uicontrol(checkboxs, 'Style', 'checkbox',   'Units', 'normalized', 'Position', [0 .25 1 .25], 'String', 'Stepwise', 'Callback', []);
cboxvbar   = uicontrol(checkboxs, 'Style', 'checkbox',   'Units', 'normalized', 'Position', [0 0 .5 .25], 'String', 'Const v', 'Callback', []);
cboxnone = uicontrol(checkboxs, 'Style', 'checkbox',   'Units', 'normalized', 'Position', [.5 .5 .5 .25], 'String', 'No Torque', 'Callback', []);
cboxdesi = uicontrol(checkboxs, 'Style', 'checkbox',   'Units', 'normalized', 'Position', [.5 .25 .5 .25], 'String', 'Designed', 'Callback', []);
cboxstepv = uicontrol(checkboxs, 'Style', 'checkbox',   'Units', 'normalized', 'Position', [.5 .0 .5 .25], 'String', 'StepV', 'Callback', []);

lfftypes = [];

%Load first file
loadFile_callback

fig.Visible = 'on';

%%%%Callbacks
    function loadFile_callback(~,~, f, p)
        if nargin < 4
            %Prompt the user to select a file
            [f, p] = uigetfile([path filesep '*.mat'], 'MultiSelect','off','Pick an ElRo Trace');
            if ~p %No file selected, do nothing
                return
            end
            file = f;
            path = p;
            save('GUIsettings.mat', 'path', '-append')
            %Format the slider
            d = dir([path filesep '*.mat']);
            d = {d.name};
            len = length(d);
            %Sort filenames
            d = sort(d);
            fileSlider.Min = 1;
            fileSlider.Max = len;
            fileSlider.String = d;
            fileSlider.Enable = 'on';
            if len ==1
                fileSlider.Enable = 'off';
            else
                fileSlider.SliderStep = [1 10] ./ (len-1);
            end
            lfftypes = cell(1,len);
        else
            file = f;
            path = p;
        end
        %Load the file
        load([path file],'eldata');
        name = file(1:end-4);
        cla(mainAxis)
        fig.Name = sprintf('ElRoGUI %s', name);
        %Change fields to mimic Phage, for plotting ( can use same code )
        eldata.time = {eldata.time};
        eldata.contour = {eldata.rotlong};
        eldata.force = {eldata.rot};
        eldata.inf = eldata.inf;
        eldata.comment = eldata.inf.Parameters;
        %Load comment
        if isfield(eldata,'comment')
            trcNotes.String = eldata.comment;
        else
            trcNotes.String = '';
        end
        
        fileSlider.Value = find(cellfun(@(x) strcmp(x, file),fileSlider.String),1); %This line... isn't necessary
        lfftypes{fileSlider.Value} = eldata.inf.Mode;
        if nargin == 4
            %Get old slider number by referencing the text value
            ofsv = textscan(txtSlider.String(2,:),'%d/%d');
            ofsv = ofsv{1};
        end
        txtSlider.String = sprintf('%s\n%d/%d', name, round(fileSlider.Value), fileSlider.Max);
        loadCrop.String = 'Load Crop';
        
        %Check for datatype settings
        fsv = logical([cboxfix.Value, cboxstep.Value, cboxvbar.Value, cboxnone.Value cboxdesi.Value cboxstepv.Value]);
        %Ignore if all is selected. Treat none as all, too
        if nargin == 4 && ~cboxall.Value && ~all(fsv) && ~all(~fsv)
            %Find actual next data
            arrdir = sign(fileSlider.Value - ofsv);
            if arrdir ~= 0
                ended = 0;
                if arrdir > 0
                    irng = fileSlider.Value:arrdir:fileSlider.Max;
                else
                    irng = fileSlider.Value:arrdir:fileSlider.Min;
                end
                for i = irng
                    %check if we've already loaded the next before, else load and get its Mode
                    if isempty(lfftypes{i})
                        a=load([path fileSlider.String{i}]);
                        lfftypes{i} = a.eldata.inf.Mode;
                    end
                    modvec = strcmp(lfftypes{i}, {'Fixed', 'Stepwise', 'Constant Speed', '-', 'Designed' 'Step V'});
                    if any(fsv .* modvec)
                        loadFile_callback([], [], fileSlider.String{i}, path);
                        return
                    end
                end
            end
        end
        %Plot centroid image
        %plot 99th - 1st percentile, to remove outliers
        xx = eldata.x;
        yy = eldata.y;
        trimpct = .5;
        cla(subRAxis)
        xl = prctile(xx, [0 100] + [1 -1] * trimpct);
        yl = prctile(yy, [0 100] + [1 -1] * trimpct);
        ki = xx > xl(1) & xx < xl(2) & yy > yl(1) & yy < yl(2);
        [hc, hx, hy] = histcounts2(xx(ki), yy(ki), 50);
        hx = hx(1:end-1) + median(diff(hx))/2;
        hy = hy(1:end-1) + median(diff(hy))/2;
%         hc = log(hc+1);
% srf = surface(subRAxis, hx, hy, hc');
        srf = pcolor(subRAxis, hx, hy, hc');
        %Label centroid, plotted by same method. Here it's just the center of the screen.
        hold(subRAxis, 'on')
        plot(subRAxis, mean(xl), mean(yl), '+', 'Color', [1 1 1], 'MarkerSize', 4)
        srf.EdgeColor = 'none';
        srf.FaceColor = 'interp';
        xlim(subRAxis, xl)
        ylim(subRAxis, yl)
        axis(subRAxis, 'ij')
        axis(subRAxis, 'square')
        box(subRAxis, 'off')
        subRAxis.YDir = 'normal';
        subRAxis.XColor = [1 1 1];
        subRAxis.YColor = [1 1 1];
        subRAxis.XTickLabel = [];
        subRAxis.YTickLabel = [];
        %Normalize the color a bit
        cmax = max(1,prctile(hc(:), 95));
        subRAxis.CLim = [0 cmax];
        
        %Button labels, because these change
        plotOff.String = 'Calc Cal/Prot';
        
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
            conF = cellfun(@(x)windowFilter(@mean, x, fil, dec),eldata.contour,'UniformOutput',0);
            timF = cellfun(@(x)windowFilter(@mean, x, fil, dec),eldata.time,'UniformOutput',0);
            forF = cellfun(@(x)windowFilter(@mean, x, fil, dec),eldata.force,'UniformOutput',0);
        else
            conF = eldata.contour;
            timF = eldata.time;
            forF = eldata.force;
        end
        
        %Plot force on bottom. Don't use cla to keep current window.
        arrayfun(@delete,subAxis.Children)
        cellfun(@(x,y)plot(subAxis, x, y, 'Color', .7 * [1 1 1]), eldata.time, eldata.force)
        plotCell(subAxis, timF, forF)
        
        %Plot contour on top
        arrayfun(@delete,mainAxis.Children)
        %Hijacked for Moffit POV (1.25kHz raw data)
%         fulconF = cellfun(@(x)windowFilter(@mean, x, [], 2),stepdata.contour,'UniformOutput',0);
%         fulti mF = cellfun(@(x)windowFilter(@mean, x, [], 2),stepdata.time,'UniformOutput',0);
%         cellfun(@(x,y)plot(mainAxis, x, y, 'Color', [.7 .7 .7]), fultimF, fulconF, 'UniformOutput', false);
        %/Hijack
        cellfun(@(x,y)plot(mainAxis, x, y, 'Color', .7 * [1 1 1]), eldata.time, eldata.contour, 'UniformOutput', false);
        filtLine = plotCell(mainAxis, timF, conF);
        
        %Plot protocol
        switch eldata.inf.Mode
            case 'Stepwise'
                params = procparams(eldata.inf.Mode, eldata.inf.Parameters);
                stmax = ceil(eldata.time{end}(end)/params.tdwell);
                lx = [(0:stmax); (0:stmax)];
                lx = lx(2:end-1) * params.tdwell;
                ly = [(0:stmax-1); (0:stmax-1)] * params.stepsz / 360 * (2*strcmp('Hydrolysis', params.dir) -1);
                ly = ly(:);
                line(mainAxis, lx,ly)
                line(mainAxis, lx,ly+.5)
                line(mainAxis, lx,ly-.5)
                line(mainAxis, lx,ly-1)
                line(mainAxis, lx,ly+1)
                line(subAxis, lx,ly)
            case {'Constant Speed', 'Designed'}
                params = procparams(eldata.inf.Mode, eldata.inf.Parameters);
                tmax = eldata.time{end}(end);
                if str2double(eldata.inf.Date) >= 20190829
                    line(mainAxis, [0 tmax], [0 tmax] * params.rspd * (2*strcmp('Hydrolysis', params.dir) -1));
                line(subAxis, [0 tmax], [0 tmax] * params.rspd * (2*strcmp('Hydrolysis', params.dir) -1));
                else
                    line(mainAxis, [0 tmax], [0 tmax] * params.rspd * -(2*strcmp('Hydrolysis', params.dir) -1));
                    line(subAxis, [0 tmax], [0 tmax] * params.rspd * -(2*strcmp('Hydrolysis', params.dir) -1));
                end
            case 'Fixed'
                params = procparams(eldata.inf.Mode, eldata.inf.Parameters);
                tmax = eldata.time{end}(end);
%                 dt = 1/ params.modf / 4;
%                 ts = 0:dt:tmax;
%                 ys = params.pos/360 + params.moda/360 * sin(params.modf * ts * 2 * pi);
%                 plot(mainAxis, ts, ys, 'Color', 'b')
%                 plot(subAxis, ts, ys, 'Color', 'b')
                line(mainAxis, [0 tmax], (1-params.pos/360) * [1 1]);
                line(subAxis, [0 tmax], (1-params.pos/360) * [1 1]);
                line(mainAxis, [0 tmax], (1-params.pos/360)+.5 * [1 1]);
                line(subAxis, [0 tmax], (1-params.pos/360)+.5 * [1 1]);
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
        subRAxisB.Position = subRAxisB.Position + [1 0 0 0];
        subRAxisT.Position = subRAxisT.Position + [1 0 0 0];
        subRAxis.Position = mod(subRAxis.Position,1);
        %gather contour together, apply crop to con if exists
        if radioKDF2.Value || radioKDF3.Value
            cons = [conF{:}];
            tims = [timF{:}];
            if isempty(cons)
                return
            end
            loadCrop_callback
            if ~isempty(cropT)
                cons = cons(tims > cropT(1) & tims < cropT(2));
            end
            hbinsz = 0.005;
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
                subRAxisB.Position = mod(subRAxisB.Position,1);
                subRAxisT.Position = mod(subRAxisT.Position,1);
                subRAxis.Position = subRAxis.Position + [1 0 0 0];
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
                if isempty(pkheis)
                    return
                end
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
                binsz = .1;
%                 xs = (-1:ceil(20/binsz)+1) * binsz;
                xs = -.01:0.01:1;
                xs = xs - binsz/2; %shift by binsz/2 bc step sizes might differ by eps
                cts = histcounts(pkdsts, xs);
                %plot on both subR axes
                xp = xs(1:end-1)+ binsz/2;
                ctss = smooth(cts, 5)';
                bar(subRAxisT, xp, ctss, 'EdgeColor', 'none')
                axis(subRAxisT, 'tight')
                bar(subRAxisB, xp, ctss, 'EdgeColor', 'none')
                axis(subRAxisB, 'tight')
                %on top, plot 0-5
                xlim(subRAxisT, [0 2/3])
                %on bottom, 0-20
                xlim(subRAxisB, [0 2])
                
                %Fit gaussian
                %                 gauss = @(x0, x) exp( -(x-x0(1)).^2 / 2 / x0(2) ) * x0(3);
                %                 lsqopts = optimoptions('lsqcurvefit');
                %                 lsqopts.Display = 'none';
                %                 lb = [0 0 0];
                %                 ub = [20 20 length(cts)];
                %                 fit = lsqcurvefit(gauss, [10 2 max(cts)], xp, cts, lb, ub, lsqopts);
                
                [fit, gauss] = fitgauss_iter2(xp(2:end-1), ctss(2:end-1), [-2 .5], 2);
                cellfun(@(x)plot(subRAxisT, xp, gauss(x, xp)), fit);
                cellfun(@(x)plot(subRAxisB, xp, gauss(x, xp)), fit);
                %display fit stats as text.
                fitm = reshape([fit{:}], 3, [])';
                cellfun(@(x) text(subRAxisB, x(1), 1.1*gauss(x, x(1)), sprintf('%0.2f+-%0.2f', x(1), x(2)), 'HorizontalAlignment', 'left'), fit)
                cellfun(@(x) text(subRAxisT, x(1), 1.1*gauss(x, x(1)), sprintf('%0.2f+-%0.2f', x(1), x(2)), 'HorizontalAlignment', 'left'), fit)
                %                     text(subRAxisB, 20, mean(get(subRAxisB, 'ylim')), sprintf('gauss can''t be fit \n(probably too few N)'), 'HorizontalAlignment', 'right')
            end
            mainRAxis.XTickLabel = [];
        end
    end

    function toWorksp_callback(~,~)
        assignin('base','guiCf',conF);
        assignin('base','guiTf',timF);
        tmp = eldata;
        tmp.time = tmp.time{1};
        assignin('base','guieldata',tmp);
    end

    function clrGraph_callback(~,~)
        %Delete all lines, text objects
        len = length(mainAxis.Children);
        %Is it faster to grab all of mainAxis.Children and index the reference? [doesn't matter anyway]
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
            cropT = [];
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
        
        ln1 = line([1 1]*x(1), [0 1e4]);
        ln2 = line([1 1]*x(2), [0 1e4]);
        drawnow
        switch questdlg('Remove this section?','Trim?','Yes','No', 'No');
            case 'Yes'
                %Undo cell-ifying, field-ifying
                eldata.time = eldata.time{1};
                eldata = rmfield(eldata, {'contour', 'comment', 'force'});
                
                %Find index of first greater than start, last less than end
                st = find(eldata.time > x(1),1);
                en = find(eldata.time < x(2),1, 'last');
                %Act on every field that is of right length
                fnames = fieldnames(eldata);
                origlen = length(eldata.x);
                for j = 1:length(fnames)
                    if length(eldata.(fnames{j})) == origlen
                        eldata.(fnames{j})(st:en) = [];
                    end
                end
                save([path file], 'eldata')
                loadFile_callback([], [], file, path)
            case 'No'
                delete(ln1)
                delete(ln2)
        end
    end

    function fixLimit_callback(~,~)
        zoom(mainAxis, 'out')
        zoom(subAxis, 'out')
        axis(mainAxis, 'tight')
        axis(subAxis, 'tight')
        zoom(mainAxis, 'reset')
        zoom(subAxis, 'reset')
    end

    function locNoise_callback(~,~)
        %Plot the local noise levels every so-and-so points
        noiwin = 1e4;
        szs = cellfun(@length, eldata.time);
        szs = floor(szs/noiwin);
        for i = 1:length(eldata.time)
%             cfil = stepdata.contour{i} - smooth(stepdata.contour{i},125)';
            for j = 1:szs(i)
                %Estimate noise, annotate with text
                ran = (j-1)*noiwin+1:j*noiwin;
                textt = double(mean(eldata.time{i}(ran([1 end]))));
                textc = double(mean(eldata.contour{i}(ran)));
%                 textv = std(cfil(ran));
                textv = sqrt(estimateNoise(eldata.contour{i}(ran), [], 1))*100;
                if j == 1
                    pfit = @(x)polyfit(1:length(x), x, 1);
                    textvel = pfit(eldata.contour{i});
                    textvel = -textvel(1) * 4000;
                    text(mainAxis, textt, textc+1/3, sprintf('%0.2fc, %0.1fv',textv, textvel), 'Rotation', 90, 'Clipping', 'on')
                else
                    text(mainAxis, textt, textc+1/3, sprintf('%0.2fc',textv), 'Rotation', 90, 'Clipping', 'on')
                end
            end
        end
    end

    function plotCal_callback(~,~)
        thbin = 4; %thbin must divide 120
        [p, x] = angularhist(eldata.x, eldata.y, thbin);
        figure('Name' , sprintf('AngularHist %s', name))
        plot(x/pi*180,p/max(p))
        hold on
        %Negate to account for sign differences in RotTra and angularhist (arctan)
        p2 = histcounts(mod(-eldata.contour{1},1), [0 (x+thbin/2/180*pi)/2/pi]);
        plot(x/pi*180,p2/max(p2))
        axis(gca, 'tight')
        %Find most probable 3-fold rotation axis
        p2sm = circsmooth(p2, 5);
        p2sm = sum(reshape(p2sm, [], 3), 2);
        [~, maxi] = max(p2sm);
        yl = ylim;
        xs = x(maxi);
        xs = xs/pi*180 + [0 120 240];
        arrayfun(@(x)line( x * [1 1], yl, 'Color', [0.8500 0.3250 0.0980] ), xs); %Second color of @lines
    end

    function plotOff_callback(~,~)
        switch eldata.inf.Mode
            case 'Stepwise'
                ed = eldata;
                ed.time= ed.time{1};
                loadCrop_callback
                if ~isempty(cropT)
                    opts.cropt = cropT;
                    getProtocol(ed,opts);
                else
                    getProtocol(ed);
                end
            case 'Fixed'
                ed = eldata;
                ed.time= ed.time{1};
                opts = [];
                if ~isempty(cropT)
                    opts.ttrim = cropT;
                end
                CalElro(ed, opts);
            case {'Constant Speed' 'Designed'}
                ed = eldata;
                ed.time = ed.time{1};
                opts.path = path;
                CalcWork(ed, [], opts)
            case 'Step V'
                ed = eldata;
                ed.time = ed.time{1};
                opts = [];
                if ~isempty(cropT)
                    opts.ttrim = cropT;
                end
                CalTilt(ed, opts)
            otherwise
                plotOff.String = 'Wrong Mode';
        end
    end

    function plotRaw_callback(~,~)
        tmp = eldata.contour;
        tmp2 = eldata.rot;
        eldata.rot = eldata.rotlong;
        eldata.rotlong = tmp2;
        eldata.contour = eldata.force;
        eldata.force = tmp;
        refilter_callback
    end

    function plotForce_callback(~,~)
        eld = eldata;
        eld.time = eld.time{1};
        
        
        
        
    end
    function custom01_callback(~,~)
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
%         %Moffit: 1bp for 0.064s; Group Meeting: 15bp per .200s = .013
%         xr = yr * .03 * axdim(1)/axdim(2);
%         mainAxis.XLim = xl(1) + [0 xr];
%         cellfun(@(x)set(x,'LineWidth',1.5), filtLine)
        
        
        xl = mainAxis.XLim;
        yl = mainAxis.YLim;
        args = str2num(customB1t.String); %#ok<ST2NM>
        ssz = args(1);
        soff = args(2);
        liney = (soff:ssz:2e4)-1e4;
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
        concrop = cellfun(@(x,y)cropfcn(x,y,a), eldata.contour, eldata.time, 'uni', 0);
%         concrop = [concrop{:}];
        concrop = concrop(~cellfun(@isempty, concrop));
        
        fils  = [3 5 10 25];
        binsz = .01;
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
                xlim(newax, [0 3]);
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

    end

    function printFig_callback(~,~)
        print(fig, sprintf('.\\PhagePrtSc%s', datestr(now, 'yymmddHHMMSS')),'-dpng',sprintf('-r%d',96))
    end

%%%%Helpers
    function varargout = plotCell(ax, x, y)
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