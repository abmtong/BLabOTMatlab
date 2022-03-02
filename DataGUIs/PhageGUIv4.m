function PhageGUIv4()
%% PhageGUI: Interface for viewing optical tweezers .mat files
%Expects a file with name phage*.mat that contains a struct, with fields time, contour, force, all of which are cell arrays
%Can work with most other subgroups' mat files -- detects their format and re-wraps them into Phage-like [see @renametophage]
%Last annotated 191127

%% Add paths, by running startup.m
thispath = fileparts(mfilename('fullpath'));
run( fullfile( thispath, '..', 'startup.m') )

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

%% Declare variables
stepdata = []; %The name of the struct is stepdata
cropLines = cell(1,4); %The crop lines (t_start and t_end for time and force axis)
kvlines = {}; %Kalafut-Visscher fit lines
filtLine = []; %Filtered plot of the data
cropT = []; %Crop time indicies
conF = []; %Vector of the filtered contour
timF = []; %Vector of the filtered time
forF = []; %Vector of the filtered force
fil = []; %Filter width (see @windowFilter)
dec = []; %Decimation amount (see @windowFilter)
stripes = []; %Dotted lines, for showing stripes on the axis
fnfil = '*.mat'; %filename filter, was phage*.mat
ezAnOpts = []; % To hold EasyAnalyze options through runnings
fSamp = []; % 

%% In-file options: I don't think these should need to be changed, but if they need to be ...
fplotmin = 1; %Minimum force to consider when setting y-limits. Useful to remove contour divergences due to zero force [broken tether]

%% Construct figure and axes
%Create a figure with size 3/4ths the screensize, centered. Invisible, for now, to not update as we add ui elements
scrsz = get(0, 'ScreenSize');
fig = figure('Name', 'PhageGUIcrop', 'Position', [scrsz(3:4)/8 .75*scrsz(3:4)], 'Visible', 'off');

%Use panels to help organization. This is the main panel, which holds the axes.
panaxs = uipanel('Position', [.1 0 .9 .95]); %'panel for axes'
panaxs.BackgroundColor = [1 1 1];
mainAxis = axes(panaxs, 'Position', [.05 .31 .78 .68]); %Holds the main distance-time plot
mainRAxis= axes(panaxs, 'Position', [.85 .31 .14 .68]); %'main right axis': Holds the kernel density plot
subAxis  = axes(panaxs, 'Position', [.05 .05 .78 .2]);
subRAxisB= axes(panaxs, 'Position', [.85, .05, .14, .1]);
subRAxisT= axes(panaxs, 'Position', [.85, .15, .14, .1]);
%Hold all of the axes
hold(mainAxis,'on')
hold(mainRAxis,'on')
hold(subAxis, 'on')
hold(subRAxisT, 'on')
hold(subRAxisB, 'on')
%Link axes so they scroll together
linkaxes([mainAxis, subAxis], 'x')
linkaxes([mainAxis, mainRAxis], 'y')

%This panel contains the top row of buttons, which are used for functions
pantop = uipanel('Position', [0 .95 1 .05]); %'panel on top'
loadFile = uicontrol(pantop,                  'Units', 'normalized', 'Position', [ 0, 0, .1, 1],       'String', 'Load File', 'Callback',@loadFile_callback);
loadCropB= uicontrol(pantop,                  'Units', 'normalized', 'Position', [.1, 0, .075, 1],       'String', 'Load Crop', 'Callback',@loadCrop_callback);
permCrop = uicontrol(pantop,                  'Units', 'normalized', 'Position', [.175, 0, .075, 1],     'String', 'Crop', 'Callback',@permCrop_callback);
permCropT= uicontrol(pantop,                  'Units', 'normalized', 'Position', [.25, .5, .025, .5], 'String', 'CropID', 'Callback',@getCropNs_callback);
permCropB= uicontrol(pantop, 'Style', 'edit', 'Units', 'normalized', 'Position', [.25, 0, .025, .5],  'String', '', 'Callback',@loadCrop_callback);
measLine = uicontrol(pantop,                  'Units', 'normalized', 'Position', [.275, 0, .075, 1],       'String', 'Measure', 'Callback',@measLine_callback);
trimTrace= uicontrol(pantop,                  'Units', 'normalized', 'Position', [.35, 0, .075, 1],       'String', 'Trim', 'Callback',@trimTrace_callback);
toWorksp = uicontrol(pantop,                  'Units', 'normalized', 'Position', [.425, 0, .05, 1],      'String', 'ToWkspace' , 'Callback',@toWorksp_callback);
locNoise = uicontrol(pantop,                  'Units', 'normalized', 'Position', [.475, 0, .05, 1],     'String', 'LocNoise' , 'Callback',@locNoise_callback);
ezAnalyze= uicontrol(pantop,                  'Units', 'normalized', 'Position', [.525, 0, .075, 1],     'String', 'Easy Analyze' , 'Callback',@ezAnalyze_callback);
customB1 = uicontrol(pantop,                  'Units', 'normalized', 'Position', [.60, 0.5, .05, .5],  'String', 'Aspect Ratio', 'Callback', @custom01_callback);
customB1t= uicontrol(pantop, 'Style', 'edit', 'Units', 'normalized', 'Position', [.60, 0, .05, .5],    'String', '[2.5, 0]', 'Callback', []);
customB2 = uicontrol(pantop,                  'Units', 'normalized', 'Position', [.65, .5, .05, .5],   'String', 'Custom02', 'Callback',@custom02_callback);
customB3 = uicontrol(pantop,                  'Units', 'normalized', 'Position', [.65, 0 , .05, .5],   'String', 'ScaleFCs', 'Callback',@custom03_callback);
trcNotes = uicontrol(pantop, 'Style', 'text', 'Units', 'normalized', 'Position', [.7, 0, .2, 1],       'String', 'Comment');
printFig = uicontrol(pantop,                  'Units', 'normalized', 'Position', [.9, 0, .05, 1],       'String', 'Print' , 'Callback',@printFig_callback);
helpText = uicontrol(pantop,                  'Units', 'normalized', 'Position', [.95, 0, .05, 1],       'String', 'Help' , 'Callback',@helpText_callback);

