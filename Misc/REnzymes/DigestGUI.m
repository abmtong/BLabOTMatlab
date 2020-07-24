function varargout = DigestGUI(varargin)
% DIGESTGUI MATLAB code for DigestGUI.fig
%      DIGESTGUI, by itself, creates a new DIGESTGUI or raises the existing
%      singleton*.
%
%      H = DIGESTGUI returns the handle to a new DIGESTGUI or the handle to
%      the existing singleton*.
%
%      DIGESTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIGESTGUI.M with the given input arguments.
%
%      DIGESTGUI('Property','Value',...) creates a new DIGESTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DigestGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DigestGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DigestGUI

% Last Modified by GUIDE v2.5 06-Oct-2017 19:49:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DigestGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DigestGUI_OutputFcn, ...
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

function DigestGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.data = [];
if ~isempty(varargin)
    handles.data = varargin{1};
    handles.menu.String = unique(handles.data(:,1));
    menu_Callback(hObject, eventdata, handles)
end
guidata(hObject, handles);

function varargout = DigestGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function menu_Callback(hObject, eventdata, handles) %#ok<*INUSD>
len = 19282;
cla(handles.mainPlot);
xlim(handles.mainPlot,[0 len]);
ylim(handles.mainPlot,[-1 1]);
[names, ~, vals] = unique(handles.data(:,1));
name = handles.menu.String{handles.menu.Value};
REind = find(strcmp(names,name), 1);
inds = vals == REind;
snip = handles.data(inds, :);
text(handles.mainPlot, 0,.9,sprintf('%s, site %s, %s overhang',  name, snip{1,2}, snip{1,5} ), 'Interpreter','none')
text(handles.mainPlot, 0,.45,sprintf('%s\n', snip{:,6}))
x = [snip{:,3}];
%For each site
for j = 1:size(snip,1)
    if strcmp(snip{j,4}, '5''')
        y = 1;
    else
        y = -1;
        x(j) = -x(j);
    end
    line(handles.mainPlot, [0 len], [0 0])
    xx = snip{j,3};
    line(handles.mainPlot, [xx xx], [0 y])
end
x = [1 sort(abs(x)) len];
dx = diff(x);
for j = 1:length(dx)
    text(handles.mainPlot, mean(x(j:j+1)),0.2, sprintf('%0.2fkb', dx(j)/1e3 ))
end
guidata(hObject, handles)

function loadFile_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
thispath = fileparts(which('REnzymeGUI'));
[file, path] = uigetfile(thispath);
if ~path
    return
end
dat = load([path file]);
fnames = fieldnames(dat);
handles.data = dat.(fnames{1});
handles.menu.String = unique(handles.data(:,1));
menu_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

function goName_Callback(hObject, eventdata, handles)
name = handles.findName.String;
ind = findEnzyme(unique(handles.data(:,1)),name);
if ind
    handles.menu.Value = ind;
    menu_Callback(hObject, eventdata, handles)
    return
end
guidata(hObject, handles);

function findName_Callback(hObject, eventdata, handles)
function menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function findName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
