function varargout = MovieGUI(varargin)
% MOVIEGUI MATLAB code for MovieGUI.fig
%      MOVIEGUI, by itself, creates a new MOVIEGUI or raises the existing
%      singleton*.
%
%      H = MOVIEGUI returns the handle to a new MOVIEGUI or the handle to
%      the existing singleton*.
%
%      MOVIEGUI('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in MOVIEGUI.M with the given input arguments.
%
%      MOVIEGUI('Property','Value',...) creates a new MOVIEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MovieGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MovieGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help MovieGUI

% Last Modified by GUIDE v2.5 08-Jan-2018 12:55:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MovieGUI_OpeningFcn, ...
    'gui_OutputFcn',  @MovieGUI_OutputFcn, ...
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


% --- Executes just before MovieGUI is made visible.
function MovieGUI_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
% varargin   command line arguments to MovieGUI (see VARARGIN)

% Choose default command line output for MovieGUI
h.output = hObject;

% default filepath for eye camera
h.filepath = '/home/carsen/pach/data/EXP/';
h.suffix   = {'.mj2','.mp4','.mkv','.avi','.mpeg','.mpg','.asf'}; % suffix of eye camera file!

% default filepath to write binary file (ideally an SSD)
h.binfolder = 'F:\DATA';

% default smoothing constants
h.sc        = 4;
h.tsc       = 1;

set(h.slider2,'Min',0);
set(h.slider2,'Max',1);
set(h.slider2,'Value',0);
set(h.edit1,'String',num2str(0));
h.saturation = zeros(100,1);
h.whichfile = 1;

axes(h.axes1);
set(gca,'xtick',[],'ytick',[]);
box on;

% Update h structure
guidata(hObject, h);

% UIWAIT makes MovieGUI wait for user response (see UIRESUME)
% uiwait(h.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MovieGUI_OutputFcn(hObject, eventdata, h)
% Get default command line output from h structure
varargout{1} = h.output;


%%%%% choose folder to write binary file
function pushbutton18_Callback(hObject, eventdata, h)
folder_name = uigetdir(h.binfolder);
if folder_name ~= 0
    h.binfolder = folder_name;
    set(h.text21,'String',h.binfolder);
end
% Update h structure
guidata(hObject, h);


% ------------ choose folder -- can have multiple blocks!
function folder_Callback(hObject, eventdata, h)
folder_name = uigetdir(h.filepath);
if folder_name ~= 0
    h.rootfolder = folder_name;
    [filename,folders,namef] = FindBlocks(h,folder_name);
    
    if isempty(filename{1})
        msgbox('ahh! no movie files found!');
    else
        [filename,folders,namef] = ChooseFiles(filename,folders,namef);
    
        h.files = filename;
        h.folders = folders;
        h.vr = [];
        h.nX = [];
        h.nY = [];
        for j = 1:numel(filename)
            h.vr{j} = VideoReader(filename{j});
            nX{j}    = h.vr{j}.Width;
            nY{j}    = h.vr{j}.Height;
            h.nX = nX;
            h.nY = nY;
            h.whichfile = j;
            h = ResetROIs(h);
        end
        h.wROI = 1;
        h.rcurr = 0;
        h.whichfile = 1;
        
        set(h.popupmenu6,'String',folders);
        set(h.popupmenu6,'Value',h.whichfile);
        
        
        % reset ROIs to fit in video
        
        fprintf('displaying \n%s\n',filename{h.whichfile});
        if length(folder_name) > length(h.filepath)
            if strcmp(folder_name(1:length(h.filepath)),h.filepath)
                foldname = folder_name(length(h.filepath)+1:end);
                ns       = strfind(foldname,'\');
                if isempty(ns)
                    ns   = strfind(foldname,'/');
                end
                if ~isempty(ns)
                    ns = ns(1);
                    foldname = sprintf('%s\n%s',foldname(1:ns),foldname(ns+1:end));
                    set(h.text13,'String',foldname);
                else
                    set(h.text13,'String',folder_name);
                end
            else
                set(h.text13,'String',folder_name);
            end
        else
            set(h.text13,'String',folder_name);
        end
        
        h.folder_name = folder_name;
        h.nframes = h.vr{h.whichfile}.Duration*h.vr{h.whichfile}.FrameRate-1;
        disp(h.nframes)
        h.cframe = 1;
        set(h.slider1,'Value',0);
        set(h.slider4,'Value',0);
        set(h.edit3,'String','1');
        
        PlotFrame(h);
    end
end
guidata(hObject,h);

% --------------- choose file to view! -------------------%
function popupmenu6_Callback(hObject, eventdata, h)
h.whichfile = get(hObject,'Value');
h.cframe = 1;
h.wROI = 1;
set(h.checkbox16,'Value',1);
PlotFrame(h);
fprintf('displaying \n%s\n',h.files{h.whichfile});
h.nframes = h.vr{h.whichfile}.Duration*h.vr{h.whichfile}.FrameRate-1;
set(h.edit1,'String',sprintf('%1.2f',h.saturation(h.whichfile)));
set(h.slider2,'Value',h.saturation(h.whichfile));
guidata(hObject,h);


% SET WHETHER OR NOT TO VIEW AREAS
function checkbox16_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.wROI = wc;
PlotFrame(h);
guidata(hObject,h);


function keepROI_Callback(hObject, eventdata, h)
nxS = floor(h.nX{h.whichfile} / h.sc);
nyS = floor(h.nY{h.whichfile} / h.sc);
if isempty(h.ROI{h.whichfile}{1})
    ROI0 = [1 1 nxS nyS];
else
    ROI0 = [nxS*.25 nyS*.25 nxS*.5 nyS*.5];
end
ROI = DrawROI(h,ROI0);
ROI = OnScreenROI(ROI, nxS, nyS);
if isempty(h.ROI{h.whichfile}{1})
    h.ROI{h.whichfile}{1} = ROI;
else
    h.ROI{h.whichfile}{end+1} = ROI;
end
h.rcurr = 0;

PlotFrame(h);

guidata(hObject, h);

function excludeROI_Callback(hObject, eventdata, h)
nxS = floor(h.nX{h.whichfile} / h.sc);
nyS = floor(h.nY{h.whichfile} / h.sc);
ROI0 = [nxS*.4 nyS*.4 nxS*.3 nyS*.3];
ROI = DrawROI(h,ROI0);
ROI = OnScreenROI(ROI, nxS, nyS);
if isempty(h.eROI{h.whichfile}{1})
    h.eROI{h.whichfile}{1} = ROI;
else
    h.eROI{h.whichfile}{end+1} = ROI;
end
h.rcurr = 1;

PlotFrame(h);

guidata(hObject, h);

function deleteall_Callback(hObject, eventdata, h)
h = ResetROIs(h);
PlotFrame(h);
guidata(hObject, h);

function deleteone_Callback(hObject, eventdata, h)
if h.rcurr
    if numel(h.eROI{h.whichfile}) > 1
        h.eROI{h.whichfile} = h.eROI{h.whichfile}(1:end-1);
    else
        h.eROI{h.whichfile}{1} = [];
    end
else
    if numel(h.ROI{h.whichfile}) > 1
        h.ROI{h.whichfile} = h.ROI{h.whichfile}(1:end-1);
    else
        h.ROI{h.whichfile}{1} = [];
    end
end
PlotFrame(h);
guidata(hObject, h);


% --- SLIDER FOR CHOOSING DISPLAYED FRAME ------------------ %
function slider1_CreateFcn(hObject, eventdata, h)
% Hint: slider controls usually have a light gray background.
set(hObject,'Interruptible','On');
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.75 .75 .75]);
end

function slider1_Callback(hObject, eventdata, h)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(hObject,'Interruptible','On');
set(hObject,'BusyAction','cancel');
v = get(hObject,'Value');
smin = get(hObject,'Min');
smax = get(hObject,'Max');
cframe = min(h.nframes,max(1,round(v/(smax-smin) * h.nframes)));
h.cframe = cframe;
set(h.edit3,'String',num2str(cframe));
set(h.slider4,'Value',h.cframe/h.nframes);
PlotFrame(h);

guidata(hObject,h);


% --- FINESCALE SLIDER ------------------ %
function slider4_Callback(hObject, eventdata, h)
set(hObject,'Interruptible','On');
set(hObject,'BusyAction','cancel');
set(hObject,'SliderStep',[1/double(h.nframes) 2/double(h.nframes)]);
v = get(hObject,'Value');
cframe = min(h.nframes,max(1,round((v)*h.nframes)));%%/ h.nframes)));
h.cframe = cframe;
set(h.edit3,'String',num2str(cframe));
set(h.slider1,'Value',h.cframe/h.nframes);
PlotFrame(h);
guidata(hObject,h);