%This panel contains the left bar of text inputs, used for filtering and kernel density
panlef = uipanel('Position',[0 0 .1 .95]); %'panel on left'
panlef.BackgroundColor = [1 1 1]; %make it white
fileSlider= uicontrol(panlef, 'Style', 'slider', 'Units', 'normalized', 'Position', [0 .90 1 .1],      'Callback', @fileSlider_callback);
txtSlider = uicontrol(panlef, 'Style', 'text',   'Units', 'normalized', 'Position', [.15 .901 .7 .07], 'String', '1');
clrGraph  = uicontrol(panlef,                    'Units', 'normalized', 'Position', [0 .875 1 .025],   'String', 'Clear Graph', 'Callback', @clrGraph_callback);
%This subpanel has the filtering text boxes
panFil = uipanel(panlef, 'Position', [0 .8 1 .075]);
filtFactT = uicontrol(panFil, 'Style', 'text', 'Units', 'normalized', 'Position', [0 .67 .5 .33],  'String', 'Filt Fact');
filtFact  = uicontrol(panFil, 'Style', 'edit', 'Units', 'normalized', 'Position', [0 .0 .5 .67],   'String', '[]', 'Callback', @refilter_callback);
deciFactT = uicontrol(panFil, 'Style', 'text', 'Units', 'normalized', 'Position', [.5 .67 .5 .33], 'String', 'Dec Fact');
deciFact  = uicontrol(panFil, 'Style', 'edit', 'Units', 'normalized', 'Position', [.5 .0 .5 .67],  'String', '20', 'Callback', @refilter_callback);
%This subpanel has the contour limit text boxes
panConMx= uipanel(panlef, 'Position', [0 .725 1 .075]);
conMinT = uicontrol(panConMx, 'Style', 'text', 'Units', 'normalized', 'Position', [0 .67 .5 .33],  'String', 'Y Min');
conMin  = uicontrol(panConMx, 'Style', 'edit', 'Units', 'normalized', 'Position', [0 .0 .5 .67],   'String', '0', 'Callback', @fixLimit_callback);
conMaxT = uicontrol(panConMx, 'Style', 'text', 'Units', 'normalized', 'Position', [.5 .67 .5 .33], 'String', 'Y Max');
conMax  = uicontrol(panConMx, 'Style', 'edit', 'Units', 'normalized', 'Position', [.5 .0 .5 .67],  'String', '4000', 'Callback', @fixLimit_callback);
%This subpanel has buttons, 
panPlotX = uipanel(panlef, 'Position', [0 .65 1 .075]);
plotCal   = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [0  .5 .5 .5], 'String', 'Plot Cal', 'Callback', @plotCal_callback);
plotOff   = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [.5 .5 .5 .5], 'String', 'Plot Off', 'Callback', @plotOff_callback);
plotRaw   = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [0  0  .5 .5], 'String', 'Plot Raw', 'Callback', @plotRaw_callback);
plotMet   = uicontrol(panPlotX, 'Units', 'normalized', 'Position', [.5 0  .5 .5], 'String', 'Plot Meta', 'Callback', @plotMet_callback);
%This panel has the KDF (kernel density function) calculation options
radioKDF  = uibuttongroup(panlef,                       'Units', 'normalized', 'Position', [0 .55 1 .1 ], 'SelectionChangedFcn', @kdf_callback);
radioKDF1 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [0 .66 5 .34], 'String', 'No KDF', 'Callback', []);
radioKDF2 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [0 .33 1 .33], 'String', 'KDF Quick', 'Callback', []);
radioKDF3 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [0 .0  1 .33], 'String', 'KDF Full', 'Callback', []);
radioKDF4 = uicontrol(radioKDF, 'Style', 'radiobutton', 'Units', 'normalized', 'Position', [.5 .66  .5 .34], 'String', 'K-V', 'Callback', []);
radioKDF2t= uicontrol(radioKDF, 'Style', 'edit',        'Units', 'normalized', 'Position', [.7 .33 .3 .33], 'String', '20', 'Callback', @kdf_callback);
radioKDF3t= uicontrol(radioKDF, 'Style', 'edit',        'Units', 'normalized', 'Position', [.7 0   .3 .33], 'String', '1', 'Callback', @kdf_callback);
radioKDF2.Value = true; %Default to KDF Quick

