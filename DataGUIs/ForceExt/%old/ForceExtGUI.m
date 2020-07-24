function varargout = ForceExtGUI(varargin)
% FORCEEXTGUI MATLAB code for ForceExtGUI.fig
%      FORCEEXTGUI, by itself, creates a new FORCEEXTGUI or raises the existing
%      singleton*.
%
%      H = FORCEEXTGUI returns the handle to a new FORCEEXTGUI or the handle to
%      the existing singleton*.
%
%      FORCEEXTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FORCEEXTGUI.M with the given input arguments.
%
%      FORCEEXTGUI('Property','Value',...) creates a new FORCEEXTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ForceExtGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ForceExtGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ForceExtGUI

% Last Modified by GUIDE v2.5 14-Sep-2017 15:23:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ForceExtGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ForceExtGUI_OutputFcn, ...
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

% --- Executes just before ForceExtGUI is made visible.
function ForceExtGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to ForceExtGUI (see VARARGIN)

% Choose default command line output for ForceExtGUI
handles.output = hObject;

%%Declare various variables
%Raw data from the loaded trace
handles.time = [];
handles.extension = [];
handles.force = [];
%File path/name
handles.path = []; %The folder containing phage*.mat files
handles.name = []; %The * of ForceExtension_*.mat
%WLC Params Storage
handles.wlcData = {'name','perlen','strmod','conlen'};
handles.wlciData = {'name','dx','n','ki'};
%Crop data storage
handles.cropLines = cell(1,2); %Store crop lines, so we can delete them
handles.stepLines = cell(1,1); %Store fitting results line, to delete
handles.crops = {'cropped_file','[crop_time_start crop_time_end]'}; %Store crop data
handles.tempCrop = []; %Store current crop

cla(handles.mainPlot);
cla(handles.subPlot);

%Load settings file (or create one)
if exist('ForceExtGUIsettings.mat','file')
    load('ForceExtGUIsettings.mat')
    if exist ('filePath','var')
        handles.path = filePath;
    end
    if exist('crops','var')
        handles.crops = crops;
    end
else
    c='Settings file for Phage GUI';
    save ForceExtGUIsettings.mat c;
end

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = ForceExtGUI_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%% Callbacks %%%%%%%%%%

function loadFile_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
%Prompt the user to select a file
[fileName, filePath] = uigetfile([handles.path filesep 'For*.mat'], 'MultiSelect','off','Pick a ForceExtension Trace');
if fileName == 0; %No file selected, do nothing
    return
end

%Load the file, extract to GUI data
file = load([filePath filesep fileName],'ContourData');
handles.name = fileName(16:end-4); %Converts 'ForceExtension_MMDDYYN##.dat' to 'MMDDYYN##'
handles.time = file.ContourData.time;
handles.extension = file.ContourData.extension;
handles.force = file.ContourData.force;
%If you've changed folder, update var.s, ForceExtGUIsettings.
if ~strcmp(handles.path, filePath)
    handles.path = filePath;
    save('ForceExtGUIsettings.mat','filePath','-append');
end

handles.tempCrop = [];

%Plot For-Time on top, For-Ext on bottom
cla(handles.mainPlot)
cla(handles.subPlot, 'reset')
cla(handles.residPlot, 'reset')
plot(handles.mainPlot, handles.time, handles.force)
plot(handles.subPlot, handles.extension, handles.force)

guidata(hObject,handles)

function crop_Callback(hObject, eventdata, handles)
%Prompt the user to select two x-positions (times) with ginput
[x,~] = ginput(2);
x = sort(x);

%If there's already a crop for the file, overwrite it, else append
ind = findCellField(handles.crops,handles.name);
if ~ind %Crop not found, append to the end
    ind = size(handles.crops,1)+1;
end
handles.crops{ind,1} = handles.name;
handles.crops{ind,2} = x;

%Save to file
crops = handles.crops; %#ok<NASGU>
save('ForceExtGUIsettings.mat','crops','-append');

%Load the newly made crop [guidata will be saved in @loadCrop_Callback]
loadCrop_Callback(hObject, eventdata, handles)

function loadCrop_Callback(hObject, eventdata, handles)
%Check if the file is cropped
ind = findCellField(handles.crops, handles.name);
if ~ind
    disp(['Crop not found for ' handles.name '.']);