function slider4_CreateFcn(hObject, eventdata, h)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',0);
set(hObject,'Max',1);


% --- PLAY button
function togglebutton1_Callback(hObject, eventdata, h)
while get(hObject, 'value') && h.cframe < h.nframes
    h.cframe = h.cframe+4;
    set(h.edit3,'String',num2str(h.cframe));
    set(h.slider1,'Value',h.cframe/h.nframes);
    PlotFrame(h);
end
set(h.slider4,'Value',h.cframe/h.nframes);
guidata(hObject,h);


% --- SLIDER FOR SATURATION -------------------%
function slider2_Callback(hObject, eventdata, h)
set(hObject,'Interruptible','On');
set(hObject,'BusyAction','cancel');
sats = get(hObject,'Value');
h.saturation(h.whichfile) = sats;
set(h.edit1,'String',sprintf('%1.2f',sats));
PlotFrame(h);
guidata(hObject, h);

function slider2_CreateFcn(hObject, eventdata, h)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function edit1_Callback(hObject, eventdata, h)
sval = get(hObject,'String');
set(h.slider2,'Value',str2num(sval));
h.saturation(h.whichfile) = str2num(sval);
PlotFrame(h);
guidata(hObject,h);

function edit1_CreateFcn(hObject, eventdata, h)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','String',num2str(h.pupLow));
end


