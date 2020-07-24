function varargout = test(varargin)
% TEST MATLAB code for test.fig
%      TEST, by itself, creates a new TEST or raises the existing
%      singleton*.
%
%      H = TEST returns the handle to a new TEST or the handle to
%      the existing singleton*.
%
%      TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST.M with the given input arguments.
%
%      TEST('Property','Value',...) creates a new TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test

% Last Modified by GUIDE v2.5 20-Jun-2017 13:00:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_OpeningFcn, ...
                   'gui_OutputFcn',  @test_OutputFcn, ...
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
function test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user loadFile (see GUIDATA)
% varargin   command line arguments to test (see VARARGIN)

% Choose default command line output for test
handles.output = hObject; %Outputs the handle if you call this within a program
handles.contour = []; %The raw contour
handles.conFilt = []; %The filtered contour, for fitting
handles.time = [];    %The raw time
handles.timFilt = []; %The filtered time, for plotting fitted contour
handles.path = [];    %The filepath of phage*.mat files

%Look for settings file to load
if exist('GUIsettings.mat','file')
    load('GUIsettings.mat')
    if exist ('filePath','var')
        handles.path = filePath;
    end
else %Otherwise, create it
    c='Settings file for Phage GUI';
    save GUIsettings.mat c;
end




handles.colors=[0         0.4470    0.7410;
                0.8500    0.3250    0.0980;
                0.9290    0.6940    0.1250;
                0.4940    0.1840    0.5560;
                0.4660    0.6740    0.1880;
                0.3010    0.7450    0.9330;
                0.6350    0.0780    0.1840]; %the default color order for plotting

% Update handles structure
guidata(hObject, handles);

loadFile_Callback(hObject,eventdata,handles);

% UIWAIT makes test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%Output handler (Right now there's no outputs)
function varargout = test_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user loadFile (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%Loads a phage*.mat file, which contains the trace data.
function loadFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user loadFile (see GUIDATA)
[fileName, filePath] = uigetfile([handles.path filesep 'phage*.mat'], 'MultiSelect','off','Pick a Phi29 Trace');
if fileName == 0; %No file selected
    return;
end
file = load([filePath filesep fileName],'stepdata');
handles.contour = file.stepdata.contour;
handles.time = file.stepdata.time;
handles.path = filePath;
save('GUIsettings.mat','filePath','-append');
len=length(handles.contour);
handles.segment.Max = len;
handles.segment.SliderStep = [1 10]./(len-1);
handles.segment.Value = 1;
guidata(hObject,handles)

%plot whole on bottom
cla
%Check for funny stuff - way out of bounds contours
max1 = cellfun(@max, handles.contour);
max2 = max(max1);
if(max2 > 10000)
    ylim([-inf,10000]);
else
    ylim([-inf, inf]);
end
hold on
plotCell(handles.time,handles.contour);
hold off
%plot segments on top
segment_Callback(hObject,eventdata,handles);

%A slider to choose which portion of the trace to plot.
function segment_Callback(hObject, eventdata, handles)
% hObject    handle to segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

num = round(handles.segment.Value); %Round might be unnecessary, but to be safe
handles.segmentText.String = num2str(num);

%Plot the segment, with color matching the bottom plot
col = rem(num,7); % find the color to plot it as
if col == 0
    col = 7;
end
plot(handles.mainPlot,handles.time{num},handles.contour{num},'Color',handles.colors(col,:))

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function segment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%Helper function, necessary since @cellfun doesn't execute in order
function plotCell(xData, yData)
for i = 1:length(xData)
    plot(xData{i}, yData{i})
end
