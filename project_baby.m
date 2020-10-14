function varargout = project_baby(varargin)
% PROJECT_BABY MATLAB code for project_baby.fig
%      PROJECT_BABY, by itself, creates a new PROJECT_BABY or raises the existing
%      singleton*.
%
%      H = PROJECT_BABY returns the handle to a new PROJECT_BABY or the handle to
%      the existing singleton*.
%
%      PROJECT_BABY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECT_BABY.M with the given input arguments.
%
%      PROJECT_BABY('Property','Value',...) creates a new PROJECT_BABY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before project_baby_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to project_baby_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help project_baby

% Last Modified by GUIDE v2.5 12-Dec-2018 00:43:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @project_baby_OpeningFcn, ...
                   'gui_OutputFcn',  @project_baby_OutputFcn, ...
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


% --- Executes just before project_baby is made visible.
function project_baby_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to project_baby (see VARARGIN)

% Choose default command line output for project_baby
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes project_baby wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = project_baby_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
% Importing voicebox module for audio processing


% [1] Getting feature vector for Class 1 (BabyDiscomfort)
path = fullfile('Baby Database/BabyDiscomfort/');
files = dir(strcat(path,'*.wav'));
class1 = cell(1,length(files));
for f=1:length(files)
        if (~isempty(strfind(files(f).name,'wav')))
            [data,fs] = audioread(fullfile(path,files(f).name));
            class1{f} = mean(melcepst(data));
        end
end

% [2] Getting feature vector for Class 2 (BabyHungry)
path = fullfile('Baby Database/BabyHungry/');
files = dir(strcat(path,'*.wav'));
class2 = cell(1,length(files));
for f=1:length(files)
        if (~isempty(strfind(files(f).name,'wav')))
            [data,fs] = audioread(fullfile(path,files(f).name));
            class2{f} = mean(melcepst(data));
        end
end

% [3] Reading input voice getting ready for classification
input_voice = strcat('test_samples/', get(handles.edit1, 'String'));
[y,fs] = audioread(input_voice);
sound(y,fs)
y = y(:,1);
dt = 1/fs;
t = 0:dt:(length(y)*dt)-dt;

axes(handles.axes1);
plot(t,y); xlabel('Seconds'); ylabel('Amplitude');

axes(handles.axes2);
plot(psd(spectrum.periodogram,y,'Fs',fs,'NFFT',length(y)));
c = mean(melcepst(y));

% [4] Getting our Training Set and labels
trainset = cell(1,length(class1)+length(class2));
labels = cell(1,length(class1)+length(class2));
for t=1:length(class1)
    trainset{t} = class1{t};
    labels{t} = 'Discomfort';
    idx = t;
end

for t=1:length(class2)
    trainset{idx+t} = class2{t};
    labels{idx+t} = 'Hungry';
end

% [5] Creating our KNN Classifier and fitting it to out data
L1_distance = [];
my_result = [];

distance =[];
for i = 1:length(trainset)
    L1_distance = [L1_distance ; (c - cell2mat(trainset(i)))];
end

for i=1:length(trainset)
    my_result = [my_result ; sum(L1_distance(i,:))];
end

c1 = abs(my_result(1:length(class1)));
c2 = abs(my_result((length(class1)+1:length(class2))));

sorted_my_result= sort(abs(my_result));
k_5 = sorted_my_result(1:5);

c1_count =0;
c2_count = 0;
for i=1:5
    if ismember(k_5(i),c1)
        c1_count = c1_count + 1;
    else
        c2_count = c2_count + 1;
    end
end

if c1_count > c2_count
    disp('Discomfort')
    set(handles.text5,'String','Discomfort');
else
    disp('Hungry')
    set(handles.text5,'String','Hungry');
end





function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% [3] Reading input voice getting ready for classification
input_voice = strcat('test_samples/', get(handles.edit1, 'String'));
[y,fs] = audioread(input_voice);
y = y(:,1);
c = mean(melcepst(y));


% [1] Getting feature vector for Class 1 (BabyDiscomfort)
path = fullfile('Baby Database/BabyDiscomfort/');
files = dir(strcat(path,'*.wav'));
class1 = cell(1,length(files));
for f=1:length(files)
        if (~isempty(strfind(files(f).name,'wav')))
            [data,fs] = audioread(fullfile(path,files(f).name));
            class1{f} = mean(melcepst(data));
        end
end

% [2] Getting feature vector for Class 2 (BabyHungry)
path = fullfile('Baby Database/BabyHungry/');
files = dir(strcat(path,'*.wav'));
class2 = cell(1,length(files));
for f=1:length(files)
        if (~isempty(strfind(files(f).name,'wav')))
            [data,fs] = audioread(fullfile(path,files(f).name));
            class2{f} = mean(melcepst(data));
        end
end

% [3] Getting our Training Set and labels
trainset = cell(1,length(class1)+length(class2));
labels = cell(1,length(class1)+length(class2));
for t=1:length(class1)
    trainset{t} = class1{t};
    labels{t} = 'Discomfort';
    idx = t;
end

for t=1:length(class2)
    trainset{idx+t} = class2{t};
    labels{idx+t} = 'Hungry';
end


% [4] Reading input voice & classify it
y_test = cell(1,length(trainset));
y_pred = cell(1,length(trainset));
path = fullfile('test_samples/');
files = dir(strcat(path,'*.wav'));
for f=1:length(files)
    if (~isempty(strfind(files(f).name,'wav')))
            [y,fs] = audioread(fullfile(path,files(f).name));
            c = mean(melcepst(y));
            if strfind(files(f).name, 'dc')
                y_test{f} =  0;
            else if strfind(files(f).name, 'hungry')
                y_test{f} = 1;
                end
            end
    end
    
    L1_distance = [];
    my_result = [];

    for i = 1:length(trainset)
        L1_distance = [L1_distance ; (c - cell2mat(trainset(i)))];
    end

    for i=1:length(trainset)
        my_result = [my_result ; sum(L1_distance(i,:))];
    end

    c1 = abs(my_result(1:length(class1)));
    c2 = abs(my_result((length(class1)+1:length(class2))));

    sorted_my_result= sort(abs(my_result));
    k_3 = sorted_my_result(1:3);

    c1_count =0;
    c2_count = 0;
    for i=1:3
        if ismember(k_3(i),c1)
            c1_count = c1_count + 1;
        else
            c2_count = c2_count + 1;
        end
    end

    if c1_count > c2_count
        disp(strcat('Discomfort', '--', files(f).name))
        y_pred{f} = 0;
    else
        disp(strcat('Hungry', '--', files(f).name))
        y_pred{f} = 1;
    end
 
end

figure
%subplot(2,2,1)
plotconfusion(y_test(1:80),y_pred(1:80))
%subplot(2,2,2)
figure
plotroc(y_test(1:80),y_pred(1:80))

x_c1 = cell(1,length(class1)) 
y_c1 = cell(1,length(class1)) 
x_c2 = cell(1,length(class2)) 
y_c2 = cell(1,length(class2))
for i=1:length(x_c1)
    x_c1{i} = class1{1,i}(3)
    y_c1{i} = class1{1,i}(5)
end
for i=1:length(x_c2)
    x_c2{i} = class2{1,i}(3)
    y_c2{i} = class2{1,i}(5)
end

figure
% Plot first class
scatter(cell2mat(x_c2),cell2mat(y_c2),'b')
% Plot second class.
hold on;
x1=scatter(cell2mat(x_c1),cell2mat(y_c1),'r')
scatter(c(3), c(5), 'green')