% ------ Save ROI settings and keep list of saved folders ----- %
function savesettings_Callback(hObject, eventdata,h)
saveROI(h);
if ~isfield(h,'multifiles')
    ik = 1;
else
    ik = length(h.multifiles)+1;
end
h.multifiles{ik} = h.settings;
if strcmp(h.settings(1:length(h.filepath)),h.filepath)
    foldname = h.settings(length(h.filepath)+1:end);
else
    foldname = h.settings;
end
h.multifilelabel{ik} = foldname;

guidata(hObject,h);


% ----- ROIs will be processed across expts -------------------- %
function processROIs_Callback(hObject, eventdata, h)
h = LumpProc(h);
guidata(hObject,h);


%%%% list of files box
function popupmenu6_CreateFcn(hObject, eventdata, h)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','first choose folder');
set(hObject,'Value',1);
if isfield(h,'folders')
    set(hObject,'String',folders);
end

%%%%% frame number edit box
function edit3_Callback(hObject, eventdata, h)
cframe = get(hObject,'String');
if iscell(cframe)
    cframe = cframe{1};
end
h.cframe = max(1,min(h.nframes,round(str2num(cframe))));
set(hObject,'String',sprintf('%d',h.cframe));
set(h.slider1,'Value',h.cframe/h.nframes);
set(h.slider4,'Value',h.cframe/h.nframes);
PlotFrame(h);
guidata(hObject,h);

function edit3_CreateFcn(hObject, eventdata, h)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%% SPATIAL SMOOTHING BOX
function edit4_Callback(hObject, eventdata, h)
spatscale = get(hObject,'String');
if iscell(spatscale)
    spatscale = spatscale{1};
end
spatscale = max(1, min(50, round(str2num(spatscale))));
% resize ROIs
h = ResizeROIs(h, spatscale);

h.sc    = spatscale;
set(hObject, 'String', sprintf('%d', h.sc));

PlotFrame(h);
guidata(hObject, h);

function edit4_CreateFcn(hObject, eventdata, h)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% temporal smoothing constant box
function edit5_Callback(hObject, eventdata, h)
tempscale = get(hObject,'String');
if iscell(tempscale)
    tempscale = tempscale{1};
end
h.tsc    = max(1, min(50, round(str2num(tempscale))));
set(hObject, 'String', sprintf('%d', h.tsc));
PlotFrame(h);
guidata(hObject, h);

function edit5_CreateFcn(hObject, eventdata, h)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- what should be processed --------------------------- %
function checkbox1_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.whichROIs(1) = wc;
guidata(hObject,h);

function checkbox2_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.whichROIs(2) = wc;
guidata(hObject,h);

function checkbox3_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(1,1)  = wc;
guidata(hObject,h);

function checkbox4_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(2,1)  = wc;
guidata(hObject,h);

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(3,1)  = wc;
guidata(hObject,h);

function checkbox6_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(4,1)  = wc;
guidata(hObject,h);

function checkbox7_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(1,2)  = wc;
guidata(hObject,h);


function checkbox8_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(2,2)  = wc;
guidata(hObject,h);

function checkbox9_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(3,2)  = wc;
guidata(hObject,h);

function checkbox10_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(4,2)  = wc;
guidata(hObject,h);

function checkbox11_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(1,3)  = wc;
guidata(hObject,h);

function checkbox12_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(2,3)  = wc;
guidata(hObject,h);

function checkbox13_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(3,3)  = wc;
guidata(hObject,h);

function checkbox14_Callback(hObject, eventdata, h)
wc = get(hObject,'Value');
h.svdmat(4,3)  = wc;
guidata(hObject,h);


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, h)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)


% --- Executes on button press in checkbox16.

% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16