else
    %Delete old lines
    if ~isempty(handles.cropLines{1})
        cellfun(@delete, handles.cropLines)
    end
    
    %Set tempCrop to the actual crop
    handles.tempCrop = handles.crops{ind,2};

    %Draw a line at the start/end crop bdys
    handles.cropLines{1} = line(handles.mainPlot,handles.crops{ind,2}(1) * [1 1], [0 30]);
    handles.cropLines{2} = line(handles.mainPlot,handles.crops{ind,2}(2) * [1 1], [0 30]);

end
guidata(hObject,handles);

function clearWLCParams_Callback(hObject, eventdata, handles)
handles.wlcTable.Data = cell(8,2);
guidata(hObject, handles);

function fitWLC_Callback(hObject, eventdata, handles) %#ok<*INUSD>
[fitParams, xl] = fitWLC(handles,1);
if isempty(fitParams)
    return
end
handles.wlcTable.Data{1,1} = fitParams(1);
handles.wlcTable.Data{2,1} = fitParams(2);
handles.wlcTable.Data{3,1} = fitParams(3);
handles.residPlot.XLim = xl;
linkaxes([handles.residPlot, handles.subPlot], 'x')
guidata(hObject, handles)

function fitWLCInterc_Callback(hObject, eventdata, handles)
fitWLC(handles, 2);

function toWorkspace_Callback(hObject, eventdata, handles)
assignin('base','guidata',handles);
if ~isempty(handles.tempCrop);
    cropind = handles.time >= handles.tempCrop(1) & handles.time < handles.tempCrop(2);
    assignin('base', 'guiFc', handles.force(cropind));
    assignin('base','guiTc', handles.time(cropind));
    assignin('base','guiXc', handles.extension(cropind));
end
assignin('base','guiX',handles.extension);
assignin('base','guiT',handles.time);
assignin('base','guiF',handles.force);
assignin('base','guiFit',[handles.wlcTable.Data{1:3,1}]);

%%%%%%%%%% Helper Functions %%%%%%%%%%

function [fitParams, xl] = fitWLC(handles, option)
if ~isempty(handles.tempCrop);
    cropind = handles.time >= handles.tempCrop(1) & handles.time < handles.tempCrop(2);
    frc = handles.force(cropind);
    %tim = handles.time(cropind);
    ext = handles.extension(cropind);
else
    fprintf('Curve needs to be cropped before fitting.')
    fitParams = [];
    xl = [];
    return
end
switch option
    case 1
        fr = str2num(handles.loF.String); %#ok<ST2NM>
        opts.loF = fr(1);
        opts.hiF = fr(2);
        wid = str2double(handles.hiF.String);
        frc = smooth(frc, wid);
        ext = smooth(ext, wid);
        
        fitParams = fitForceExt(ext,frc,opts);
        cla(handles.residPlot)
        plot(handles.subPlot, ext, frc,'Color',[.8 .8 .8])
        hold(handles.subPlot,'on')
        frp = opts.loF:0.1:opts.hiF;
        wlcfun = @(x)ForceExt_XWLC_Wikipedia(x, fitParams(1), fitParams(2))*fitParams(3)*.34;
        plot(handles.subPlot, wlcfun(frp), frp)
        xl = [wlcfun(opts.loF), wlcfun(opts.hiF)] + [-10 10];
        plot(handles.residPlot, wlcfun(frc), (wlcfun(frc)-ext)./wlcfun(frc),'o')
        line(handles.residPlot, xl, [0,0])
    case 2
        fitParams = firForceExtInterc(ext, frc, [handles.wlcTable.Data{1:3,1}]);
end

%Looks for inStr in inCell(1,:) and returns the index (first occurrence if multiple, 0 if it's not found)
function outInd = findCellField(inCell, inStr)
for i = 1:size(inCell,1)
    if strcmp(inCell{i,1},inStr)
        outInd = i;
        return
    end
end
outInd = 0;

%%%%%%%%%% Unused, but required by GUIDE %%%%%%%%%%

function loF_Callback(hObject, eventdata, handles)
function loF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hiF_Callback(hObject, eventdata, handles)
function hiF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
