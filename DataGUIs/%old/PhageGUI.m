function varargout = PhageGUI(varargin)
%PHAGEGUI MATLAB code for PhageGUI.fig
%A GUI for viewing the effects of various stepfinding algorithms on phage data
%Currently has implemented Klafut-Visscher ('K-V') and Aggarwal ('Hist') methods
%The input phage data needs to be in the format output by Ghe's tools (phage*.mat, contains struct 'stepdata')

%@author Alex Tong, this text mod'd 7/6/17
%Made with GUIDE

% Edit the above text to modify the response to help PhageGUI

% Last Modified by GUIDE v2.5 02-Oct-2017 16:57:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PhageGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PhageGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%Opening code: Create variables, open dialog for first file
function PhageGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to PhageGUI (see VARARGIN)

% Choose default command line output for PhageGUI
handles.output = hObject; %Unused, not using outputs

%%Declare various variables
%Raw data from the loaded trace
handles.contour = [];
handles.time = [];
handles.extension = [];
handles.force = [];
%File path/name
handles.path = []; %The folder containing phage*.mat files
handles.name = []; %The * of phage*.mat
%Histogram data storage - Also change @clearHist if changed.
handles.stepSizeDist = {'name','means',0:0.5:20};
handles.stepSizeDist2 = {'name','means',0:0.5:20};
%Crop data storage
handles.cropLines = cell(1,4); %Store crop lines, so we can delete them
handles.stepLines = cell(1,2); %Store stepfinding results lines, so we can delete them
handles.tempCrop = []; %Crop not stored in GUIsettings.mat, is used when fitting steps
%This is the default 7-color order for plotting, to sync colors across graphs
handles.colors=[0.000 0.447 0.741; 0.850 0.325 0.098;
                0.929 0.694 0.125; 0.494 0.184 0.556;
                0.466 0.674 0.188; 0.301 0.745 0.933;
                0.635 0.078 0.184]; 
handles.filLine = []; %Filtered data line, so can easily delete