%Load first file
loadFile_callback

%Now that we've made the figure and loaded the data, draw the figure
if strcmp(file, 'phageMMDDYYN00.mat') %If loadFile was canceled, just exit
    close(fig)
    return
end
fig.Visible = 'on';

%% Main Callbacks
    function loadFile_callback(~,~, f, p)
        %Load a data file
        if nargin < 4 %If nargin < 4, this was called by clicking a button or on startup
            %Prompt the user to select a file
            [f, p] = uigetfile([path filesep fnfil], 'MultiSelect','off','Pick a Trace');
            if ~p %No file selected, do nothing
                return
            end
            %Assign the file/path to static variables
            file = f;
            path = p;
            %Save path so next time we start, we remember that folder
            save('GUIsettings.mat', 'path', '-append')
            %Format the slider: Find other files in this folder and sort them
            d = dir([path filesep fnfil]);
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
                fileSlider.SliderStep = [1 10] ./ (len-1); %Step by one file on small step, 10 files on large step
            end
        else %If nargin == 4, this was called by the file slider, so assign the passed f and p
            file = f;
            path = p;
        end
        %Load the file
        tmp = load([path file]);
        %Get the structure's name
        sn = fieldnames(tmp); %'struct name'
        if length(sn) > 1
            warning('File %s has more than one variable in it, loading the first one alphabetically', f)
            return
        end
        sn = sn{1};
        tmp = tmp.(sn);
        %Check that the loaded file is indeed a struct
        if ~isstruct(tmp)
            warning('Loaded file %s is not a valid data file', f)
            return
        end
        %Check if it's regular phage data or something else
        if strcmp(sn, 'stepdata')
            stepdata = tmp;
            %Going to stop removing the preceding phage*, and handle it in loadCrop
