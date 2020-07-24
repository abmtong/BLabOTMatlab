function varargout = PhageGUIcrop(varargin)
%PHAGEGUICROP MATLAB code for PhageGUIcrop.fig

% Last Modified by GUIDE v2.5 02-Nov-2017 14:46:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PhageGUIcrop_OpeningFcn, ...
                   'gui_OutputFcn',  @PhageGUIcrop_OutputFcn, ...
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
function PhageGUIcrop_OpeningFcn(hObject, eventdata, handles, varargin)
%Raw data from the loaded trace
handles.contour = [];
handles.time = [];
handles.force = [];
handles.tlim = [];
handles.flim = [];
handles.clim = [];
%File path/name
handles.path = []; %The folder containing phage*.mat files
handles.file = []; %'phage*.mat'
handles.name = []; %The * of phage*.mat
%Crop data storage
handles.cropLines = cell(1,4); %Store crop lines, so we can delete them

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

%Add subfolders with helper functions
handles.thispath = fileparts(which('PhageGUIcrop'));
addpath (handles.thispath)                 %PhageGUIcrop
addpath ([handles.thispath '\Helpers\'])   %Filename sorter
addpath ([handles.thispath '\StepFind_KV\'])%windowFilter

%Change color order to rainbow
cols = getColors(10);
handles.mainPlot.ColorOrder = cols;
handles.subPlot.ColorOrder = cols;

guidata(hObject, handles);
loadFile_Callback(hObject,eventdata,handles);

%Output handler (Right now there's no outputs, so required by GUIDE but useless)
function varargout = PhageGUIcrop_OutputFcn(hObject, eventdata, handles) %#ok<*INUSL> - Remove myriad warnings of unused var/fcn
varargout{1} = handles;

%%%%%%%%%% Callbacks %%%%%%%%%%

%Opens UI to pick a phage*.mat file
function loadFile_Callback(hObject, eventdata, handles)
%Prompt the user to select a file
[file, path] = uigetfile([handles.path filesep 'phage*.mat'], 'MultiSelect','off','Pick a Phi29 Trace');
if ~path
    return
end

%If you've changed folder, update var.s. Saves writes to GUIsettings.
if ~strcmp(handles.path, path)
    handles.path = path;
    lastpath = path; %#ok<NASGU>
    save('GUIsettings.mat','lastpath','-append');
end

%Update slider
d = dir([path filesep 'phage*.mat']);
d = {d.name};
len = length(d);
%Sort, so it's by day then by N##
d = sort_phage(d);
handles.fileslider.Min = 1;
handles.fileslider.Max = len;
handles.fileslider.String = d;
handles.fileslider.Enable = 'on';
if len ==1
    handles.fileslider.Enable = 'off';
else
    handles.fileslider.SliderStep = [1 10] ./ (len-1);
end
handles.fileslider.Value = find(cellfun(@(x) strcmp(x, file),d),1);

handles.file = file;
handles.path = path;
handles.name = file(6:end-4); %Converts 'phageMMDDYYN##.dat' to 'MMDDYYN##'

%Name the figure the filename
set(gcf,'Name',['PhageGUIcrop ' handles.name])

loadAndDraw(hObject, eventdata, handles); %guidata called here

%If ginput selected left to right, writes a crop to [path]\CropFiles\[name].crop, else deletes it
function crop_Callback(hObject, eventdata, handles)
%Prompt the user to select two x-positions (times) with ginput
[x,~] = ginput(2);

cropfp = sprintf('%s\\CropFiles\\%s.crop',handles.path, handles.name);
cropp = fileparts(cropfp);
if ~exist(cropp, 'dir')
    mkdir(cropp)
end
if ~issorted(x) %delete crop
    if exist(cropfp, 'file')
        delete(cropfp)
    end
    fprintf(['Crop deleted for ' handles.name '\n'])
else %write crop
    fid = fopen(cropfp, 'w');
    fwrite(fid, sprintf('%f\n%f', x));
    fclose(fid);
    loadCrop_Callback(hObject, eventdata, handles)
end

%Loads a crop file stored in [path]\CropFiles\[name].crop
function loadCrop_Callback(hObject, eventdata, handles)
%Create path of crop file
cropfp = sprintf('%s\\CropFiles\\%s.crop',handles.path, handles.name);
fid = fopen(cropfp);
if fid == -1
    fprintf('Crop not found for %s\n', handles.name)
    return
end

ts = textscan(fid, '%f');
fclose(fid);
ts = ts{1};

%Delete old lines
if ~isempty(handles.cropLines{1})
    cellfun(@delete, handles.cropLines)
end

%Set trimTrace to the actual crop
handles.trimTrace = ts;

%Draw a line at the start/end crop bdys
mainYLim = handles.mainPlot.YLim;
subYLim = handles.subPlot.YLim;
handles.cropLines{1} = line(handles.mainPlot,ts(1) * [1 1], mainYLim);
handles.cropLines{2} = line(handles.mainPlot,ts(2) * [1 1], mainYLim);
handles.cropLines{3} = line(handles.subPlot ,ts(1) * [1 1], subYLim);
handles.cropLines{4} = line(handles.subPlot ,ts(2) * [1 1], subYLim);
guidata(hObject,handles);

%Permanently remove sections of the trace
function trimTrace_Callback(hObject, eventdata, handles)
[x,~] = ginput(2);
x = sort(x);

ln1 = line([1 1]*x(1), [0 1e4]);
ln2 = line([1 1]*x(2), [0 1e4]);
drawnow
switch questdlg('Trim here?','Trim?','Yes','No', 'No');
    case 'Yes'
        load([handles.path handles.file], 'stepdata');
        %Find index of first greater than start, last less than end
        cellfind = @(ce) (find(ce > x(1),1));
        cellfind2 = @(ce) (find(ce < x(2),1, 'last'));
        inds = cellfun(cellfind, stepdata.time, 'UniformOutput', false); %#ok<NODEF>
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
        switch questdlg('Edit comment?','Comment?','Yes','No', 'No');
            case 'Yes'
                resp = inputdlg('Comment', 'Enter new comment', [1,80], {handles.comment.String});
                if ~isempty(resp)
                    handles.comment.String = resp{1};
                    stepdata.comment = handles.comment.String;
                end
        end
        save([handles.path handles.file], 'stepdata')
        loadAndDraw(hObject, eventdata, handles)
    case 'No'
        delete(ln1)
        delete(ln2)
end

%Outputs handles to workspace
function toWorkspace_Callback(hObject, eventdata, handles)
xlim(handles.mainPlot, handles.tlim)
ylim(handles.subPlot, handles.flim)
ylim(handles.mainPlot, handles.clim)
assignin('base','guidata',handles);

% Lets you measure the dX, dY between two points
function measure_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
[x, y] = ginput(2);
dx = abs(diff(x));
dy = abs(diff(y));

line(x,y)
text(x(end),y(end),sprintf('(dx,dy,m) = (%0.2f, %0.2f, %0.2f)\n',dx,dy,dy/dx))

%%%%%%%%%% Helper functions (not callbacks) %%%%%%%%%%

%Loads, draws the data from the file picked in @loadFile_callback
function loadAndDraw(hObject, eventdata, handles)
%Load the file, extract to GUI data
load([handles.path handles.file],'stepdata');
handles.contour = stepdata.contour;
handles.time = stepdata.time;
handles.force = stepdata.force;

filwid = [];
fildec = 5;

handles.contour = cellfun(@(x)windowFilter(@mean, x, filwid, fildec),handles.contour,'UniformOutput',0);
handles.time    = cellfun(@(x)windowFilter(@mean, x, filwid, fildec),handles.time,'UniformOutput',0);
handles.force   = cellfun(@(x)windowFilter(@mean, x, filwid, fildec),handles.force,'UniformOutput',0);

if isfield(stepdata, 'comment')
    handles.comment.String = stepdata.comment;
else
    handles.comment.String = '';
end

%Plot contour on top
cla(handles.mainPlot);
hold(handles.mainPlot, 'on')
plotCell(handles.mainPlot,handles.time,handles.contour);
hold(handles.mainPlot, 'off')

%Set con limits
maxcon = max(cellfun(@max, handles.contour));
mincon = min(cellfun(@min, handles.contour));
conpad = (maxcon - mincon)/20;
clim =[mincon-conpad, maxcon+conpad];
handles.clim = clim;
ylim(handles.mainPlot,clim);

%Plot force on bottom
cla(handles.subPlot);
hold(handles.subPlot, 'on')
plotCell(handles.subPlot,handles.time,handles.force);
hold(handles.subPlot, 'off')

%Set for limits
minfor = min(cellfun(@min, handles.force));
maxfor = max(cellfun(@max, handles.force));
forpad = (maxfor-minfor)/20;
flim = [minfor - forpad, maxfor + forpad];
handles.flim = flim;
ylim(handles.subPlot, flim);

%Set tim limits
mintim = min(cellfun(@min, handles.time));
maxtim = max(cellfun(@max, handles.time));
tlim = [mintim maxtim];
handles.tlim = tlim;
xlim(handles.mainPlot,tlim);

linkaxes([handles.subPlot, handles.mainPlot],'x');
pan off, zoom on
guidata(hObject,handles)

%Plots a xData/yData pair held in cells
function plotCell(inAxis, xData, yData)
for i = 1:length(xData)
    plot(inAxis, xData{i}, yData{i})
end

function outColor = getColors(n)
col0 = 2/3; %blue
dcol = 1/n;
s = 1; %1 for bold colors, .25 for pastel-y colors
v = .6; % too high makes yellow difficult to see, too low and everything is muddy
outColor = zeros(n,3);
for i = 1:n
    h = mod(col0 + (i-1)*dcol,1); %Color wheel
    outColor(i,:) = hsv2rgb( h, s, v);
end

function editComment_Callback(hObject, eventdata, handles)
resp = inputdlg('Comment', 'Enter new comment', [1,80], {handles.comment.String});
handles.comment.String = resp{1};
load([handles.path handles.file],'stepdata');
stepdata.comment = handles.comment.String; %#ok<STRNU>
save([handles.path handles.file],'stepdata');
guidata(hObject, handles)

function fileslider_Callback(hObject, eventdata, handles)
num = round(handles.fileslider.Value); %@round might be unnecessary, but to be safe
handles.file = handles.fileslider.String{num};
handles.name = handles.file(6:end-4);
set(gcf,'Name',['PhageGUIcrop ' handles.name])
loadAndDraw(hObject, eventdata, handles)

function fileslider_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