%Add subfolders with helper functions
handles.thispath = fileparts(which('PhageGUI'));
addpath (handles.thispath)                     %PhageGUI
addpath ([handles.thispath '\StepFind_KV\'])   %K-V stepfinder
addpath ([handles.thispath '\StepFind_Hist\']) %Hist stepfinder
addpath ([handles.thispath '\StepFind_ChiSq\']) %Chi stepfinder

cla(handles.mainPlot);
cla(handles.subPlot);

%Load settings file (or create one)
if exist('GUIsettings.mat','file')
    load('GUIsettings.mat')
    if exist ('lastpath','var')
        handles.path = lastpath;
    end
else
    c='Settings file for Phage GUI';
    save GUIsettings.mat c;
end

% Update handles structure
guidata(hObject, handles);
loadFile_Callback(hObject,eventdata,handles);

%Output handler (Right now there's no outputs, so required by GUIDE but useless)
function varargout = PhageGUI_OutputFcn(hObject, eventdata, handles) %#ok<*INUSL> - Remove myriad warnings of unused var/fcn
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%% Callbacks %%%%%%%%%%

%Loads a phage*.mat file
function loadFile_Callback(hObject, eventdata, handles)
%Prompt the user to select a file
[name, path] = uigetfile([handles.path filesep 'phage*.mat'], 'MultiSelect','off','Pick a Phi29 Trace');
if name == 0; %No file selected, do nothing
    return;
end

%Load the file, extract to GUI data
file = load([path name],'stepdata');
if isfield(file.stepdata, 'comment')
    handles.filePath.String = file.stepdata.comment;
else
    handles.filePath.String = [path name];
end
handles.name = name(6:end-4); %Converts 'phageMMDDYYN##.dat' to 'MMDDYYN##'
handles.contour = file.stepdata.contour;
handles.time = file.stepdata.time;
handles.extension = file.stepdata.extension;
handles.force = file.stepdata.force;
%If you've changed folder, update var.s. Saves writes to GUIsettings.
if ~strcmp(handles.path, path)
    handles.path = path;
    lastpath = path; %#ok<NASGU>
    save('GUIsettings.mat','lastpath','-append');
end

%Name the figure the filename
set(gcf,'Name',['PhageGUI ' handles.name])

%Setup the segment choosing slider
len=length(handles.contour);
handles.segment.Enable = 'on';
handles.segment.Max = len;
if len > 1
    handles.segment.SliderStep = [1 10]./(len-1);
else %If the file only has one segment, disable the slider
    handles.segment.Enable = 'off';
end
handles.segment.Value = 1;
handles.tempCrop = [];
guidata(hObject,handles)

%Plot whole trace on bottom plot
cla(handles.subPlot);
%Set YLimits : some traces have way out of bounds contours, so compensate
maxcon = max(cellfun(@max, handles.contour)); %The second argument of the first @min is the maximum contour of the trace
mincon = min(cellfun(@min, handles.contour)); %Contour should never be negative, but for safety
conpad = (maxcon-mincon)/20;
ylim(handles.subPlot,[mincon-conpad, maxcon+conpad]);
xlim(handles.subPlot,[-Inf Inf]);
%And plot the bottom trace.
hold(handles.subPlot, 'on')
plotCell(handles.subPlot,handles.time,handles.contour);
hold(handles.subPlot, 'off')

%Plot the individual segment on top plot
segment_Callback(hObject,eventdata,handles);

%Plot the relevant segment when the slider is moved
function segment_Callback(hObject, eventdata, handles)
num = round(handles.segment.Value); %@round might be unnecessary, but to be safe
handles.segmentText.String = num2str(num);

%Calculate filtered values
con = handles.contour{num};
tim = handles.time{num};
if length(con) > 1
    linfit = polyfit(tim, con, 1);
else
    linfit = 0;
end
frc = handles.force{num};
handles.Speed.String = sprintf('%0.1fbp/s, %dpts\n%0.1f-%0.1fpN',-linfit(1), length(con), min(frc), max(frc) );
conF = GUIwindowFilter(handles, con);
timF = GUIwindowFilter(handles, tim);

%Plot them, unfiltered in grey, filtered in the appropriate color

len = length(handles.contour);
plot(handles.mainPlot,tim,con,'Color',[0.75 0.75 0.75]);
hold(handles.mainPlot, 'on');
handles.filLine = plot(handles.mainPlot,timF,conF,'Color',getColor(num,len));
hold(handles.mainPlot, 'off');
tpad = 0.05;
cpad = 10;
xlim(handles.mainPlot, [tim(1), tim(end)] + tpad * [-1 1]);
ylim(handles.mainPlot, [min(con), max(con)] + cpad * [-1 1]);

%Update GUI data
guidata(hObject,handles)

%Clears the lines generated by stepfinding fcns
function clearGraph_Callback(hObject, eventdata, handles)
%Delete staircases
cellfun(@delete,handles.stepLines);
%Delete text, pointing lines
len = length(handles.mainPlot.Children);
toDel = false(1,len);
for i = 1:len
    gobj = handles.mainPlot.Children(i);
    if isgraphics(gobj, 'Text')
        toDel(i)=true;
    elseif isgraphics(gobj, 'Line') && length(gobj.XData) == 2;
        toDel(i)=true;
    end
end
arrayfun(@delete, handles.mainPlot.Children(toDel))

%Writes a crop to [path]\CropFiles\[name].crop
function crop_Callback(hObject, eventdata, handles)
%Prompt the user to select two x-positions (times) with ginput
[x,~] = ginput(2);
x = sort(x);

cropfp = sprintf('%s\\CropFiles\\%s.crop',handles.path, handles.name);
cropp = fileparts(cropfp);
if ~exist(cropp, 'dir')
    mkdir(cropp)
end
fid = fopen(cropfp, 'w');
fwrite(fid, sprintf('%f\n%f', x))
fclose(fid);

%Load the newly made crop
loadCrop_Callback(hObject, eventdata, handles)

%Loads a crop file stored in [path]\CropFiles\[name].crop
function loadCrop_Callback(hObject, eventdata, handles)
%Create path of crop file
cropfp = sprintf('%s\\CropFiles\\%s.crop',handles.path, handles.name);
fid = fopen(cropfp);
if fid == -1
    fprintf('Crop not found for %s', handles.name)
    return
end

ts = textscan(fid, '%f');
fclose(fid);
ts = ts{1};

%Delete old lines
if ~isempty(handles.cropLines{1})
    cellfun(@delete, handles.cropLines)
end

%Set tempCrop to the actual crop
handles.tempCrop = ts;

%Draw a line at the start/end crop bdys
mainYLim = handles.mainPlot.YLim;
subYLim = handles.subPlot.YLim;
handles.cropLines{1} = line(handles.mainPlot,ts(1) * [1 1], mainYLim);
handles.cropLines{2} = line(handles.mainPlot,ts(2) * [1 1], mainYLim);
handles.cropLines{3} = line(handles.subPlot ,ts(1) * [1 1], subYLim);
handles.cropLines{4} = line(handles.subPlot ,ts(2) * [1 1], subYLim);
guidata(hObject,handles);

%Creates a temporary crop of the data- it still determines the steps used when stepfindings, but is not saved
function tempCrop_Callback(hObject, eventdata, handles)
[x,~] = ginput(2);
handles.tempCrop = sort(x);
guidata(hObject, handles);

%Clears the histograms - Also change initiation (@PhageGUI_OpeningFcn) if changed.
function clearHists_Callback(hObject, eventdata, handles)
%Clear histogram data
handles.stepSizeDist = {'name','means',0:0.5:20};
handles.stepSizeDist2 = {'name','means',0:0.5:20};
%Clear histogram plots
cla(handles.stepHist);
cla(handles.stepHist2);
%Update GUI data
guidata(hObject,handles);

%Recalculates the trace based on different XWLC param.s (ends up being about the same)
function reContour_Callback(hObject, eventdata, handles)
%New P(ersistence length) and S(tretch modulus). Ghe uses P=35, S=1200
P = 45;
S = 800;
%Process each segment
for i = 1:length(handles.contour)
    %Contour = (extension) / (extension/contour) * (nm/bp)
    handles.contour{i} = real(handles.extension{i} ./ ForceExt_XWLC(handles.force{i}, P, S) /.34);
end

%Plot top graph
segment_Callback(hObject, eventdata, handles);

%Plot bottom graph
hold(handles.subPlot, 'on')
plotCell(handles.subPlot,handles.time,handles.contour);
hold(handles.subPlot, 'off')

%Update GUI data
guidata(hObject, handles);

%Outputs current trace and the rest of the handles to the workspace
function toWorkspace_Callback(hObject, eventdata, handles)
num = round(handles.segment.Value);
assignin('base','guidata',handles);
assignin('base','guiC',handles.contour{num});

con = handles.contour{num};
tim = handles.time{num};

assignin('base','guiCfkv',GUIwindowFilter(handles, con, 1));
assignin('base','guiCfhs',GUIwindowFilter(handles, con, 2));
assignin('base','guiT',handles.time{num});
assignin('base','guiTfkv',GUIwindowFilter(handles, tim, 1));
assignin('base','guiTfhs',GUIwindowFilter(handles, tim, 2));

if ~isempty(handles.tempCrop);
    cropind = tim >= handles.tempCrop(1) & tim < handles.tempCrop(2);
    assignin('base','guiCc',con(cropind));
    assignin('base','guiTc',tim(cropind));
end

function printFig_Callback(hObject, eventdata, handles)
saveas(handles.figure1, [datestr(now, 'mm dd yy HH MM SS') '.png'])

%%%%%%%%%% Helper functions (not callbacks) %%%%%%%%%%

%Applies a stepfinding algorithm to the trace segment shown in the top window. Plots the results and step size histogram.
function findSteps(hObject, eventdata, handles, option)
%option=1 for K-V, =2 for Hist, 3 for ChSq

%option2 = 1 -> use extension, not contour
option2 = 0;

%Grab GUI values
seg = round(handles.segment.Value);
con = handles.contour{seg};
tim = handles.time{seg};

%If a tempCrop exists, apply it
if ~isempty(handles.tempCrop);
    cropind = tim >= handles.tempCrop(1) & tim < handles.tempCrop(2);
    con = con(cropind);
    tim = tim(cropind);
end

if option2
    realcon = con;
    con = handles.extension{seg};
    if ~isempty(handles.tempCrop);
        con = con(cropind);
    end
end


if length(con) < 100
    fprintf('Too few points within crop boundary, skipping\n');
    return;
end

%Filter it
tr = GUIwindowFilter(handles, con, option);
tim = GUIwindowFilter(handles, tim, option);
%Apply stepfinding alogrithm, outputs are stepInd = index of step in tr (?time), and stepMean = position (bp) of dwell
%Since there is one more dwell than there are bursts, length(stepInd) = length(stepMean)+1

switch option
    case 1 %K-V
        dec = str2double(handles.decimate.String);
        [stepInd, stepMean] = AFindStepsV4(tr);
        color = [0 0 0.5]; %plot K-V steps blue
        histax = handles.stepHist; %plot the histogram on the upper graph
        diststr = 'stepSizeDist'; %Use the K-V histogram data
    case 2 %Hist                        V7d, V8C
        dec = str2double(handles.decimate_H.String);
        [stepInd, stepMean] = findStepHistV7d(tr,0.2,[],[],dec);
        color = [0.5 0 0]; %plot Hist steps red
        histax = handles.stepHist2; %Plot the histogram on the lower graph
        diststr = 'stepSizeDist2'; %Use the Hist histogram data
    case 3 %ChSq
        dec = str2double(handles.decimate.String);
        [stepInd, stepMean] = fsChSq(tr,[], 2);
        color = [0 0.5 0]; %plot ChSq steps green
        histax = handles.stepHist; %plot the histogram on the upper graph
        diststr = 'stepSizeDist'; %Use the K-V histogram data\
        option = 1; %Do the same as K-V
end

if option2
    %Calculate means - the step heights
    tr2 = GUIwindowFilter(handles, realcon, option);
    stepMean = zeros(1,length(stepInd)-1);
    for i = 1:length(stepMean)
        stepMean(i) = mean(tr2(stepInd(i):stepInd(i+1)));
    end
end


%Create the stepping line and plot it
len = length(stepInd);
indX =[1 reshape([2:len-1;2:len-1],1,[]) len]; %This creates [1 2 2 3 3 4 4 ... len-1 len-1 len]
indY = reshape([1:len-1; 1:len-1],1,[]); %This creates [1 1 2 2 3 3 4 4 5 5... len-1 len-1]
lineX = tim(stepInd(indX));
lineY = stepMean(indY);
%Remove old lines
if ~isempty(handles.stepLines{option})
    delete(handles.stepLines{option})
end
hold(handles.mainPlot, 'on');
handles.stepLines{option} = line(handles.mainPlot, lineX,lineY, 'Color', color);
%Indicate step sizes on graph
%Define how long we want the step size-indicating lines to be
dt = .01;
dc = 10;
switch option
    case 2%Plot (hist) in red below steps
        for i = 1:length(stepInd)-2;
            line(handles.mainPlot, double(tim(stepInd(i+1))*[1 1] - [0 dt]), double(stepMean(i+1)) * [1 1] - [0 dc], 'Color', [0.5 0 0])
            text(handles.mainPlot, double(tim(stepInd(i+1))-dt), double(stepMean(i+1))-dc, sprintf('%0.1f',stepMean(i)-stepMean(i+1)))
        end
    otherwise%Plot (K-V, ChSq) in blue above steps
        for i = 1:length(stepInd)-2;
            line(handles.mainPlot, tim(stepInd(i+1))*[1 1] + [0 dt], stepMean(i) * [1 1] + [0 dc], 'Color', [0 0 0.5])
            text(handles.mainPlot, double(tim(stepInd(i+1))+dt), double(stepMean(i))+dc, sprintf('%0.1f',stepMean(i)-stepMean(i+1)))
        end
end
hold(handles.mainPlot, 'off');

%Bin the step sizes
bins = handles.(diststr){1,3}; %0:0.5:20, or whatever is defined in @clearHists_Callback / opening fcn
len = length(bins);
binmean = zeros(1,len); %to save this individual trace's data
nums = zeros(1, len); %to hold the whole histogram's data
steps = -diff(stepMean);
%Count the number of points in the bins
for i = 1:len-1
    binmean(i) = sum( steps >= bins(i) & steps < bins(i+1) );
end
%Save to GUI data
stepName = [handles.name '#' num2str(seg)];
ind = findCellField(handles.(diststr),stepName);
if ~ind
    ind = size(handles.(diststr),1)+1;
end
handles.(diststr){ind,1} = stepName;
handles.(diststr){ind,2} = steps;
handles.(diststr){ind,3} = binmean;
%Sum across bins
for i = 2:size(handles.(diststr),1)
    nums = nums + handles.(diststr){i,3};
end
%And update graph
plot(histax, nums, bins);
guidata(hObject, handles);

%Plots a xData/yData pair held in cells
function plotCell(inAxis, xData, yData)
len = length(xData);
for i = 1:len
    plot(inAxis, xData{i}, yData{i}, 'Color', getColor(i,len))
end

% Filters by a centered window (with inWindow points at each side) with filterFunction [filter params are extracted from handles]
function outData = GUIwindowFilter(handles, inData, option)
if nargin < 3 || isempty(option)
    option = 1; % =1 if filtering KV, otherwise Hist
end

%Grab values from GUI
switch option
    case 2
        inDecimate = str2double(handles.decimate_H.String);
        inWidth = str2num(handles.filterWidth_H.String); %#ok<ST2NM>
    otherwise
        inDecimate = str2double(handles.decimate.String);
        inWidth = str2num(handles.filterWidth.String); %#ok<ST2NM>
end
filterFunction = str2func(handles.filterMenu.String{handles.filterMenu.Value});
outData = windowFilter(filterFunction, inData, inWidth, inDecimate);

%Looks for inStr in inCell(1,:) and returns the index (first occurrence if multiple, 0 if it's not found)
function outInd = findCellField(inCell, inStr)
for i = 1:size(inCell,1)
    if strcmp(inCell{i,1},inStr)
        outInd = i;
        return
    end
end
outInd = 0;

function outColor = getColor(i,n)
col0 = 2/3; %blue
dcol = .1; %10 color cycle, enough to tell apart & slider fast-move is 10 segments
h = mod(col0 + (i-1)*dcol,1); %Color wheel
s = 1; %1 for bold colors, .25 for pastel-y colors
v = .6; % too high makes yellow difficult to see, too low and everything is muddy
outColor = hsv2rgb( h, s, v);

function reFilter(hObject, handles)
num = round(handles.segment.Value); %@round might be unnecessary, but to be safe

len = length(handles.contour);
%Calculate filtered values
con = handles.contour{num};
tim = handles.time{num};

conF = GUIwindowFilter(handles, con);
timF = GUIwindowFilter(handles, tim);


%Plot them, unfiltered in grey, filtered in the appropriate color
delete(handles.filLine);
hold(handles.mainPlot, 'on');
handles.filLine = plot(handles.mainPlot,timF,conF,'Color',getColor(num,len));
hold(handles.mainPlot, 'off');
guidata(hObject, handles)

%%%%%%%%%% Callbacks that point to other functions/callbacks %%%%%%%%%%

function findStep_Callback(hObject, eventdata, handles)
findSteps(hObject, eventdata, handles, 1)
function findStep_H_Callback(hObject, eventdata, handles)
findSteps(hObject, eventdata, handles, 2)
function findStepChSq_Callback(hObject, eventdata, handles)
findSteps(hObject, eventdata, handles, 3)
function filterMenu_Callback(hObject, eventdata, handles)
reFilter(hObject, handles)
function filterWidth_Callback(hObject, eventdata, handles)
reFilter(hObject, handles)
function filterWidth_H_Callback(hObject, eventdata, handles)
function decimate_Callback(hObject, eventdata, handles)
reFilter(hObject, handles)
function decimate_H_Callback(hObject, eventdata, handles)

%%%%%%%%%% Requried by GUIDE, but unused %%%%%%%%%%

function segmentText_CreateFcn(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD> - Removes myriad warnings of unused var/fcn
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function segment_CreateFcn(hObject, eventdata, handles)
function filterMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function filterWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function filterWidth_H_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function decimate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function decimate_H_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