%             if length(file) > 5 && strcmpi(file(1:5), 'phage')
%                 name = file(6:end-4); %Strip leading 'phage' and trailing '.mat'
%             else
%                 
%             end
            name = file(1:end-4); %Just strip trailing '.mat'
        else
            %If it's something else, convert to phage-like
            stepdata = renametophage(tmp, sn);
            name = file(1:end-4); %Strip trailing '.mat'
        end
        %Clear main axis
        cla(mainAxis)
        %Name the figure to reflect the current file
        fig.Name = sprintf('PhageGUIcrop %s', name);
        %Load comment, if it exists
        if isfield(stepdata,'comment')
            trcNotes.String = stepdata.comment;
        else
            trcNotes.String = '';
        end
        %Set the slider to the correct value, update the accompanying text
        fSamp = 1/mean(cellfun(@(x) mean(diff(x)), stepdata.time));
        fileSlider.Value = find(cellfun(@(x) strcmp(x, file),fileSlider.String),1);
        txtSlider.String = sprintf('%s\n%d/%d\n%0.2fHz', name, round(fileSlider.Value), fileSlider.Max, fSamp);
        %Reset the crop buttons
        loadCropB.String = 'Load Crop';
        cropT = [];
        
        zoom on
        %Plot
        refilter_callback
        fixLimit_callback
        %Load crop
        loadCrop_callback
    end

    function loadCrop_callback(~,~)
        %Load a crop
        cropT = loadCrop(permCropB.String, path, file);
        if isempty(cropT)
            loadCropB.String = 'Crop not found';
            return
        else
            loadCropB.String = 'Load Crop';
        end
        %Delete old crop lines
        if ~isempty(cropLines{1,1})
            cellfun(@delete, cropLines(1,:))
        end
        %Draw lines at the start/end crop bdys
        mainYLim = mainAxis.YLim;
        subYLim = subAxis.YLim;
        cropLines{1,1} = line(mainAxis,cropT(1) * [1 1], mainYLim, 'Color', 'r');
        cropLines{1,2} = line(mainAxis,cropT(2) * [1 1], mainYLim, 'Color', 'r');
        cropLines{1,3} = line(subAxis ,cropT(1) * [1 1], subYLim, 'Color', 'r');
        cropLines{1,4} = line(subAxis ,cropT(2) * [1 1], subYLim, 'Color', 'r');
        %Zoom out if the crop is outside the current x limit
        if mainAxis.XLim(1) > cropT(1)
            mainAxis.XLim = [cropT(1)-.5 mainAxis.XLim(2)];
        end
        if mainAxis.XLim(2) < cropT(2)
            mainAxis.XLim = [mainAxis.XLim(1) cropT(2)+0.5];
        end
    end

    function fileSlider_callback(~,~)
        %If the slider is moved, load the corresponding file
        file = fileSlider.String{round(fileSlider.Value)};
        loadFile_callback([], [], file, path)
    end

    function refilter_callback(~,~)
        %Filter the data
        %Get the filtering parameters (width and decimation)
        fil = str2num(filtFact.String); %#ok<ST2NM>, we need to have '[]' be interpretable as [], not NaN
        dec = str2double(deciFact.String);
        %And filter
        conF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.contour,'UniformOutput',0);
        timF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.time,'UniformOutput',0);
        forF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.force,'UniformOutput',0);
        %Plot contour on top, first unfiltered in grey then filtered in color
        arrayfun(@delete,mainAxis.Children) %Don't use cla to keep current zoom
        cellfun(@(x,y)plot(mainAxis, x, y, 'Color', .7 * [1 1 1]), stepdata.time, stepdata.contour);
        filtLine = plotCell(mainAxis, timF, conF);
        %Plot force on bottom
        arrayfun(@delete,subAxis.Children)
        cellfun(@(x,y)plot(subAxis, x, y, 'Color', .7 * [1 1 1]), stepdata.time, stepdata.force)
        plotCell(subAxis, timF, forF)
        %Semi-passive feedback has sections cut out where the trap is moving.
        % if these are saved, plot them: unfiltered in grey, filtered in dark grey
        if isfield(stepdata, 'cut')
            cconF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.cut.contour,'UniformOutput',0);
            ctimF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.cut.time,'UniformOutput',0);
            cforF = cellfun(@(x)windowFilter(@mean, x, fil, dec),stepdata.cut.force,'UniformOutput',0);
            cellfun(@(x,y)plot(mainAxis,x,y,'Color',[.7 .7 .7]), stepdata.cut.time, stepdata.cut.contour)
            cellfun(@(x,y)plot(subAxis,x,y,'Color',[.7 .7 .7]), stepdata.cut.time, stepdata.cut.force)
            cellfun(@(x,y)plot(mainAxis,x,y,'Color',[.2 .2 .2]), ctimF, cconF)
            cellfun(@(x,y)plot(subAxis,x,y,'Color',[.2 .2 .2]), ctimF, cforF)
        end
        %Calculate and list the local noise at each section
        locNoise_callback
        %Calculate the kernel density function of the filtered data
        kdf_callback
    end

    function kdf_callback(src,~)
        %Calculate the kernel density function (akin to a residence time histogram) of the curve
        % oops also K-V stepfinding is handled here
        %Don't recalc if we change a KDF option but that method isn't selected
        if nargin > 1 && isequal(src, radioKDF2t) && ~radioKDF2.Value
            return
        end
        if nargin > 1 && isequal(src, radioKDF3t) && ~radioKDF3.Value
            return
        end
        %Clear the kdf, histogram axes
        cla(mainRAxis)
        cla(subRAxisT)
        cla(subRAxisB)
        %If the option is KDF, calculate the KDF
        if radioKDF2.Value || radioKDF3.Value
            %Gather [filtered] contour together, apply crop to if it exists
            cons = [conF{:}];
            tims = [timF{:}];
            frcs = [forF{:}];
            loadCrop_callback
            if ~isempty(cropT)
                cons = cons(tims > cropT(1) & tims < cropT(2) );
            end
            %Trim to plot limits
            cons = cons( cons > str2double(conMin.String) & cons < str2double(conMax.String) );
            %Set the y bin size; this works well in all(?) cases
            hbinsz = 0.1;
            if radioKDF2.Value
                %Calc kdf by nhistc (histogram)
                [histy, histxx] = nhistc(cons, hbinsz);
                %Smooth by the user-input parameter
                histy = smooth(histy, str2double(radioKDF2t.String));
                plot(mainRAxis, histy, histxx, 'Color', 'b');
            elseif radioKDF3.Value
                %Calc kdf using @kdf (actual kernel density, i.e. place a gaussian with width [input parameter] at each point
                [histy, histxx] = kdf(cons, hbinsz, str2double(radioKDF3t.String));
                plot(mainRAxis, histy, histxx, 'Color', 'b');
                %We can do some stepfinding, since kdf is smooth, we can get peak heights
                % Can't use @kdfsfind because we need the peak heights, too, for plotting purposes
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
                if pkdsts %If there's only one peak, theres no pkdsts
                    arrayfun(@(x,y,z)text(mainRAxis,y,x,sprintf('%0.2f',z), 'Clipping', 'on'), pkcen, pkheis, pkdsts)
                end
                %plot lines from 0 to peak
                lx = [pkloc; pkloc; pkloc];
                lx = lx(:);
                ly = [zeros(size(pkhei)); pkhei; zeros(size(pkhei))];
                ly = ly(:);
                line(mainRAxis, ly, lx);
                %Calculate step size histogram. Hard code for Phage numbers
                binsz = .1;
                %Bin from 0 to 20
                xs = -100*binsz:binsz:101+binsz;
                xs = xs - binsz/2; %shift by binsz/2 bc step sizes will be even multiples of binsz, and thus may differ by eps
                cts = histcounts(pkdsts, xs);
                %Plot on subR axes
                xp = xs(1:end-1)+ binsz/2;
                %Plot bar as 
                bar(subRAxisT, xp, cts, 'EdgeColor', 'none')
                axis(subRAxisT, 'tight')
                bar(subRAxisB, xp, cts, 'EdgeColor', 'none')
                axis(subRAxisB, 'tight')
                %On top, show 0-5
                xlim(subRAxisT, [0 5])
                %On bottom, show 0-20
                xlim(subRAxisB, [0 20])
                %Fit gaussian
                gauss = @(x0, x) exp( -(x-x0(1)).^2 / 2 / x0(2) ) * x0(3);
                lsqopts = optimoptions('lsqcurvefit');
                lsqopts.Display = 'none';
                lb = [0 0 0];
                ub = [20 20 length(cts)];
                fit = lsqcurvefit(gauss, [10 2 max(cts)], xp, cts, lb, ub, lsqopts);
                %Plot the gaussian fit
                arrayfun(@(x)plot(x, xp, gauss(fit, xp)), [subRAxisT, subRAxisB]);
                %Display fit stats as text
                text(subRAxisB, fit(1), 1.1*gauss(fit, fit(1)), sprintf('%0.2f+-%0.2f', fit(1), fit(2)), 'HorizontalAlignment', 'left')
                text(subRAxisT, fit(1), 1.1*gauss(fit, fit(1)), sprintf('%0.2f+-%0.2f', fit(1), fit(2)), 'HorizontalAlignment', 'left')
            end
            %Remove x tick of kdf graph
            mainRAxis.XTickLabel = [];
        elseif radioKDF4.Value
            %Do K-V stepfinding
            cellfun(@delete,kvlines)
            %For speed, apply K-V only if cropped - KV takes a long time on long traces
            if isempty(cropT)
                return
            end
            %Apply crop
            cf = cellfun(@(x,y) y(x > cropT(1) & x < cropT(2)), stepdata.time, stepdata.contour, 'Un', 0);
            tf = cellfun(@(x,y) y(x > cropT(1) & x < cropT(2)), stepdata.time, stepdata.time, 'Un', 0);
            %Filter using K-V--specific filter options
            wid = 5;
            pf = single(8);
            cf = cellfun(@(x)windowFilter(@mean, x, [], wid), cf, 'un',0);
            tf = cellfun(@(x)windowFilter(@mean, x, [], wid), tf, 'un',0);
            %Remove empty cells
            cf(cellfun(@isempty,cf)) = [];
            tf(cellfun(@isempty,tf)) = [];
            %Apply K-V stepfinding
            [~, ~, trs, sszs] = BatchKV(cf, pf, 500, 0);
            %Plot in red
            kvlines = cellfun(@(x,y)plotkv(mainAxis, x, y, 'LineWidth', 1, 'Color', 'r'), tf, trs, 'Un',0);
            %Calculate step size histogram
            binsz = .1;
            xs = -1:0.1:21;
            xs = xs - binsz/2; %shift by binsz/2 bc step sizes might differ by eps
            cts = histcounts(sszs, xs);
            %plot on both subR axes
            xp = xs(1:end-1)+ binsz/2;
            bar(subRAxisT, xp, cts, 'EdgeColor', 'none')
            axis(subRAxisT, 'tight')
            bar(subRAxisB, xp, cts, 'EdgeColor', 'none')
            axis(subRAxisB, 'tight')
            %On top, show 0-5
            xlim(subRAxisT, [0 5])
            %On bottom, show 0-20
            xlim(subRAxisB, [0 20])
        end
    end

    function toWorksp_callback(~,~)
        %Copy the currently open file to the workspace, for convenience
        assignin('base','guiCf',conF);
        assignin('base','guiTf',timF);
        assignin('base','guistepdata',stepdata);
        assignin('base','guicropT', cropT);
        if ~isempty(cropT)
            %If crop is valid, add cropped guistepdata
            assignin('base','guisdcrop', cropstepdata(stepdata, cropT))
        end
    end

    function clrGraph_callback(~,~)
        %Delete all lines and text objects in mainAxis and mainRAxis
        chs = [mainAxis.Children; mainRAxis.Children];
        len = length(chs);
        toDel = false(len,1);
        for i = 1:len
            gobj = chs(i);
            if isgraphics(gobj, 'Text')
                toDel(i)=true;
            elseif isgraphics(gobj, 'Line') && length(gobj.XData) == 2;
                %Plots with two points are lines, e.g. made from Measure
                toDel(i)=true;
            end
        end
        arrayfun(@delete, chs(toDel))
    end

    function measLine_callback(~,~)
        %Draw a line between two user-selected points
        [x, y] = ginput(2);
        dx = abs(diff(x));
        dy = abs(diff(y));
        line(x,y)
        %Write the dx, dy, slope of the line
        text(x(end),y(end),sprintf('(dx,dy,m) = (%0.2f, %0.2f, %0.2f)\n',dx,dy,dy/dx), 'Clipping', 'on')
    end

    function permCrop_callback(~,~)
        %Crop by clicking two points. Must be selected left to right; right to left deletes the crop
        cropstr = permCropB.String;
        [x, ~] = ginput(2);
        %If crop is ended by pressing enter, skip cropping
        if length(x) ~= 2
            return
        end
        %Create the filepath to the crop
        cropfp = sprintf(['%s' filesep filesep 'CropFiles%s' filesep filesep '%s.crop'], path, cropstr, name);
        cropp = fileparts(cropfp);
        %Create the folder, if it doesn't exist
        if ~exist(cropp, 'dir')
            mkdir(cropp)
        end
        %If crop is selected right to left, delete it
        if ~issorted(x)
            if exist(cropfp, 'file')
%                 fprintf('Deleted crop%s for %s\n', cropstr, name)
                delete(cropfp)
                cellfun(@delete, cropLines)
                loadCropB.String = 'Crop deleted';
            end
            return
        end
        %Write the crop
        fid = fopen(cropfp, 'w');
        fwrite(fid, sprintf('%f\n%f', x));
        fclose(fid);
        %Load the crop
        loadCrop_callback
    end

    function trimTrace_callback(~,~)
        %Select a section of a trace to physically remove (delete the enclosed points)
        [x,~] = ginput(2);
        x = sort(x);
        %If trim is ended by pressing enter, exit
        if length(x) ~= 2
            return
        end
        %Draw lines denoting area to remove
        yl = ylim;
        ln1 = line([1 1]*x(1), yl);
        ln2 = line([1 1]*x(2), yl);
        drawnow
        %Ask the user to make sure they want to go through with the trim operation
        switch questdlg('Trim here?','Trim?','Yes','No', 'No');
            case 'Yes'
                %Trim
                stepdata = trimstepdata(stepdata, x);
                %Save
                save([path file], 'stepdata')
                %Load
                loadFile_callback([], [], file, path)
            case 'No'
                %Remove the lines
                delete(ln1)
                delete(ln2)
        end
    end

    function fixLimit_callback(~,~)
        %Set the x/y limits to fit the plotted data
        tlim = [stepdata.time{1}(1) stepdata.time{end}(end)];
        flim = [min(cellfun(@min, stepdata.force)), max(cellfun(@max, stepdata.force))];
        %For contour, fit the trace, but only consider where F>1, and stay within the input min/max boxes
        cmin = max(str2double(conMin.String), min(cellfun(@grabmin, stepdata.contour, stepdata.force)));
        cmax = min(str2double(conMax.String), max(cellfun(@grabmax, stepdata.contour, stepdata.force)));
        clim = [cmin cmax];
        if length(clim) ~= 2 || ~issorted(clim)
            clim = [0 6000]; %Fallback if automatic procedure messes up
        end
        %Zoom out, set limits, zoom reset so the figure 'remembers' this zoom on double-click
        zoom(mainAxis, 'out')
        zoom(subAxis, 'out')
        xlim(mainAxis, tlim)
        ylim(mainAxis, clim + [0 1])
        ylim(subAxis, flim)
        zoom(mainAxis, 'reset')
        zoom(subAxis, 'reset')
    end

    function m = grabmin(c, f)
        %Helper for fixLimit, grabs the minimum contour with force at least 1
        m = double(min(c(f>fplotmin)));
        if isempty(m)
            m = 1e4;
        end
    end

    function m = grabmax(c, f)
        %Helper for fixLimit, grabs the maximum contour with force at least 1
        m = double(max(c(f>fplotmin)));
        if isempty(m)
            m = 0;
        end
    end

    function locNoise_callback(~,~)
        %Plot the local noise levels (sd)
        netlen = sum(cellfun(@length, stepdata.time));
        %Plot every noiwin points
        if netlen > 1e5
            %If the length of the trace is too long, plot fewer noise samples
            noiwin = round(netlen/1e2);
        else
            noiwin = 500;
        end
        %Find out how many samples to plot per trace
        szs = cellfun(@length, stepdata.time);
        szs = floor(szs/noiwin); %Only plot if we can get at least noiwin points
        for i = 1:length(stepdata.time)
            for j = 1:szs(i)
                %Find out where to place the text marker
                ran = (j-1)*noiwin+1:j*noiwin;
                textt = double(mean(stepdata.time{i}(ran([1 end]))));
                textc = double(mean(stepdata.contour{i}(ran)));
                %And calculate the velocity
                textv = sqrt(estimateNoise(stepdata.contour{i}(ran), [], 2));
                if j == 1
                    %The first also has velocity information. Don't do this every point, as it takes some time
                    pfit = @(x)polyfit(1:length(x), x(:)', 1);
                    textvel = pfit(stepdata.contour{i});
                    textvel = -textvel(1) * 2500;
                    text(mainAxis, textt, textc+20, sprintf('%0.2f, %0.1fv',textv, textvel), 'Rotation', 90, 'Clipping', 'on')
                else
                    %Plot text that says the noise
                    text(mainAxis, textt, textc+20, sprintf('%0.2f',textv), 'Rotation', 90, 'Clipping', 'on')
                end
            end
        end
    end

    function plotCal_callback(~,~)
        %Plot the calibration fits
        if isfield(stepdata, 'cal')
            plotcal(stepdata.cal);
        end
    end

    function plotOff_callback(~,~)
        %Plot the offset curves, if saved
        if isfield(stepdata, 'off')
            plotoff(stepdata.off);
        end
    end

    function plotRaw_callback(~,~)
        %Plot the raw force, bead extension, and norm volts
        if isfield(stepdata, 'forceAX')
            plotraw(stepdata)
            xlim(mainAxis.XLim)
        end
    end

    function plotMet_callback(~,~)
        %Display things like XWLC params, etc. [things in Opts]
        if isfield(stepdata, 'opts')
            plotmet(stepdata)
        end
    end

    function getCropNs_callback(~,~)
        %Get the cropNs of the current data folder (i.e. shows the cropIDs and the number of crops in each)
        getcropns(path);
    end

    function ezAnalyze_callback(~,~)
        %Add PWD dir
        addpath([thispath '\PairwiseDist']); %PWD code

        %Query for opts
        if isempty(ezAnOpts)
            tmp = easyAnalyzeOpts;
        else
            tmp = easyAnalyzeOpts(ezAnOpts);
        end
        %If empty, opts picker was cancelled
        if isempty(tmp)
            return
        else
            ezAnOpts = tmp;
        end
        
        %Get traces
        switch ezAnOpts.Traces
            case 1 %Single trace, just take current crop
                cropfcn = @(x, y, z) x(y>z(1) & y<z(2));
                dat = cellfun(@(x,y)cropfcn(x,y,cropT), stepdata.contour, stepdata.time, 'uni', 0);
                dat = dat(~cellfun(@isempty, dat));
            case 2 %Multiple: getFCs on this folder w/ current cropstr
                dat = getFCs(permCropB.String, path);
            otherwise
                error('easyAnalyze traces option %d not recognized')
        end
        
        %Add some details of the files. Conflicted where to call getFCs
        ezAnOpts.cropstr = permCropB.String;
        ezAnOpts.path = path;
        
        %Assign data to workspace
        assignin('base', 'guitraces', dat);
        
        %Analyze
        easyAnalyze(dat, ezAnOpts);
    end

    function helpText_callback(~,~)
        pGUI_msgblurb
    end

%% Custom Callbacks
%These are here to do custom, variable things. May be moved to a more permanent button.
    function custom01_callback(~,~)
        %Draw lines parallel to the X axis
        customB1.String = 'AspectRatio';
        xl = mainAxis.XLim;
        yl = mainAxis.YLim;
        yr = diff(yl);
        %Get actual axes size from product of sizes of containing panels
        axdim = fig.Position(3:4).*panaxs.Position(3:4).*mainAxis.Position(3:4);
        %Set the aspect ratio (by distorting x)
        xr = yr * .03 * axdim(1)/axdim(2);
        mainAxis.XLim = xl(1) + [0 xr];
        %Make the filtered line bold
        cellfun(@(x)set(x,'LineWidth',1.5), filtLine)
        %In this new axis, find what Y-values to draw the lines at
        xl = mainAxis.XLim;
        yl = mainAxis.YLim;
        args = str2num(customB1t.String); %#ok<ST2NM> - we're converting an array of numbers
        %The array is [step size, offset]
        ssz = args(1);
        soff = args(2);
        %The y values are multiples of ssz and extend a bit above and below the current window
        liney = (0:ssz:diff(yl)*2) + ssz*floor((min(yl)-diff(yl)*.5)/ssz) + mod(soff,ssz);
        %A third parameter sz in the array makes [sz sz sz ssz-3*sz] steps
        if length(args) > 2
            ssz = -args(3);
            liney = [liney' liney'+ssz liney'+2*ssz liney'+3*ssz];
            liney = liney(:)';
        end
        xl2 = mainRAxis.XLim;
        %Draw lines. Plot a little extra along x
        delete(stripes);
        stripes = gobjects(2, length(liney));
        for i = 1:length(liney)
            stripes(1,i) = line(mainAxis,  xl  .* [.8 1.2], liney(i) * [1 1], 'LineStyle', ':', 'Color', [1 1 1]*0);
            stripes(2,i) = line(mainRAxis, xl2 .* [.8 1]  , liney(i) * [1 1], 'LineStyle', ':', 'Color', [1 1 1]*0);
        end
    end

    function custom02_callback(~,~)
        cla(subAxis) %Convert to mirror extension
        customB2.String = 'MirExt';
        mx = cellfun(@(x,y,z) x - y/stepdata.cal.AX.k + z/stepdata.cal.BX.k, stepdata.extension, stepdata.forceAX, stepdata.forceBX, 'Un', 0);
        cellfun(@(x,y)plot(subAxis,x,y), stepdata.time, mx)
        ylim(subAxis, [-inf inf])
        return

    end

    function custom03_callback(~,~)
%         %Does FC rescaling, so you can see the effect before you make the files. See @FCrescale for more info.
%         % Alters the figure's stepdata, so rescale is useable for e.g. takePWD
%         customB3.String = 'ScaleFCs';
%         str = permCropB.String;
%         tmp = FCrescale([path file], str);
%         if ~isempty(tmp)
%             stepdata = tmp;
%             refilter_callback
%         end
        
        %Fit crop to a line, adjust to make it flat. For checking drift (Lumicks/Fran)
        csd = cropstepdata(stepdata, cropT, 0);
        pf = polyfit([csd.time{:}], [csd.contour{:}], 1);
        stepdata.contour = cellfun(@(x,y) y - x * pf(1) , stepdata.time, stepdata.contour, 'Un', 0);
        refilter_callback;
    end

    function printFig_callback(~,~)
        %Print the figure to a .png file
        print(fig, sprintf('.\\PhagePrtSc%s', datestr(now, 'yymmddHHMMSS')),'-dpng',sprintf('-r%d',96))
    end

%% Helper functions
    function varargout = plotCell(ax, x, y)
        %Plots a cell array and assigns rainbow colors to the cells
        out = cell(1,length(x));
        for i = 1:length(x)
            out{i} = plot(ax, x{i}, y{i}, 'Color', getColor(i));
        end
        %Make it act like @plot, where it returns nothing if nargout is 0
        if nargout
            varargout{1} = out;
        end
    end

    function outColor = getColor(i)
        %Generates the rainbow of colors to plot different feedback cycles
        n = 10;
        outColor = colorcircle( [mod(i + floor(n*2/3), n)+1 n], .6);
        %Original code below, replaced by the function above
        %{
        %Generates a rainbow starting from blue->red->green, period 10
        col0 = 2/3;
        dcol = .1;
        %Generate colors in hsv colorspace
        h = mod(col0 + (i-1)*dcol,1); %Hue: equally spaced along the color wheel
        s = 1; %Saturation: 1 for bold colors, .25 for pastel-y colors
        v = .6; %Value: too high makes yellow difficult to see, too low and everything is muddy
        outColor = hsv2rgb( h, s, v);
        %}
    end
end