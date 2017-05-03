function varargout = roisub(varargin)
% ROISUB MATLAB code for roisub.fig
%      ROISUB, by itself, creates a new ROISUB or raises the existing
%      singleton*.
%
%      H = ROISUB returns the handle to a new ROISUB or the handle to
%      the existing singleton*.
%
%      ROISUB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROISUB.M with the given input arguments.
%
%      ROISUB('Property','Value',...) creates a new ROISUB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roisub_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roisub_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%       
% 
%       HOW TO USE THIS GUI FOR CALCIUM IMAGING DATA WITH DORIC
%       ENDOMICROSCOPE:
% 
%       -PREPARATIONS to work with this program: one TIFF stack/data set
%       per folder; optional: text file named 'Framrate' containing only a 
%       number describing the framerate of the calcium imaging video (TIFF 
%       file)
% 
%       -load .tif data recorded by doric endomicroscope by pushing SELECT
%       FOLDER button, if you do not have a text file containing the
%       framerate, a dialog window will open asking to enter the framerate
%       IF, you already worked on the file before, the program will ask if
%       you want to load the last version
% 
%       -LOW IN, HIGH IN, LOW OUT, HIGH OUT sliders for changes brightness
%       and contrast to investigate images (RESET resets values to initial
%       values)
% 
%       -FRAMES SLIDER for sliding through TIFF images from frame to frame
%       -PLAY button to play the video from current frame in FRAME SLIDER,
%       STOP for stopping the video immediately
% 
%       -PREPROCESSING downsamples the file to 40 percent, kicks out faulty
%       frames and does flat field correction; additionally gives you a 
%       graph of 'mean change over time'
%       -if needed, ALIGN IMAGES allows to align the images to the first
%       frame (RESET if you want to reset the alignment)
%
%       -DELTA F/F calculates the change over time of the video by
%       substracting a mean frame from each frame and dividng by the mean
%       frame
% 
%       -MANUAL ROIs is used to define the ROIs manually by hand. Define 
%       a ROI by clicking around the wanted area. Corners can be adjusted 
%       afterwards by hovering over it until one sees a circle symbol. 
%       Simply click and drag to adjust the corner. If you place the cursor 
%       over the middle, the cursor should change into a cross which allows 
%       you to shift the selected area. If you are satisfied: double-click.
%       You can press the ROI button multiple times to define as many ROIs
%       as you want. In case you want to clear all ROIs and start over,
%       please use the CLEAR ALL ROIS button
%       -to remove a ROI or parts of it simply overlap with a new MANUAL ROI
%       -to define a lot of ROIs use the THRESHOLD slider to define a
%       threshold and then click AUTO ROIS to apply the threshold
%       -if you already defined ROIs or you want to use a ROI mask from
%       a previous data set press LOAD ROIS
%       -to show changes in brightness over time for your defined ROIs
%       use PLOT ROIS
% 
%       -SAVE VIDEO allows you to save the calcium imaging video as AVI
%       file in three different ways: Original, meaning you save the
%       original video with contrast settings, preprocessed and aligned (if
%       you did those changes), dF/F, saves the delta F/F video, and
%       Combined saves the preprocessed (and aligned) video overlayed with
%       the CI signal in red
%
% 
%       HOW TO ANALYZE THE BEHAVIORAL VIDEO:
%       -load video by pushing SELECT FOLDER button
%       IF you worked with the data before, you will be asked if you want
%       to load the last version
%       -crop the video to the area in which the animal is moving by pushing
%       the CROP & CONVERT TO HSV button by simply clicking and dragging the cursor
%       over the desired area. You can adjust the are by hovering over the
%       edges and then click and dragging it. If you are satisfied with the
%       defined area, right-click, press Copy Position, and double-click
%       onto the screen. In the dialog window simply press NEXT and FINISH.
%       The CROP VIDEO also automatically downsample and convert the 
%       cropped video to HSV color space
%       -select a color preset from the drop-down window (GREEN, PINK, 
%       YELLOW, BLUE) to use the defined threshold presets for the 
%       respective spot. Adjust the thresholds if needed to extract only 
%       the desired colored spot from the back of the animal by using the 
%       HUE, SATURATION, and VALUE THRESHOLD, each LOW or HIGH
%       -apply the color to all frames by pushing either SAVE AS ANTERIOR
%       or POSTERIOR SPOT
%       -scroll through all frames to check if spot is detected in all/most
%       of the frames; if not, set threshold again and then push the same
%       button again
%       -to show the movement of the animal push TRACE ANIMAL, it will
%       display movement of the anterior spot in the specified color and 
%       the movement of the posterior spot in the specified color. 
%       Additionally it will plot a figure for each ROI you defined, which 
%       shows a heat map corresponding to the activity during that frame
%       -BEHAVIORAL DETECTION allows you to define 8 different behaviors,
%       define shortkeys and give them names. Then it will play the video
%       from the specified frame from the frame slider and you will be able
%       to use your shortkeys to indicate your defined behavior of the
%       animal during that frame. After you push STOP or the video ends, you
%       will get a plot showing you the different behaviors over time. It
%       will save the plot under the name mouse_behavior. Furthermore it
%       will save the MAT file Behavior containing the number of behaviors
%       you defined (Amount), at which timepoints you defined them during 
%       the video (Events), the shortkeys you used (Shortkeys), the names 
%       you gave the behaviors (BehavNames), and at which timepoint the 
%       behaviors started and ended (barstart, barwidth)
%
%
%       SOURCES USED: threshold.m; SimpleColorDetectionByHue; Mohammed Ali
%       2016 Paper 'An integrative approach for analyzing hundreds of
%       neurons in task performing mice using wide-field calcium imaging.',
%       Image Alignment Toolbox (IAT).
%       
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roisub

% Last Modified by GUIDE v2.5 27-Feb-2017 13:57:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roisub_OpeningFcn, ...
                   'gui_OutputFcn',  @roisub_OutputFcn, ...
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


% --- Executes just before roisub is made visible.
function roisub_OpeningFcn(hObject, eventdata, handles, varargin)
clear global d;
clear global v;
global d
global v
global p
p.pn=[]; %path empty
%initializing variables needed before hand
v.pushed=0; %no video loaded
d.pushed=0; %no video loaded
d.bcount=0; %no. of rois selected equals zero
d.bcountd=0; %no. of dust specs selected equals zero
d.roisdefined=0; %no rois defined
d.play=0; %play button not pressed
v.play=0; %play button not pressed
v.pn=[]; %behavioral video path empty
v.behav=0; %behavior not tracked
d.pn=[]; %CI video path empty
d.thresh=0; %no ROI threshold
d.valid=0; %no ROI was selcted incorrectly
d.align=0; %signals whether images were aligned
p.pnpreset=[]; %no color preset imported
d.help=1; %help should be displayed
d.alignCI=[]; %alignment video is empty
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roisub (see VARARGIN)

% Choose default command line output for roisub
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes roisub wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = roisub_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------

%% DORIC CAMERA CODE


%%---------------------------Processing calcium imaging video

% --- Executes on button press in pushbutton5.                   LOAD DORIC
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p
%clears cache
%clears all global variables
clear global d;
%reinitializes global variables
global d
d.pushed=0; %no video loaded
d.bcount=0; %no ROI selected
d.bcountd=0; %no dust specs defined
d.roisdefined=0; %no ROI values
d.play=0; %play button not pressed
d.thresh=0; %no ROI threshold
d.valid=0; %no ROI was selcted incorrectly
d.dF=0; %no dF/F processing was done
d.load=0; %no ROIs were loaded
d.align=0; %no alignment
d.alignCI=[]; %alignment video is empty
d.pre=0; %no preprocessing
d.mip=0; %no maximum intensity projection
d.pn=[]; %no CI video path
d.ROIv=0; %no ROI values were loaded
d.ROImeans=[]; %no ROI values have been calculated
%colors for ROIs
d.colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};

%clear axes
cla(handles.axes1,'reset');
%resets frame slider
handles.slider7.Value=1;
%resets values of low in/out, high in/out to start values
handles.slider5.Value=0;
handles.slider15.Value=1;
handles.slider6.Value=0;
handles.slider16.Value=1;

if d.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end

% ms.UseParallel = true; %initializes parallel processing

%defining initial folder displayed in dialog window
if isempty(p.pn)==1
    [d.pn]=uigetdir('F:\jenni\Documents\PhD PROJECT\Calcium Imaging\doric camera\');
else
    [d.pn]=uigetdir(p.pn);
end

%clears old behavioral video if new calcium imaging video is loaded
if v.pushed==1 && strcmp(v.pn,d.pn)==0
    %clears cache
    %clears all global variables
    clear global v;
    %reinitializes global variables
    global v %#ok<*TLEV,*REDEF>
    v.pushed=0;
    v.play=0;
    v.pn=[];
    v.amount=[];
    v.shortkey=[];
    v.name=[];
    v.events=[];
    v.skdefined=0;
    v.behav=0;
    v.smallestArea=25;
    %clears axes
    cla(handles.axes2,'reset');
end

%extracts filename
filePattern = fullfile(d.pn, '*.tif'); % *.tiff for 2-P
Files = dir(filePattern);
if size(Files,1)==0
    msgbox('This folder does not contain a TIFF file!','ATTENTION');
    return;
end
d.fn = Files(1).name;

%defining dimensions of video
frames=size(imfinfo([d.pn '\' d.fn]),1);
x=imfinfo([d.pn '\' d.fn]);
Width=x(1).Width;
Height=x(1).Height;

%asking frame rate of the CI video
try
   d.framerate=csvread([d.pn '\Framerate.txt']);
catch ME
   %if there is no framerate text file open dialog box to ask for framerate
   if (strcmp(ME.identifier,'MATLAB:csvread:FileNotFound'))
        prompt = {'Enter framerate:'};
        dlg_title = 'Framerate';
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        d.framerate=str2num(cell2mat(answer));
   end
end 

%check whether video had been processed before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn))
    tf(k)=strcmp([d.fn(1:end-4) 'dFvid.mat'],files(k).name); %looking for dF/F processed video as .mat file
end
if sum(tf)>0 %if a file is found
    % Construct a questdlg with two options
    choice = questdlg('Would you like to load your last processed version?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    switch choice
        case 'YES'
            %function for loading last processed version
            loadlastCI;
            if sum(sum(d.mask))~=0 %if a ROI mask was loaded, plot the ROIs
                %plotting ROIs
                singleFrame=d.imd(:,:,round(handles.slider7.Value));
                axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                B=bwboundaries(d.mask); %boundaries of ROIs
                stat = regionprops(d.labeled,'Centroid'); %center of the ROIs
                d.b=cell(length(B),1);
                d.c=cell(length(B),1);
                colors=repmat(d.colors,1,ceil(length(B)/8)); %repeat color scheme as many times as there are ROIs
                for j = 1 : length(B)
                    d.b{j,1} = B{j};
                    d.c{j,1} = stat(d.ROIorder(j)).Centroid;
                    plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
                    text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
                end
                hold off;
            else
                singleFrame=d.imd(:,:,round(handles.slider7.Value));
                axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
            end
            %loading original calcium imaging video
            % Construct a questdlg with two options
            choice = questdlg('Would you also like to load the original calcium imaging video?', ...
                'Attention', ...
                'YES','NO','YES');
            % Handle response
            switch choice
                case 'YES'
                    if length(Files)==1
                        %function for loading TIFF stack
                        pn=d.pn;
                        fn=d.fn;
                        [imd,origCI,pre] = loadCIstack(pn,fn);
                        if pre==0
                            d.origCI=imd;
                        else
                            d.origCI=origCI;
                            uiwait(msgbox('The file was too big to load the unprocessed clacium imaging video! The file is now already downsampled!'));
                        end
                        d.pre=pre;
                    else
                        %function for loading single TIFFs together
                        pn=d.pn;
                        fn=d.fn;
                        [imd] = loadCIsingle(pn,fn,Files);
                        d.origCI=imd;
                    end
                    d.dF=1; %signals that dF/F was performed
                    load([d.pn '\' d.fn(1:end-4) 'vidalign']);
                    d.align=vidalign; %whether alignment was applied
                    d.pre=1; %presprocessing was performed

                    msgbox('Loading complete!');
                    
                    % Construct a questdlg with two options
                    choice = questdlg('Is this your first time working with this software? Do you need the help messages?', ...
                        'Attention', ...
                        'YES','NO','YES');
                    % Handle response
                    switch choice
                        case 'YES'
                            d.help=1;
                        case 'NO'
                            d.help=0;
                    end
                case 'NO'
                    d.dF=1; %signals that dF/F was performed
                    load([d.pn '\' d.fn(1:end-4) 'vidalign']);
                    d.align=vidalign; %whether alignment was applied
                    d.pre=1; %presprocessing was performed
                    d.origCI=[];
                    
                    % Construct a questdlg with two options
                    choice = questdlg('Is this your first time working with this software? Do you need the help messages?', ...
                        'Attention', ...
                        'YES','NO','YES');
                    % Handle response
                    switch choice
                        case 'YES'
                            d.help=1; %help dialogues
                        case 'NO'
                            d.help=0; %no help dialogues
                    end
            end
        case 'NO'
            if length(Files)==1
                %function for loading TIFF stack
                pn=d.pn;
                fn=d.fn;
                [imd,origCI,pre] = loadCIstack(pn,fn);
                d.origCI=origCI;
                d.pre=pre;
                d.imd=imd;

                d.pushed=1; %signals that file was selected
                d.roisdefined=0; %no rois defined
                d.b=[]; %matrix for drawing boundaries of ROIs empty
                d.c=[]; %matrix for drawing center of ROIs empty
                d.dF=0; %no dF/F performed
                d.load=0; %no ROIs loaded
                d.align=0; %no alignment
                d.mip=0; %no maximum intensity projection
                d.origCI=[]; %no original CI video

                %looking at first original picture
                axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
                % Construct a questdlg with two options
                choice = questdlg('Is this your first time working with this software? Do you need the help messages?', ...
                    'Attention', ...
                    'YES','NO','YES');
                % Handle response
                switch choice
                    case 'YES'
                        d.help=1;
                    case 'NO'
                        d.help=0;
                end
            else
                %function for loading single TIFFs together
                pn=d.pn;
                fn=d.fn;
                [imd] = loadCIsingle(pn,fn,Files);
                d.imd=imd;

                d.pushed=1; %signals that file was selected
                d.roisdefined=0; %no rois defined
                d.b=[]; %matrix for drawing boundaries of ROIs empty
                d.c=[]; %matrix for drawing center of ROIs empty
                d.dF=0; %no dF/F performed
                d.load=0; %no ROIs loaded
                d.align=0; %no alignment
                d.pre=0; %no preprocessing
                d.mip=0; %no maximum intensity projection
                d.origCI=[]; %no original CI video

                %looking at first original picture
                axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
                % Construct a questdlg with two options
                choice = questdlg('Is this your first time working with this software? Do you need the help messages?', ...
                    'Attention', ...
                    'YES','NO','YES');
                % Handle response
                switch choice
                    case 'YES'
                        d.help=1;
                    case 'NO'
                        d.help=0;
                end
            end
    end

elseif length(Files)==1
    %function for loading TIFF stack
    pn=d.pn;
    fn=d.fn;
    [imd,origCI,pre] = loadCIstack(pn,fn);
    d.origCI=origCI;
    d.pre=pre;
    d.imd=imd;
    
    d.pushed=1; %signals that file was selected
    d.roisdefined=0; %no rois defined
    d.b=[]; %matrix for drawing boundaries of ROIs empty
    d.c=[]; %matrix for drawing center of ROIs empty
    d.dF=0; %no dF/F performed
    d.load=0; %no ROIs loaded
    d.align=0; %no alignment
    d.mip=0; %no maximum intensity projection
    d.origCI=[]; %no original CI video
    
    %looking at first original picture
    if size(d.imd,3)>=4500
        singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
    end
    % Construct a questdlg with two options
    choice = questdlg('Is this your first time working with this software? Do you need the help messages?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    switch choice
        case 'YES'
            d.help=1;
        case 'NO'
            d.help=0;
    end
else
    %function for loading single TIFFs together
    pn=d.pn;
    fn=d.fn;
    [imd] = loadCIsingle(pn,fn,Files);
    d.imd=imd;
    
    d.pushed=1; %signals that file was selected
    d.roisdefined=0; %no rois defined
    d.b=[]; %matrix for drawing boundaries of ROIs empty
    d.c=[]; %matrix for drawing center of ROIs empty
    d.dF=0; %no dF/F performed
    d.load=0; %no ROIs loaded
    d.align=0; %no alignment
    d.pre=0; %no preprocessing
    d.mip=0; %no maximum intensity projection
    d.origCI=[]; %no original CI video
    
    %looking at first original picture
    axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
    % Construct a questdlg with two options
    choice = questdlg('Is this your first time working with this software? Do you need the help messages?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    switch choice
        case 'YES'
            d.help=1;
        case 'NO'
            d.help=0;
    end
end
p.pn=d.pn; %saving current file directory so it can be displayed next time you want to select a folder

titleLabel = ['Calcium imaging video: ' d.fn]; %filename as title
set(handles.text27, 'String', titleLabel);
%if you hover with the animal over the filename, you can see the path
handles.text27.TooltipString=d.pn;
textLabel = sprintf('%d / %d', 1,size(d.imd,3));
set(handles.text36, 'String', textLabel);
handles.slider7.Max=size(d.imd,3);

msgbox('Loading Completed.','Success');






% --- Executes on slider movement.                           CHANGES LOW IN
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider5.Value changes low in value
if d.pushed==4 || d.roisdefined==1 %if ROIs were defined
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1)
    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2);
    text(d.c{k,1}(1),d.c{k,1}(2),num2str(k));
    end
    hold off;
    d.pushed=4;
else
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); %shows image in axes1
end

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                          CHANGES LOW OUT
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider6.Value changes low out value
if d.pushed==4 || d.roisdefined==1 %if ROIs were defined
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1)
    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2);
    text(d.c{k,1}(1),d.c{k,1}(2),num2str(k));
    end
    hold off;
    d.pushed=4;
else
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); %shows image in axes1
end

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                          CHANGES HIGH IN
function slider15_Callback(hObject, eventdata, handles)
% hObject    handle to slider15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider15.Value changes high in value
if d.pushed==4 || d.roisdefined==1 %if ROIs were defined
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1)
    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2);
    text(d.c{k,1}(1),d.c{k,1}(2),num2str(k));
    end
    hold off;
    d.pushed=4;
else
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); %shows image in axes1
end

% --- Executes during object creation, after setting all properties.
function slider15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                         CHANGES HIGH OUT
function slider16_Callback(hObject, eventdata, handles)
% hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider16.Value changes high out value
if d.pushed==4 || d.roisdefined==1 %if ROIs were defined
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1)
    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2);
    text(d.c{k,1}(1),d.c{k,1}(2),num2str(k));
    end
    hold off;
    d.pushed=4;
else
    d.pushed=1;
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); %shows image in axes1
end

% --- Executes during object creation, after setting all properties.
function slider16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in pushbutton22.                       RESET
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%resets values of low in/out, high in/out to start values
handles.slider5.Value=0;
handles.slider15.Value=1;
handles.slider6.Value=0;
handles.slider16.Value=1;
singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1); imshow(singleFrame); %shows image in axes1






% --- Executes on button press in pushbutton38.                 REMOVE DUST
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
if d.pre==1
    msgbox('You have to remove dust before preprocessing!','ATTENTION');
    return;
end

%display instructions only if the button was pressed for the first time or
%a mistake was made and you want the help
if d.bcountd==0 || d.help==1
    uiwait(msgbox('Please define the region of dust by clicking around the area. The corners can be moved afterwards as well as the whole selected area. When satisfied with the selection please double-click!','Attention','modal'));
end

%display current image to select ROI
singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1);

%function for removing dust
bcountd=d.bcountd;
imd=d.imd;
[imd,bcountd] = removeDust(singleFrame,bcountd,imd);
d.bcountd=bcountd;
d.imd=imd;

%showing resulting frame
singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1);imshow(singleFrame);
msgbox('Removal complete!','Success');


% --- Executes on button press in pushbutton23.               PREPROCESSING
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
if d.pre==1
    msgbox('You already did preprocessing!','ATTENTION');
    return;
end

%Downsampling
h=msgbox('Downsampling... please wait!');
imd=imresize(d.imd,0.4);
close(h);

%function for eliminating faulty frames
[imd] = faultyFrames(imd);

d.origCI=imresize(imd,0.805); %keeping this file stored as original video but resized since original video is bigger than the downsampled video

%function for flatfield correction
[imdd] = flatFieldCorrection(imd);
d.imd=imdd;

%showing resulting frame
singleFrame=d.imd(:,:,round(handles.slider7.Value));
axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);

d.pre=1; %preprocessing was done
%plotting mean change along the video
meanChange=diff(mean(mean(d.imd,1),2));
h=figure;plot(squeeze(meanChange));title('Mean brightness over frames');xlabel('Number of frames');ylabel('Brightness in uint16');
name=('Mean Change');
path=[d.pn '/',name,'.png'];
path=regexprep(path,'\','/');
print(h,'-dpng','-r100',path); %-depsc for vector graphic
msgbox('Preprocessing done!','Success');


% --- Executes on button press in pushbutton9.                ALIGNS IMAGES
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
if d.pre==0
    msgbox('Please do preprocessing before aligning!','ATTENTION');
    return;
end
% adapted from source: http://de.mathworks.com/help/vision/examples/video-stabilization-using-point-feature-matching.html
if d.dF==1
     msgbox('Please align before calculating dF/F.','Attention');
     return
end

%saves original in different variable
d.alignCI=d.imd;

%define ROI that is used for transformation
axes(handles.axes1);
a=imcrop;
cropped=clipboard('pastespecial');
cropCoordinates=str2num(cell2mat(cropped.A_pastespecial));
%checks if cropping coordinates are valid
if isempty(cropCoordinates)==1 || cropCoordinates(1,3)==0 || cropCoordinates(1,4)==0
    msgbox('Please select valid cropping area! Check the instructions again.','ERROR');
    return;
end
cc=floor(cropCoordinates);
%function for extracting and enhancing alignment ROI
imd=d.imd;
[ROI] = alignmentROI(cc,imd);

if handles.radiobutton1.Value==1
    %function for using subpixel registration algorithm
    [imdC] = subpixel(ROI);
    d.imd=imdC;
    %showing resulting frame
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
else
    %function for using LucasKanade algorithm
    imd=d.imd;
    [imdC,Bvector] = lucasKanade(ROI,imd);
    d.Bvector=Bvector;
    d.imd=imdC;
    %showing resulting frame
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
end


d.align=1; %signals that images were aligned
msgbox('Aligning Completed.','Success');


% --- Executes on button press in pushbutton28.            RESETS ALIGNMENT
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global d
if isempty(d.alignCI)==1
    msgbox('You did not align anything.')
    return;
end
d.imd=d.alignCI;
d.align=0; %signals that image alignment was reset
d.dF=0; %deltaF/F claculation is reset as well
%showing resulting frame
singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
msgbox('Alignment reset!');


% --- Executes on button press in pushbutton25.                   DELTA F/F
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d

if d.pre==0
    msgbox('Please do preprocessing before proceeding!','ATTENTION');
    return;
end

if d.dF==1
    msgbox('You already did delta F/F calculation!','ATTENTION');
    return;
end

%it is assumed that if you do delta F/F calculation you accepted the
%alignment, if any was done, thus adjustment of the size of the original CI
%video
if d.align==1
    d.origCI=d.origCI(round(abs(d.Bvector(1,1))):round(size(d.origCI,1)-abs(d.Bvector(1,1))),round(abs(d.Bvector(2,1))):round(size(d.origCI,2)-abs(d.Bvector(2,1))),:);  %cut middle of image
end

%function for calculating deltaF/F
imd=d.imd;
pn=d.pn;
fn=d.fn;
align=d.align;
[imddFF] = deltaFF(imd,pn,fn,align);
d.imd=imddFF;

%variable initialization for ROI processing
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.labeled = zeros(size(d.imd,1),size(d.imd,2));
d.ROIs=[];

%showing resulting frame
singleFrame=d.imd(:,:,round(handles.slider7.Value));
axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
d.dF=1; %dF/F was performed

%finding cells with maximum intensity projection and standard deviation
MaxIntensProj = max(d.imd, [], 3);
stdIm = std(d.imd,0,3);
d.mip=MaxIntensProj./stdIm;
if handles.radiobutton2.Value==1
    h=figure;imagesc(d.mip);title('Maximum Intensity Projection');
else
    h=figure;imagesc(d.mip);title('Maximum Intensity Projection');
end
name=('MIP');
path=[d.pn '/',name,'.png'];
path=regexprep(path,'\','/');
print(h,'-dpng','-r100',path); %-depsc for vector graphic
msgbox('Calculation done!','Success');







% --- Executes on button press in pushbutton3.                         ROIs
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
if d.dF==0
    msgbox('Please perform Delta F/F calculation before selection ROIs!','ATTENTION');
    return;
end

d.ROIv=0; %resetting ROIvalues loaded, since you are changing the ROI mask now

%display instructions only if the button was pressed for the first time or
%a mistake was made and you want the help
if (d.bcount==0 || d.valid==1) && d.help==1
    d.valid=0;
    uiwait(msgbox('Please define the region of interest (ROI) by clicking around the area. The corners can be moved afterwards as well as the whole selected area. When satisfied with the selection please double-click!','Attention','modal'));
end

%displaying picture with previously marked ROIs
axes(handles.axes1);
if d.bcount>0
    colors=repmat(d.colors,1,ceil(max(d.ROIorder)/8)); %selecting colors for ROIs
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable'); %determining the order of the ROIs
    singleFrame=d.mip./max(max(d.mip)); %getting picture into the value range from 0 to 1 for roipoly
    axes(handles.axes1); imshow(singleFrame);hold on;
    stat = regionprops(d.labeled,'Centroid'); %finding center of ROIs
    for k=1:size(d.b,1)
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end %drawing ROIs
    hold off;
    f=getframe(handles.axes1); %getting the MIP with ROI mask as one picture
    singleFrame=f.cdata;
elseif d.load==1
    colors=repmat(d.colors,1,ceil(max(d.ROIorder)/8)); %selecting colors for ROIs
    singleFrame=d.mip./max(max(d.mip)); %getting picture into the value range from 0 to 1 for roipoly
    axes(handles.axes1); imshow(singleFrame);hold on;
    stat = regionprops(d.labeled,'Centroid'); %finding center of ROIs
    for k=1:size(d.b,1)
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end %drawing ROIs
    hold off;
    f=getframe(handles.axes1); %getting the MIP with ROI mask as one picture
    singleFrame=f.cdata;
elseif d.bcount==0
    singleFrame=d.mip./max(max(d.mip)); %getting picture into the value range from 0 to 1 for roipoly
end

%manual ROI selection
ROI = roipoly(singleFrame);    %uint8 for CI_win_S1HL_02/20151118 & DORIC; int16 for CI_S1Hl_02
if d.bcount>0 || d.load==1 %resizing ROI since the figure from getframe is not the same resolution
    B=imresize(ROI, [size(d.mip,1) size(d.mip,2)]);
    ROI=B;
end
%check if ROI was selected correctly
if numel(find(ROI))==0
    singleFrame=d.mip;
    if d.dF==1 || d.pre==1
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    else
        axes(handles.axes1); imshow(singleFrame); hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for k=1:size(d.b,1)
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',d.colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end
    hold off;
    d.valid=1;
    msgbox('Please select valid ROI! Check the instructions again.','ERROR');
    return;
end
%count times button is pressed
d.bcount=d.bcount+1;

if d.load==1 %if a ROI mask was loaded
    d.labeled = d.labeled+(ROI*(max(max(d.labeled))+1)); %labeling of ROIs
    d.mask = d.mask+ROI; %old ROI mask + new ROI mask
    %checking if ROIs are superimposed on each other
    if numel(find(d.mask>1))>0
        choice = questdlg('Would you like to remove this ROI?', ...
        'Attention', ...
        'YES','NO','YES');
        % Handle response
        switch choice
            case 'YES'
                d.mask=d.mask-(2*ROI); %removing 2*ROI since overlaps = 2
                d.mask(d.mask<0)=0; %the romved ROI is -1 at some places, to remove that, everything below 0 = 0
                d.labeled=bwlabel(d.mask);
                %plotting ROIs
                singleFrame=d.imd(:,:,round(handles.slider7.Value));
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                B=bwboundaries(d.mask); %boundaries of ROIs
                stat = regionprops(d.labeled,'Centroid');
                %check whether ROIs are touching
                if length(stat)>length(B)
                    d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
                    d.mask = d.mask-ROI;
                    singleFrame=d.mip;
                    if d.dF==1 || d.pre==1
                        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                    else
                        axes(handles.axes1); imshow(singleFrame); hold on;
                    end
                    stat = regionprops(d.labeled,'Centroid');
                    for k=1:size(d.b,1)
                        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',d.colors{1,d.ROIorder(k)});
                        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                    end
                    hold off;
                    msgbox('Please do not let ROIs touch!','ERROR');
                    return;
                end
                d.b=cell(length(B),1);
                d.c=cell(length(B),1);
                d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
                colors=repmat(d.colors,1,ceil(max(d.ROIorder)/8));
                for j = 1 : max(d.ROIorder)
                    d.b{j,1} = B{j};
                    d.c{j,1} = stat(d.ROIorder(j)).Centroid;
                    plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
                    text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
                end
                hold off;
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined

                %saving ROI mask
                % Construct a questdlg with two options
                choice = questdlg('Would you like to save this ROI mask?', ...
                    'Attention', ...
                    'YES','NO','YES');
                % Handle response
                switch choice
                    case 'YES'
                        %saving ROI mask
                        filename=[d.pn '\' d.fn(1:end-4) 'ROIs'];
                        ROImask=d.mask;
                        ROIorder=d.ROIorder;
                        ROIlabels=d.labeled;
                        save(filename, 'ROImask','ROIorder','ROIlabels');
                    case 'NO'
                        return;
                end
                return;
            case 'NO'
                %resetting ROI mask to the one before
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1)); %substracting current ROI such that old ROI labels are the result
                d.labeled(d.labeled<0)=0;
                d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
                stat = regionprops(d.labeled,'Centroid');
                for k=1:size(d.b,1)
                    d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',d.colors{1,d.ROIorder(k)});
                    text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                end %drawing ROIs
                hold off;
                msgbox('Please do not superimpose ROIs!','ERROR');
                d.mask = d.mask-ROI; %substracting current ROI such that old ROI mask is the result
                return;
        end
    else
        d.mask(d.mask>0)=1;
    end    

    %plotting ROIs
    singleFrame=d.mip;
    if d.dF==1 || d.pre==1
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    else
        axes(handles.axes1); imshow(singleFrame); hold on;
    end
    B=bwboundaries(d.mask); %boundaries of ROIs
    stat = regionprops(d.labeled,'Centroid');
    %check whether ROIs are touching
    if length(stat)>length(B)
        d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
        d.mask = d.mask-ROI;
        singleFrame=d.mip;
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for k=1:size(d.b,1)
            d.c{k,1} = stat(d.ROIorder(k)).Centroid;
            plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',d.colors{1,d.ROIorder(k)});
            text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
        end %drwaing ROIs
        hold off;
        msgbox('Please do not let ROIs touch!','ERROR');
        return;
    end
    d.b=cell(length(B),1);
    d.c=cell(length(B),1);
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    colors=repmat(d.colors,1,ceil((max(max(d.labeled))+1)/8));
    for j = 1 : length(B)
        d.b{j,1} = B{j};
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end %drawing ROIs
    hold off;
    d.pushed=4; %signals that ROIs were selected
    d.roisdefined=1; %signals that ROIs were defined

    %saving ROI mask
    filename=[d.pn '\' d.fn(1:end-4) 'ROIs'];
    ROImask=d.mask;
    ROIorder=d.ROIorder;
    ROIlabels=d.labeled;
    save(filename, 'ROImask','ROIorder','ROIlabels');
else
    d.labeled = d.labeled+ROI*(max(max(d.labeled))+1); %labeling of ROIs
    d.mask = d.mask+ROI; %old ROI mask + new ROI mask
    %checking if ROIs are superimposed on each other
    if numel(find(d.mask>1))>0
        choice = questdlg('Would you like to remove this ROI?', ...
        'Attention', ...
        'YES','NO','YES');
        % Handle response
        switch choice
            case 'YES'
                d.mask=d.mask-(2*ROI);%removing 2*ROI since overlaps = 2
                d.mask(d.mask<0)=0; %the romved ROI is -1 at some places, to remove that, everything below 0 = 0
                d.labeled=bwlabel(d.mask);
                %plotting ROIs
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                B=bwboundaries(d.mask); %boundaries of ROIs
                stat = regionprops(d.labeled,'Centroid');
                %check whether ROIs are touching
                if length(stat)>length(B)
                    d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
                    d.mask = d.mask-ROI;
                    singleFrame=d.mip;
                    if d.dF==1 || d.pre==1
                        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                    else
                        axes(handles.axes1); imshow(singleFrame); hold on;
                    end
                    stat = regionprops(d.labeled,'Centroid');
                    for k=1:size(d.b,1)
                        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',d.colors{1,d.ROIorder(k)});
                        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                    end %drawing ROIs
                    hold off;
                    msgbox('Please do not let ROIs touch!','ERROR');
                    return;
                end
                d.b=cell(length(B),1);
                d.c=cell(length(B),1);
                d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
                colors=repmat(d.colors,1,ceil(max(d.ROIorder)/8));
                for j = 1 : max(d.ROIorder)
                    d.b{j,1} = B{j};
                    d.c{j,1} = stat(d.ROIorder(j)).Centroid;
                    plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
                    text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
                end %drawing ROIs
                hold off;
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined

                %saving ROI mask & ROI order
                % Construct a questdlg with two options
                choice = questdlg('Would you like to save this ROI mask?', ...
                    'Attention', ...
                    'YES','NO','YES');
                % Handle response
                switch choice
                    case 'YES'
                        %saving ROI mask
                        filename=[d.pn '\' d.fn(1:end-4) 'ROIs'];
                        ROImask=d.mask;
                        ROIorder=d.ROIorder;
                        ROIlabels=d.labeled;
                        save(filename, 'ROImask','ROIorder','ROIlabels');
                    case 'NO'
                        return;
                end
                return;
            case 'NO'
                d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
                d.mask = d.mask-ROI;
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                stat = regionprops(d.labeled,'Centroid');
                for k=1:size(d.b,1)
                    d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',d.colors{1,d.ROIorder(k)});
                    text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                end %drawing ROIs
                hold off;
                msgbox('Please do not superimpose ROIs!','ERROR');
                return;
        end
    else
        d.mask(d.mask>0)=1;
    end
    

    %plotting ROIs
    singleFrame=d.mip;
    if d.dF==1 || d.pre==1
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    else
        axes(handles.axes1); imshow(singleFrame); hold on;
    end
    B=bwboundaries(d.mask); %boundaries of ROIs
    stat = regionprops(d.labeled,'Centroid');
    %check whether ROIs are touching
    if length(stat)>length(B)
        d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
        d.mask = d.mask-ROI;
        singleFrame=d.mip;
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for k=1:size(d.b,1)
            d.c{k,1} = stat(d.ROIorder(k)).Centroid;
            plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',d.colors{1,d.ROIorder(k)});
            text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
        end %drawing ROIs
        hold off;
        msgbox('Please do not let ROIs touch!','ERROR');
        return;
    end
    d.b=cell(length(B),1);
    d.c=cell(length(B),1);
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    colors=repmat(d.colors,1,ceil((max(max(d.labeled))+1)/8));
    for j = 1 : length(B)
        d.b{j,1} = B{j};
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end %drawing ROIs
    hold off;
    d.pushed=4; %signals that ROIs were selected
    d.roisdefined=1; %signals that ROIs were defined

    %saving ROI mask
    filename=[d.pn '\' d.fn(1:end-4) 'ROIs'];
    ROImask=d.mask;
    ROIorder=d.ROIorder;
    ROIlabels=d.labeled;
    save(filename, 'ROImask','ROIorder','ROIlabels');
end




% --- Executes on button press in pushbutton16.              CLEAR ALL ROIS
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global d
global v
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
%resets all varibles needed for selecting ROIs
d.bcount=0; %signals ROI button was not pressed
d.pushed=1; %signals video was loaded
%re-initialization of variables for ROI calculations
d.ROIs=[];
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.labeled = zeros(size(d.imd,1),size(d.imd,2));
d.b=[];
d.c=[];
d.ROIorder=[];
d.roisdefined=0; %signals no ROIs were selected
d.load=0; %signals that no ROI mask was loaded

singleFrame=d.mip;
if d.dF==1
    axes(handles.axes1);
    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
else
    axes(handles.axes1); imshow(singleFrame);
end
msgbox('ROIs cleared!','Success');





% --- Executes on button press in pushbutton27.          LOAD EXISTING ROIs
function pushbutton27_Callback(~, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global d
%resets all varibles needed for selecting ROIs
d.bcount=0; %signals ROI button was not pressed
d.pushed=1; %signals video was loaded
%re-initialization of variables for ROI calculations
d.ROIs=[];
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.labeled = zeros(size(d.imd,1),size(d.imd,2));
d.b=[];
d.c=[];
d.ROIorder=[];
d.roisdefined=0; %signals no ROIs were selected
d.load=0; %signals that no ROI mask was loaded
d.ROIv=0; %no ROI values loaded

if d.pre==0
    msgbox('Please do preprocessing & Delta F/F calculation before proceeding!','ATTENTION');
    return;
elseif d.dF==0
    msgbox('Please do Delta F/F calculation before proceeding!','ATTENTION');
    return;
end

uiwait(msgbox('Select a "filename"ROIs.mat file!'));

%extracts filename
filepath=[d.pn '\'];
[fn,pn,~]=uigetfile([filepath '*.mat']);
%load the saved ROI mask, and order of labels
load([pn fn]);
d.mask=ROImask;
d.ROIorder=ROIorder;
d.labeled=ROIlabels;
%plotting ROIs
singleFrame=d.imd(:,:,round(handles.slider7.Value));
if d.dF==1 || d.pre==1
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
else
    axes(handles.axes1); imshow(singleFrame); hold on;
end
B=bwboundaries(d.mask); %boundaries of ROIs
stat = regionprops(d.labeled,'Centroid');
d.b=cell(length(B),1);
d.c=cell(length(B),1);
colors=repmat(d.colors,1,ceil(length(B)/8));
for j = 1 : length(B)
    d.b{j,1} = B{j};
    d.c{j,1} = stat(d.ROIorder(j)).Centroid;
    plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
    text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
end %drawing ROIs
hold off;
d.pushed=4; %signals that ROIs were selected
d.roisdefined=1; %signals that ROIs were defined
d.load=1; %signals that ROIs were manually loaded
msgbox('Loading complete!');





% --- Executes on slider movement.                          THRESHOLD LEVEL
function slider21_Callback(hObject, eventdata, handles)
% hObject    handle to slider21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
MIP=d.mip/max(max(d.mip));
MIP(MIP<handles.slider21.Value)=0;
figure(2),imshow(MIP);


% th_MIP=im2bw(MIP, handles.slider21.Value);
% smallestAcceptableArea = 25;
% structuringElement = strel('disk', 2);
% th_clean_MIP = imclose(bwareaopen(th_MIP,smallestAcceptableArea),structuringElement);
% D = bwdist(~th_clean_MIP);
% figure(2);
% imshow(D,[],'InitialMagnification','fit');
% title('Distance transform of ~bw');
% D = -D;
% D(~th_clean_MIP) = -Inf;
% L = watershed(D);
% rgb = label2rgb(L,'jet',[.5 .5 .5]);
% figure(3);
% imshow(rgb,'InitialMagnification','fit');
% title('Watershed transform of D');

% --- Executes during object creation, after setting all properties.
function slider21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton34.                   AUTO ROIs
function pushbutton34_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d

h=msgbox('Please wait...');
%reshaping to two dimensional array: pixel x time
F=d.imd;
F1=reshape(F,size(F,1)*size(F,2),size(F,3));

%PCA
F2=pca(F1');
%visualizing result from PCA
F2r=reshape(F2,size(F,1),size(F,2),size(F,3)-1); %reshaping into pictures over time: width x heigth x time
try
    close(h);
catch
end

%ICA
%selecting only first 150 dimensions
prompt = {'Enter approximate number of desired cells:'};
dlg_title = 'Cell number';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
dim=str2num(cell2mat(answer));
h=msgbox('Please wait...');
F2s=F2(:,1:dim);
[Zica, W, T, mu] = fastICA(F2s',dim); %alternative: [Zica, W, T, mu] = kICA(F2s,150);
ICAmatrix=reshape(Zica',size(F,1),size(F,2),dim);
try
    close(h);
catch
end
%extracting ROIs
ICAmatrixfilt=imgaussfilt(ICAmatrix,1.5); %or sigma=5
ROIsbw=zeros(size(F,1),size(F,2),dim);
smallestAcceptableArea=30;

singleFrame=d.mip;
if d.dF==1 || d.pre==1
    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
else
    axes(handles.axes1); imshow(singleFrame); hold on;
end

for k=1:size(ICAmatrixfilt,3)
    %converting to numbers between 0 and 1
    ROIs=ICAmatrixfilt(:,:,k)+abs(min(min(ICAmatrixfilt(:,:,k))));
    ROIs=ROIs./max(max(ROIs));
    ROIsBW=bwareaopen(im2bw(ROIs,0.8),smallestAcceptableArea);
    ROIsbw(:,:,k)=bwlabel(ROIsBW);
    if sum(sum(ROIsBW))>1000
        ROIs=imcomplement(ROIs);
        ROIsBW=bwareaopen(im2bw(ROIs,0.8),smallestAcceptableArea);
        ROIsbw(:,:,k)=bwlabel(ROIsBW);
        B = bwboundaries(ROIsbw(:,:,k));
        if sum(sum(ROIsBW))>1000 || length(B)>1
            ROIsbw(:,:,k)=zeros(size(F,1),size(F,2),1); %deleting huge ROIs or ROIs with multiple cells in one picture
        end
    end   
end

%deleting non-round objects
for j=1:size(ROIsbw,3)
    stats = regionprops(ROIsbw(:,:,j),'Area','Centroid');
    B = bwboundaries(ROIsbw(:,:,j),'noholes');
    threshold = 0.5;
    if isempty(B)==0
        % obtain (X,Y) boundary coordinates
        boundary = B{1,1};
        % compute a simple estimate of the object's perimeter
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2)));
        % obtain the area calculation corresponding to label 'k'
        area = stats(1).Area;
        % compute the roundness metric
        metric= 4*pi*area/perimeter^2;
        if metric<threshold;
            ROIsbw(:,:,j)=zeros(size(F,1),size(F,2),1);
        end
    end
end

%deleting the double assignments
for m=1:size(ROIsbw,3)
    sumM=sum(sum(ROIsbw(:,:,m)));
    for n=1:size(ROIsbw,3)
        if m~=n
            sumN=sum(sum(ROIsbw(:,:,n)));
            ROIboth=ROIsbw(:,:,m)+ROIsbw(:,:,n);
            overlay=numel(find(ROIboth==2));
            if overlay>0
                percMover=overlay/sumM*100;
                percNover=overlay/sumN*100;
                if percMover>=70 || percNover>=70 %if overlap of ROIs is greater than 70% it is interpreted as one ROI
                    ROIboth(ROIboth>1)=1;
                    ROIsbw(:,:,m)=ROIboth;
                    ROIsbw(:,:,n)=zeros(size(F,1),size(F,2),1);
                end
            end
        end
    end
end

%determining indices where there are ROIs
c=0;
for j=1:size(ROIsbw,3)
    if sum(sum(ROIsbw(:,:,j)))>0
        c=c+1;
        ROIindices(c,1)=j;
    end
end
ROIsbw=ROIsbw(:,:,ROIindices);

%plotting ROIs
d.B=[];
for k=1:size(ROIsbw,3)
    if sum(sum(ROIsbw(:,:,k)))>0
        d.B(k,1)=bwboundaries(ROIsbw(:,:,k)); %boundaries of ROIs
        stat = regionprops(ROIsbw(:,:,k),'Centroid');
        d.centroid(k,:)=stat.Centroid;
        colors=repmat(d.colors,1,ceil(dim/8));
        %drawing ROIs
        plot(d.B{k,1}(:,2),d.B{k,1}(:,1),'linewidth',2,'Color',colors{1,k});
        text(d.centroid(k,1),d.centroid(k,2),num2str(k));
    end
end
hold off;
d.pushed=4; %signals that ROIs were selected
d.roisdefined=1; %signals that ROIs were defined
d.auto=1; %signlas that automated ROI detection was used
% %saving ROI mask
% filename=[d.pn '\' d.fn(1:end-4) 'ROIs'];
% ROImask=d.mask;
% ROIorder=d.ROIorder;
% ROIlabels=d.labeled;
% save(filename, 'ROImask','ROIorder','ROIlabels');




% --- Executes on button press in pushbutton14.             PLOT ROI VALUES
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
%check whether ROIs were selected
if d.roisdefined==0
    msgbox('Please label ROIs first!','ERROR');
    return;
end
%check whether dF/F was calculated
if d.dF==0
    msgbox('Please calculate Delta F/F first!','ERROR');
    return;
end

%slightly different colors for behavior bars, such that calcium imaging
%traces can still be seen
colorsb={[0    0.4    0.7],...
    [0.8    0.3    0.09],...
    [0.9    0.6    0.1],...
    [0.4    0.1    0.5],...
    [0.4    0.6    0.1],...
    [0.3    0.7    0.9],...
    [0.6    0.07   0.1],...
    [0.6    0.9    1]};

%checking whether ROI values had been saved before and no ROI was added
if d.ROIv==0
    %labeling ROIs for every frame of the video
    n=size(d.imd,3);
    numROIs=max(d.ROIorder); %number of ROIs
    d.ROIs=cell(size(d.imd,3),numROIs);
    ROIs=zeros(size(d.imd,1),size(d.imd,2));
    h=waitbar(0,'Labeling ROIs');
    for j=1:n
        for i=1:numROIs
            m = find(d.labeled==i);
            ROIs(m)=1;
            % You can only multiply integers if they are of the same type.
            ROIsc = cast(ROIs, class(d.imd(:,:,1)));
            imdrem= ROIsc .* d.imd(:,:,j);
            d.ROIs{j,i}=imdrem(m);
        end
        waitbar(j/n,h);
    end
    close(h);
    %saving ROI values
    filename=[d.pn '\' d.fn(1:end-4) 'ROIvalues'];
    ROIvalues=d.ROIs;
    save(filename, 'ROIvalues');
    d.ROIv=1;
end

%filter for filtering traces
[b,a]=butter(1,0.01*(d.framerate/2),'high');

colors=repmat(d.colors,1,ceil(size(d.ROIs,2)/8)); %colors for traces

%function for calculating ROI fluorescence values
imd=d.imd;
mask=d.mask;
ROIs=d.ROIs;
[ROImeans] = ROIFvalues(a,b,imd,mask,ROIs);
d.ROImeans=ROImeans;

%plotting ROI values
%variable initialization
NoofSpikes=zeros(size(d.ROIs,2),1);
spikes=cell(1,size(d.ROIs,2));
ts=cell(1,size(d.ROIs,2));
amp=cell(1,size(d.ROIs,2));
%initializing that only 8 subplots will be in one figure
onesub=(1:8);
anysub=repmat(onesub,1,ceil(size(d.ROIs,2)/8));
check=(9:8:200);
check2=(8:8:200);

figure('color','w');
for j=1:size(d.ROIs,2)
    if ismember(j,check)==1 %if ROI number is 9, 18, 27... new figure is initialized, this way there are only 8 ROIs per figure
        figure('color','w');
    end
    subaxis(8,1,anysub(j),'SpacingVert',.01,'ML',.1,'MR',.1); %using subaxis for tight layout of traces
    plot(d.ROImeans(:,j),'Color',colors{1,j}),hold on;
    axlim=get(gca,'YLim');
    ylim([min(d.ROImeans(:,j)) 2*round((axlim(2)+1)/2)]); %y-axis limits: from minimum value of the current ROI to round to next even number of current axis maximum value
    if v.behav==1 %drawing bars signalling the various defined behaviors, if behaviors have been defined
        axlim=get(gca,'YLim'); %limits of y-axis
        for l=1:v.amount
            for m=1:length(v.barstart.(char(v.name{1,l})))
            rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),axlim(1),v.barwidth.(char(v.name{1,l}))(m),axlim(2)*2],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
            end
        end
        plot(d.ROImeans(:,j),'Color',colors{1,j}),hold on;
    end
    strings=sprintf('ROI No.%d',j);
    %title('ROI values in percent');
    if ismember(j,check2)==1 || j==size(d.ROIs,2) %writing x-axis label only for last plot in the figure
        xlabel('Time in seconds');
        %changing tick labels from frames to seconds by dividing by framerate
        tlabel=get(gca,'XTickLabel');
        for k=1:length(tlabel)
            tlabel{k,1}=str2num(tlabel{k,1});
        end
        tlabel=cell2mat(tlabel);
        tlabel=tlabel./d.framerate;
        set(gca,'XTickLabel',tlabel);
    else
        set(gca,'XTickLabel',[]);
    end
    ylabel('%');
    legend(strings,'Location','eastoutside');
    set(gca, 'box', 'off');
    hold on;
    [y,x]=findpeaks(d.ROImeans(:,j),'MinPeakHeight',4*median(abs(d.ROImeans(:,j))/0.6745)); %adapted quiroga spike detection formula to find maxima=spikes in traces
    spikes{1,j}=x; %counting number of spikes per ROI
    ts{1,j}=x/d.framerate; %timestamps of spikes
    amp{1,j}=y; %amplitude of spike
    if isempty(x)==0
        plot(x,max(d.ROImeans(:,j))+0.5,'k.');
    else
        spikes{1,j}=1;
    end
    %calculating total number of spikes per ROI
    NoofSpikes(j,1)=length(x);
end
hold off;
%calculating firing frequency
Frequency=round(NoofSpikes./(size(d.imd,3)/d.framerate),2);
%calculating highest amplitude change
Amplitude=round(reshape(max(d.ROImeans),size(d.ROImeans,2),1),2);

%plotting raster plot
b=zeros(size(d.ROImeans,1),1);
fig=figure;
subplot(2,1,1);
if v.behav==1 %drawing bars signalling the various defined behaviors, if behaviors have been defined
    for l=1:v.amount
        for m=1:length(v.barstart.(char(v.name{1,l})))
        rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),0,v.barwidth.(char(v.name{1,l}))(m),size(d.ROImeans,2)],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
        end
    end
end
for j=1:size(d.ROImeans,2)
    plot(spikes{1,j},j,'k.');
    hold on;
    b(spikes{1,j})=b(spikes{1,j})+1;
    title('Cell activity raster plot');
    xlabel('Time in seconds');
    ylabel('ROI number');
    xlim([0 round(size(d.imd,3))]);
    ylim([0 size(d.ROImeans,2)+1]);
end
%changing tick labels from frames to seconds by dividing by framerate
tilabel=get(gca,'XTickLabel');
for k=1:length(tilabel)
    tilabel{k,1}=str2num(tilabel{k,1});
end
tilabel=cell2mat(tilabel);
tilabel=tilabel./d.framerate;
set(gca,'XTickLabel',tilabel);
hold off;
subplot(2,1,2);
plot(b);
xlabel('Time in seconds');
ylabel('Number of spikes');
xlim([0 round(size(d.imd,3))]);
%changing tick labels from frames to seconds by dividing by framerate
ticlabel=get(gca,'XTickLabel');
for k=1:length(ticlabel)
    ticlabel{k,1}=str2num(ticlabel{k,1});
end
ticlabel=cell2mat(ticlabel);
ticlabel=ticlabel./d.framerate;
set(gca,'XTickLabel',ticlabel);
try
    close(g);
catch
end

%calculating statistics if behavior is avaiable
if v.behav==1
    names=fieldnames(v.barstart); %names of defined behaviors
    spkfreq=[];
    spkno=b;
    spkbehavno=0;
    for j=1:v.amount
        %creating array with framenumbers where certain behavior was
        %detected
        behavior=[];
        for k=1:length(v.barstart.(names{j,1}))
            behavior=[behavior,v.barstart.(names{j,1})(k):v.barstart.(names{j,1})(k)+v.barwidth.(names{j,1})(k)];
        end
        behaviors.(names{j,1})=behavior';
        spkbehav=b(behaviors.(names{j,1}),1);
        spkbehavno=spkbehavno+length(spkbehav);
        spkno(behaviors.(names{j,1}),1)=0;
        spkbsum=sum(spkbehav);
        spkfreq.(names{j,1})=spkbsum/(length(spkbehav)/d.framerate);
    end
    spkfreq.nobehavior=sum(spkno)/(spkbehavno/d.framerate);
end
% if v.behav==1
%     names=fieldnames(v.barstart); %names of defined behaviors
%     for k=1:size(spikes,2),numspikes(1,k)=numel(spikes{1,k});end %total number of spikes per cell
%     for j=1:v.amount
%         %creating array with framenumbers where certain behavior was
%         %detected
%         behavior=[];
%         for k=1:length(v.barstart.(names{j,1}))
%             behavior=[behavior,v.barstart.(names{j,1})(k):v.barstart.(names{j,1})(k)+v.barwidth.(names{j,1})(k)];
%         end
%         behaviors.(names{j,1})=behavior';
%         %determining whether a spike was detected during a defined behavior
%         %in a logical manner
%         spklogic=cell(1,size(spikes,2));
%         for i=1:size(spikes,2)
%             for h=1:length(spikes{1,i})
%                 spklogic{1,i}(h,1)=ismember(spikes{1,i}(h),behaviors.(names{j,1}));
%             end
%             spksum(1,i)=sum(spklogic{1,i});
%         end
%         spkbehav.(names{j,1}).real=spksum; %actual number os spikes per cell
%         spkbehav.(names{j,1}).total=sum(spkbehav.(names{j,1}).real); %total number of spikes for all cells
%         total(j,1)=spkbehav.(names{j,1}).total; %variable for later easy addition
%         texting{j,1}=[names{j,1},' ']; %variable for later easy addition
%         spkbehav.(names{j,1}).percent=spkbehav.(names{j,1}).real./numspikes*100; %relative number of spikes in the behavior to outside
%         spkbehav.(names{j,1}).totalpercent=sum(spkbehav.(names{j,1}).real)/sum(numspikes)*100; %relative total number of spikes for all cells
%         percent(1,j)=spkbehav.(names{j,1}).totalpercent; %variable for later easy addition
%     end
%     spkbehav.total=sum(total); %total number of spikes within all behaviors
%     spkbehav.totalpercent=spkbehav.total/sum(numspikes)*100; %relative total number of spikes within all behaviors
%     %converting number of cells to logical array saying whether there was
%     %spikes or not
%     statlogic=zeros(1,size(spikes,2));
%     statlogical=zeros(v.amount,size(spikes,2));
%     for m=1:v.amount
%         statlogic(1,:)=spkbehav.(names{m,1}).real;
%         statlogic(statlogic>0)=1;
%         statlogical(m,:)=statlogic;
%         statcells.(names{m,1})=sum(statlogical(m,:));
%     end
%     sumstat=sum(statlogical,1); %all behaviors added up to determine whether some cells are not active during the defined behaviors,
%     %some are only active for one bahvior, or for multiple or all behaviors
%     statcells.conall=numel(find(sumstat==v.amount))/size(spikes,2)*100; %cells active druing all behaviors
%     statcells.single=numel(find(sumstat==1))/size(spikes,2)*100; %cells active for only one behavior
%     statcells.con=numel(find(sumstat>=2 & sumstat<v.amount))/size(spikes,2)*100; %cells active for more than one behavior but not all behaviors
%     statcells.null=numel(find(sumstat==0))/size(spikes,2)*100; %cells not active during any behavior
%     singlecells=zeros(1,v.amount);
%     %renaming of variable for cells active for only one behavior
%     for n=1:v.amount
%         statcells.(names{n,1})=(statcells.(names{n,1})-numel(find(sumstat==v.amount)))/size(spikes,2)*100;
%         singlecells(1,n)=statcells.(names{n,1});
%     end
%     %plotting pie charts
%     %overall spike distribution
%     percentValues=[percent 100-sum(percent)];
%     figure,h=pie(percentValues);
%     title('Spikes detected within defined behaviors');
%     hText = findobj(h,'Type','text'); % text object handles
%     percentText = get(hText,'String'); % percent values
%     txt=[texting;'No behavior '];
%     %deleting text, which percentage is 0
%     c=0;
%     rtxt=[];
%     for k=1:length(percentValues)
%         if percentValues(1,k)>0
%             c=c+1;
%             rtxt{c,1}=txt{k,1};
%         end
%     end
%     txt=rtxt;
%     combinedtxt = strcat(txt,percentText); % strings and percent values
%     for n=1:length(combinedtxt)
%         hText(n).String = combinedtxt(n);
%     end
%     %cell distribution
%     percentValues=[singlecells statcells.con statcells.conall statcells.null];
%     logicalVal=percentValues; logicalVal(logicalVal>0)=1;
%     figure,h=pie(percentValues);
%     title('Percentage of cells within defined behaviors');
%     hText = findobj(h,'Type','text'); % text object handles
%     percentText = get(hText,'String'); % percent values
%     txt=[texting;'conditional ';'all ';'none '];
%     c=0;
%     for l=1:length(txt)
%         if logicalVal(l)==1
%             c=c+1;
%             txtfinal(c,1)=txt(l);
%         end
%     end
%     combinedtxt = strcat(txtfinal,percentText); % strings and percent values
%     for n=1:length(txtfinal)
%         hText(n).String = combinedtxt(n);
%     end
% end

%saving traces
% Construct a questdlg with two options
choice = questdlg('Would you like to save these traces?', ...
    'Attention', ...
    'YES','NO','YES');
% Handle response
switch choice
    case 'YES'
        f=msgbox('Please wait...');
        files=dir(d.pn);
        tf=zeros(1,length(dir(d.pn)));
        for k=1:length(dir(d.pn))
            tf(k)=strcmp('traces',files(k).name);
        end
        if sum(tf)==0 %if folder does not exist
            mkdir([d.pn '\traces']); %create folder
            tnum=ceil(size(d.ROImeans,2)/8); %total number of figures with ROI traces
            hfnum=get(fig,'Number'); %highest figure number
            numseries=(hfnum-tnum:1:hfnum-1); %figure numbers with ROI values
            %saving traces
            for j=1:tnum
                figurenum=sprintf('-f%d',numseries(j));
                name=sprintf('traces_%d',j);
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
            end
            %saving rasterplot
            figurenum=sprintf('-f%d',hfnum);
            name=('rasterplot');
            path=[d.pn '/traces/',name,'.png'];
            path=regexprep(path,'\','/');
            print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
            
            %saving ROImask as figure
            colors=repmat(d.colors,1,ceil(max(d.ROIorder)/8)); %selecting colors for ROIs
            d.ROIorder=unique(d.labeled(d.labeled>0),'stable'); %determining the order of the ROIs
            singleFrame=d.mip./max(max(d.mip)); %getting picture into the value range from 0 to 1 for roipoly
            h=figure; imshow(singleFrame);hold on;
            stat = regionprops(d.labeled,'Centroid'); %finding center of ROIs
            for k=1:size(d.b,1)
                d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
                text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
            end %drawing ROIs
            hold off;
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            name=('ROImask');
            path=[d.pn '/traces/',name,'.png'];
            path=regexprep(path,'\','/');
            print(h,'-dpng','-r200',path); %-depsc for vector graphic
            close(h);
            
            %saving raw ROI values over time
            h=figure;imagesc(d.ROImeans',[round(min(min(d.ROImeans))) round(max(max(d.ROImeans)))*0.9]),colorbar;
            title('Raw fluorescence traces');
            xlabel('Time in seconds');
            ylabel('Cell number');
            xlim([0 round(size(d.imd,3))]);
            ticlabel=get(gca,'XTickLabel');
            for k=1:length(ticlabel)
                ticlabel{k,1}=str2num(ticlabel{k,1});
            end
            ticlabel=cell2mat(ticlabel);
            ticlabel=ticlabel./d.framerate;
            set(gca,'XTickLabel',ticlabel);
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            name=('RawFluo');
            path=[d.pn '/traces/',name,'.png'];
            path=regexprep(path,'\','/');
            print(h,'-dpng','-r200',path); %-depsc for vector graphic
            close(h);

            %saving table
            filename=[d.pn '\traces\ROIs_' d.fn(1:end-4) '.xls'];
            ROInumber=cell(size(d.ROImeans,2),1);
            for k=1:size(d.ROImeans,2)
                ROInumber{k,1}=sprintf('ROI No.%d',k);
            end
            T=table(NoofSpikes,Frequency,Amplitude,...
                'RowNames',ROInumber);
            writetable(T,filename,'WriteRowNames',true);
            
            %saving data
            field1='framerate';
            field2='wave';
            field3='spikes';
            field4='amp';
            field5='ts';
            value1=d.framerate;
            value2=d.ROImeans;
            value4=amp;
            value5=ts;
            value3=struct(field4,value4,field5,value5);
            traces=struct(field1,value1,field2,value2,field3,value3);
            filename=[d.pn '\traces\traces_' d.fn(1:end-4)];
            save(filename, 'traces');
    
            try
                close(f);
            catch
            end
            msgbox('Done!','Attention');
        else  %if folder traces already exists
            if v.behav==1 %if behaviors were defined
                tnum=ceil(size(d.ROImeans,2)/8); %total number of figures with ROI traces
                hfnum=get(fig,'Number'); %highest figure number
                numseries=(hfnum-tnum:1:hfnum-1); %figure numbers with ROI values
                %saving traces
                for j=1:tnum
                    name=sprintf('traces_behav_%d',j);
                    figurenum=sprintf('-f%d',numseries(j));
                    path=[d.pn '/traces/',name,'.png'];
                    path=regexprep(path,'\','/');
                    print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
                end
                %saving rasterplot
                name=('rasterplot_behav');
                figurenum=sprintf('-f%d',hfnum);
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
                %saving table
                filename=[d.pn '\traces\freqbehav_' d.fn(1:end-4) '.xls'];
                T=struct2table(spkfreq);
                writetable(T,filename);
%                 %saving piecharts
%                 name=('piechart_behav');
%                 figurenum=sprintf('-f%d',hfnum+1);
%                 path=[d.pn '/traces/',name,'.png'];
%                 path=regexprep(path,'\','/');
%                 print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
%                 name=('piechart_cells');
%                 figurenum=sprintf('-f%d',hfnum+2);
%                 path=[d.pn '/traces/',name,'.png'];
%                 path=regexprep(path,'\','/');
%                 print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic

                %saving mean values of ROIs over time with behavior
                mVal=mean(d.ROImeans,2);
                h=figure;
                for l=1:v.amount
                    for m=1:length(v.barstart.(char(v.name{1,l})))
                    rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),round(min(mVal),1),v.barwidth.(char(v.name{1,l}))(m),abs(round(min(mVal),1))+round(max(mVal),1)],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
                    end
                end
                plot(1:length(mVal),mVal,'k');
                title('Mean fluorescence trace with behavior');
                xlabel('Time in seconds');
                ylabel('Brightness in %');
                xlim([0 round(size(d.imd,3))]);
                ticlabel=get(gca,'XTickLabel');
                for k=1:length(ticlabel)
                    ticlabel{k,1}=str2num(ticlabel{k,1});
                end
                ticlabel=cell2mat(ticlabel);
                ticlabel=ticlabel./d.framerate;
                set(gca,'XTickLabel',ticlabel);
                set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                name=('meanFluobehav');
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(h,'-dpng','-r200',path); %-depsc for vector graphic
                close(h);
                
                %saving data
                filename=[d.pn '\traces\spkbehavior_' ];
                save(filename, 'spkbehav');
%                 filename=[d.pn '\traces\cellstatistics_'];
%                 save(filename, 'statcells');
                try
                    close(f);
                catch
                end
                msgbox('Done!','Attention');
            else %if behaviors were not defined
                rmdir([d.pn '\traces'],'s'); %delete existing folder
                mkdir([d.pn '\traces']); %create same folder new, so that results are overwritten
                tnum=ceil(size(d.ROImeans,2)/8); %total number of figures with ROI traces
                hfnum=get(fig,'Number'); %highest figure number
                numseries=(hfnum-tnum:1:hfnum-1); %figure numbers with ROI values
                %saving traces
                for j=1:tnum
                    if v.behav==1
                        name=sprintf('traces_behav_%d',j);
                    else
                        name=sprintf('traces_%d',j);
                    end
                    figurenum=sprintf('-f%d',numseries(j));
                    path=[d.pn '/traces/',name,'.png'];
                    path=regexprep(path,'\','/');
                    print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
                end
                %saving rasterplot
                if v.behav==1
                    name=('rasterplot_behav');
                else
                    name=('rasterplot');
                end
                figurenum=sprintf('-f%d',hfnum);
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic

                %saving ROImask as figure
                colors=repmat(d.colors,1,ceil(max(d.ROIorder)/8)); %selecting colors for ROIs
                d.ROIorder=unique(d.labeled(d.labeled>0),'stable'); %determining the order of the ROIs
                singleFrame=d.mip./max(max(d.mip)); %getting picture into the value range from 0 to 1 for roipoly
                h=figure; imshow(singleFrame);hold on;
                stat = regionprops(d.labeled,'Centroid'); %finding center of ROIs
                for k=1:size(d.b,1)
                    d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
                    text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                end %drawing ROIs
                hold off;
                set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                name=('ROImask');
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(h,'-dpng',path); %-depsc for vector graphic
                close(h);
                
                %saving raw ROI values over time
                h=figure;imagesc(d.ROImeans',[round(min(min(d.ROImeans))) round(max(max(d.ROImeans)))*0.9]),colorbar;
                title('Raw fluorescence traces');
                xlabel('Time in seconds');
                ylabel('Cell number');
                xlim([0 round(size(d.imd,3))]);
                ticlabel=get(gca,'XTickLabel');
                for k=1:length(ticlabel)
                    ticlabel{k,1}=str2num(ticlabel{k,1});
                end
                ticlabel=cell2mat(ticlabel);
                ticlabel=ticlabel./d.framerate;
                set(gca,'XTickLabel',ticlabel);
                set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                name=('RawFluo');
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(h,'-dpng','-r200',path); %-depsc for vector graphic
                close(h);

                %saving table
                filename=[d.pn '\traces\ROIs_' d.fn(1:end-4) '.xls'];
                ROInumber=cell(size(d.ROImeans,2),1);
                for k=1:size(d.ROImeans,2)
                    ROInumber{k,1}=sprintf('ROI No.%d',k);
                end
                T=table(NoofSpikes,Frequency,Amplitude,...
                    'RowNames',ROInumber);
                writetable(T,filename,'WriteRowNames',true);

                %saving data
                field1='framerate';
                field2='wave';
                field3='spikes';
                field4='amp';
                field5='ts';
                value1=d.framerate;
                value2=d.ROImeans;
                value4=amp;
                value5=ts;
                value3=struct(field4,value4,field5,value5);
                traces=struct(field1,value1,field2,value2,field3,value3);
                filename=[d.pn '\traces\traces_' d.fn(1:end-4)];
                save(filename, 'traces');

                try
                    close(f);
                catch
                end
                msgbox('Done!','Attention');
            end
        end
    case 'NO'
        return;
end






% --- Executes on button press in pushbutton26.               SAVE CI VIDEO
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d

if isempty(d.origCI)==1&&d.pushed==1
    d.origCI=d.imd;
elseif isempty(d.origCI)==1&&d.pushed==4
    d.origCI=[];
end


if d.dF==0 %saving video if it was not processed further
    %converting original CI video to double precision and to values between 1 and 0
    h=waitbar(0,'Saving calcium imaging video');
    origCIdou=double(d.origCI);
    origCIconv=origCIdou./max(max(max(origCIdou)));

    filename=[d.pn '\' d.fn(1:end-4)];
    vid = VideoWriter(filename,'Grayscale AVI');
    vid.FrameRate=d.framerate;
    nframes=size(d.imd,3);
    open(vid);
    for k=1:nframes
        singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        writeVideo(vid,singleFrame);
        waitbar(k/nframes,h);
    end
    close(vid);
    close(h);
    msgbox('Saving video completed.');
elseif isempty(d.origCI)==1&&d.pushed==4
    % Construct a questdlg with two options
    choice = questdlg('Since you did not load the original CI video, you can only save the dF/F video. Do you want to load the original CI video now?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    switch choice
        case 'YES'
            %extracts filename
            filePattern = fullfile(d.pn, '*.tif'); % *.tiff for 2-P
            Files = dir(filePattern);
            if length(Files)==1
                %function for loading TIFF stack
                pn=d.pn;
                fn=d.fn;
                [imd] = loadCIstack(pn,fn);
                d.origCI=imd;
                d.origCI=imresize(d.imd,0.805); %keeping this file stored as original video but resized since original video is bigger than the downsampled video
            else
                %function for loading single TIFFs together
                pn=d.pn;
                fn=d.fn;
                [imd] = loadCIsingle(pn,fn,Files);
                d.origCI=imd;
                d.origCI=imresize(d.imd,0.805); %keeping this file stored as original video but resized since original video is bigger than the downsampled video
            end
            d.dF=1;
            load([d.pn '\' d.fn(1:end-4) 'vidalign']);
            d.align=vidalign;
            d.pre=1;

            msgbox('Loading complete!');
            
            % Construct a questdlg with two options
            choice = questdlg('Would you like to save only the dF/F video or the combined one?', ...
                'Attention', ...
                'dF/F','Combined');
            % Handle response
            switch choice
                case 'dF/F'
                    %function for saving dF/F video
                    pn=d.pn; fn=d.fn; framerate=d.framerate; imd=d.imd;
                    savedFF(pn,fn,framerate,imd);
                case 'Combined'
                    %function for saving combined video
                    imd=d.imd; mask=d.mask; pn=d.pn; fn=d.fn; origCI=d.origCI; framerate=d.framerate;
                    saveCombi(handles,imd,mask,fn,pn,origCI,framerate);
            end
            
        case 'NO'
            %function for saving dF/F video
            pn=d.pn; fn=d.fn; framerate=d.framerate; imd=d.imd;
            savedFF(pn,fn,framerate,imd);
    end
else
    % Construct a questdlg with two options
    choice = questdlg('Would you like to save only the dF/F video or the combined one?', ...
        'Attention', ...
        'dF/F','Combined','dF/F');
    % Handle response
    switch choice
        case 'dF/F'
            %function for saving dF/F video
            pn=d.pn; fn=d.fn; framerate=d.framerate; imd=d.imd;
            savedFF(pn,fn,framerate,imd);
        case 'Combined'
            %function for saving combined video
            imd=d.imd; mask=d.mask; pn=d.pn; fn=d.fn; origCI=d.origCI; framerate=d.framerate;
            saveCombi(handles,imd,mask,fn,pn,origCI,framerate);
    end
end




%---------------------------Browsing through video/s

% --- Executes on slider movement.                            CHANGES FRAME
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
global v
if d.pushed==0 && v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if v.pushed==0
    v.imd=[];
    nframes=[];
elseif v.pushed==1
    v.hsvA=[];
    v.hsvP=[];
    nframes=size(v.imd,2);
elseif v.pushed>=1
    nframes=size(v.imd,2);
end
if d.pushed==0
    d.imd=[];
    maxframes=size(v.imd,2);
    handles.slider7.Max=maxframes;
else
    maxframes=size(d.imd,3);
    handles.slider7.Max=maxframes;
end

cla(handles.axes1);
cla(handles.axes2);

if v.pushed>1
    if v.preset==1
        % Green preset values
        color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
    elseif v.preset==2
        % Pink preset values
        color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
    elseif v.preset==3
        % Yellow preset values
        color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
    elseif v.preset==4
        % Blue preset values
        color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
    end
end

if d.pushed==4
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    colors=repmat(d.colors,1,(ceil(size(d.b,1)/8)));
end

if d.pre==1 && d.pushed==1
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    axes(handles.axes1);
    if d.dF==1 || d.pre==1
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif d.pushed==1
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);
    if d.dF==1 || d.pre==1
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif d.pushed==4
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    axes(handles.axes1);
    if d.dF==1 || d.pre==1
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame);hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for k=1:size(d.b,1)
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end
    hold off;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
end
if v.pushed==1 && d.pushed>=1
    axes(handles.axes2); image(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata); %original video
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed==1
    axes(handles.axes2); image(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata); %original video
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed==2
    %function for masking the colored spot of the animal
    [maskedRGBImage] = spotmask(nframes,maxframes,handles);
    %showing masked image in GUI
    if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
        axes(handles.axes2); 
        grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
        set(gcf,'renderer','OpenGL');
        alpha(grid,0.1);
        str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
        text(20,20,str,'Color','r');
        hold off;
    else
        axes(handles.axes2);
        grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
        set(gcf,'renderer','OpenGL');
        alpha(grid,0.1);
        hh=imshow(color);
        set(hh, 'AlphaData', maskedRGBImage(:,:,1));
    end
    hold off;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed==3
    %function for masking the colored spot of the animal
    [maskedRGBImage] = spotmask(nframes,maxframes,handles);
    %showing masked image in GUI
    if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
        axes(handles.axes2); 
        grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
        set(gcf,'renderer','OpenGL');
        alpha(grid,0.1);
        str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
        text(20,20,str,'Color','r');
        hold off;
    else
        axes(handles.axes2);
        grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
        set(gcf,'renderer','OpenGL');
        alpha(grid,0.1);
        hh=imshow(color);
        set(hh, 'AlphaData', maskedRGBImage(:,:,1));
    end
    hold off;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
end


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in pushbutton18.                  PLAY VIDEO
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
d.stop=0;
%checks if a video file was selected
if v.pushed==0 && d.pushed==0
    msgbox('Please select folder first!','ERROR');
    return;
elseif v.pushed==0
    v.imd=[];
    nframes=[];
elseif v.pushed==1
    v.hsvA=[];
    v.hsvP=[];
    nframes=size(v.imd,2);
elseif v.pushed>=1
    nframes=size(v.imd,2);
end
if d.pushed==0
    d.imd=[];
    maxframes=size(v.imd,2);
else
    maxframes=size(d.imd,3);
end

cla(handles.axes1);
cla(handles.axes2);

if v.pushed>1
    if v.preset==1
        % Green preset values
        color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
    elseif v.preset==2
        % Pink preset values
        color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
    elseif v.preset==3
        % Yellow preset values
        color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
    elseif v.preset==4
        % Blue preset values
        color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
    end
end

if d.pushed==4
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    colors=repmat(d.colors,1,ceil(size(d.b,1)/8));
end

%if both videos were loaded
if v.pushed==1 && d.pre==1 && d.pushed==1
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        axes(handles.axes2);
        image(v.imd(round(k*round((nframes/maxframes),2))).cdata); %original video
        axes(handles.axes1); %thresholded video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            axes(handles.axes1); imshow(singleFrame);
        end
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==1 && d.pushed==1
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        axes(handles.axes2); %#ok<*LAXES>
        image(v.imd(round(k*round((nframes/maxframes),2))).cdata); %original video
        axes(handles.axes1); %original video
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==1 && d.pushed==4
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        axes(handles.axes2);
        image(v.imd(round(k*round((nframes/maxframes),2))).cdata); %original video
        axes(handles.axes1); %ROIs with video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
        else
            imshow(singleFrame);hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for j=1:size(d.b,1)
            d.c{j,1} = stat(d.ROIorder(j)).Centroid;
            plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
            text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
        end
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==2 && d.pre==1 && d.pushed==1
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(nframes,maxframes,handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %thresholded video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            axes(handles.axes1); imshow(singleFrame);
        end
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif  v.pushed==2 && d.pushed==1
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(nframes,maxframes,handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %original video
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==2 && d.pushed==4
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(nframes,maxframes,handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %ROIs with video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
        else
            imshow(singleFrame);hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for j=1:size(d.b,1)
            d.c{j,1} = stat(d.ROIorder(j)).Centroid;
            plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
            text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
        end
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==3 && d.pre==1 && d.pushed==1
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(nframes,maxframes,handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %thresholded video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            axes(handles.axes1); imshow(singleFrame);
        end
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==3 && d.pushed==1
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(nframes,maxframes,handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %original video
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==3 && d.pushed==4
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(nframes,maxframes,handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %ROIs with video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
        else
            imshow(singleFrame);hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for j=1:size(d.b,1)
            d.c{j,1} = stat(d.ROIorder(j)).Centroid;
            plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
            text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
        end
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
end


%if only calcium video was loaded
if d.pre==1 && d.pushed<4
    d.play=1;
    axes(handles.axes1);
    for k=round(handles.slider7.Value):size(d.imd,3)
        singleFrame=d.imd(:,:,round(handles.slider7.Value));
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            axes(handles.axes1); imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif d.pushed==1
    d.play=1;
    axes(handles.axes1); %original video
    for k=round(handles.slider7.Value):size(d.imd,3)
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif d.pushed==4
    d.play=1;
    axes(handles.axes1); %video with ROIs
    for k=round(handles.slider7.Value):size(d.imd,3)
    singleFrame=d.imd(:,:,k);
    if d.dF==1 || d.pre==1
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame);hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for j=1:size(d.b,1)
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3)
            d.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
end


% --- Executes on button press in pushbutton21.                        STOP
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
d.stop=1;
d.play=0;
v.play=0;







%% ---------------------------Processing behavioral video


% --- Executes on button press in pushbutton7.       LOADS BEHAVIORAL VIDEO
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
global p
%clears cache
%clears all global variables
clear global v;
%reinitializes global variables
global v %#ok<*REDEF>
v.pushed=0;
v.play=0;
v.pn=[];
v.amount=[];
v.shortkey=[];
v.name=[];
v.events=[];
v.skdefined=0;
v.behav=0;
v.smallestArea=25;
p.import=0;
%clears axes
cla(handles.axes2,'reset');
%resets frame slider
handles.slider7.Value=1;

if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end

%checks whether calcium imaging video was loaded
if d.pushed==0
    msgbox('Please select calcium imaging video first!','ATTENTION');
    return;
end        

v.pn=[];
v.fn=[];
v.crop=0; %signals video is not cropped
v.hsv=0; %signals video is not converted to hsv color space
v.Pspot=0; %signals green spot is not saved
v.Aspot=0; %signals pink spot is not saved
if d.pushed>=1
    [v.pn]=uigetdir(d.pn);
else
    [v.pn]=uigetdir('F:\jenni\Documents\PhD PROJECT\Calcium Imaging\doric camera\');
end

%check whether converted video had been saved before
filePattern = fullfile(v.pn, '*.mp4');
Files = dir(filePattern);
for j=1:length(Files)
    v.fn{j} = Files(j).name;
end
files=dir(v.pn);
tf=zeros(1,length(dir(v.pn)));
for k=1:length(dir(v.pn))
    tf(k)=strcmp([v.fn{1}(1:end-4) '_converted.mat'],files(k).name);
end
if sum(tf)>0
    % Construct a questdlg with two options
    choice = questdlg('Would you like to load your last processed version?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    switch choice
        case 'YES'
            %function for loading last processed version
            [skeys,tfb] = loadlastBV;
            %looking at first original picture
            axes(handles.axes2); image(v.imd(1).cdata);
            titleLabel = ['Behavioral video: ' v.fn];
            set(handles.text28, 'String', titleLabel);
            handles.text28.TooltipString=v.pn;
            if sum(tfb)>0
                msgbox(cat(2, {'Loading Completed. Your shortkeys are:'}, skeys),'Success');
            else
                msgbox(sprintf('Loading Completed.'),'Success');
            end
        case 'NO'
            %function for loading behavioral video
            dframerate=d.framerate; dsize=size(d.imd,3); pn=v.pn; fn=v.fn; dimd=d.imd;
            [sframe,imd,pushed,dimd,dROIv] = loadBV(dframerate,dsize,pn,fn,dimd,handles);
            d.imd=dimd;
            d.ROIv=dROIv;
            v.imd=imd;
            v.pushed=pushed;
            %looking at first original picture
            axes(handles.axes2); image(v.imd(1).cdata);
            titleLabel = ['Behavioral video: ' v.fn];
            set(handles.text28, 'String', titleLabel);
            handles.text28.TooltipString=v.pn;
            msgbox(sprintf('Loading Completed. Frames cut off: %d',sframe),'Success');
    end
else
    %function for loading behavioral video
    dframerate=d.framerate; dsize=size(d.imd,3); pn=v.pn; fn=v.fn; dimd=d.imd;
    [sframe,imd,pushed,dimd,dROIv] = loadBV(dframerate,dsize,pn,fn,dimd,handles);
    d.imd=dimd;
    d.ROIv=dROIv;
    v.imd=imd;
    v.pushed=pushed;
    %looking at first original picture
    axes(handles.axes2); image(v.imd(1).cdata);
    titleLabel = ['Behavioral video: ' v.fn];
    set(handles.text28, 'String', titleLabel);
    handles.text28.TooltipString=v.pn;
    msgbox(sprintf('Loading Completed. Frames cut off: %d',sframe),'Success');
end





% --- Executes on button press in pushbutton15. CROPPING & DOWNSAMPLING
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
axes(handles.axes2); image(v.imd(1).cdata); %displays first image
if d.help==1
    uiwait(msgbox('Please define the area where the animal is running by left-click and dragging the cursor over the area! Then right click and select Copy Position, finish by double-clicking!','Attention','modal'));
end
%initializes interactive cropping
h=imcrop;
cropped=clipboard('pastespecial');
cropCoordinates=str2num(cell2mat(cropped.A_pastespecial));
%checks if cropping coordinates are valid
if isempty(cropCoordinates)==1 || cropCoordinates(1,3)==0 || cropCoordinates(1,4)==0
    msgbox('Please select valid cropping area! Check the instructions again.','ERROR');
    return;
end
cc=floor(cropCoordinates);
%function for cropping video
cropBV(cc);
%function for downsampling video
donwsampleBV;
axes(handles.axes2); image(v.imd(1).cdata);

%saving cropped video
h=msgbox('Saving progress... Program might seem unresponsive, please wait!');
filename=[v.pn '\' v.fn{1}(1:end-4) '_converted.mat'];
convVimd=v.imd;
save(filename, 'convVimd','-v7.3');
close(h);

if d.help==1
    msgbox('Cropping and downsampling completed. Please select a color preset to view only the colored spot. If needed adjust thresholds manually! If satisfied save the two colored spots by clicking PREVIEW ANTERIOR SPOT and PREVIEW POSTERIOR SPOT. If you have only one spot select only ANTERIOR SPOT','Success');
else
    msgbox('Cropping and downsampling completed.','Success');
end





% --- Executes on slider movement.                                SPOT SIZE
function slider22_Callback(hObject, eventdata, handles)
% hObject    handle to slider22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d

v.smallestArea=round(handles.slider22.Value);

if v.pushed==0
    v.imd=[];
    nframes=[];
elseif v.pushed==1
    v.hsvA=[];
    v.hsvP=[];
    nframes=size(v.imd,2);
elseif v.pushed>=1
    nframes=size(v.imd,2);
end
if d.pushed==0
    d.imd=[];
    maxframes=size(v.imd,2);
    handles.slider7.Max=maxframes;
else
    maxframes=size(d.imd,3);
    handles.slider7.Max=maxframes;
end

if v.preset==1
    % Green preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==2
    % Pink preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==3
    % Yellow preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==4
    % Blue preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
end

%function for spot mask
[maskedRGBImage] = spotmask(nframes,maxframes,handles);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
    axes(handles.axes2); 
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    str=sprintf('animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2);
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    hh=imshow(color);
    set(hh, 'AlphaData', maskedRGBImage(:,:,1));
end
hold off;
textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
set(handles.text36, 'String', textLabel);

% --- Executes during object creation, after setting all properties.
function slider22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on slider movement.                      VALUE THRESHOLD LOW
function slider9_Callback(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

if v.preset==1
    % Green preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==2
    % Pink preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==3
    % Yellow preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==4
    % Blue preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
end

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

%function for spot mask
[maskedRGBImage] = spotmask(nframes,maxframes,handles);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
    axes(handles.axes2); 
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    str=sprintf('animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2);
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    hh=imshow(color);
    set(hh, 'AlphaData', maskedRGBImage(:,:,1));
end
hold off;

% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                     VALUE THRESHOLD HIGH
function slider10_Callback(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

if v.preset==1
    % Green preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==2
    % Pink preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==3
    % Yellow preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==4
    % Blue preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
end

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

%function for spot mask
[maskedRGBImage] = spotmask(nframes,maxframes,handles);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
    axes(handles.axes2); 
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    str=sprintf('animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2);
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    hh=imshow(color);
    set(hh, 'AlphaData', maskedRGBImage(:,:,1));
end
hold off;

% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                SATURATION THRESHOLD HIGH
function slider11_Callback(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

if v.preset==1
    % Green preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==2
    % Pink preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==3
    % Yellow preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==4
    % Blue preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
end

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

%function for spot mask
[maskedRGBImage] = spotmask(nframes,maxframes,handles);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
    axes(handles.axes2); 
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    str=sprintf('animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2);
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    hh=imshow(color);
    set(hh, 'AlphaData', maskedRGBImage(:,:,1));
end
hold off;

% --- Executes during object creation, after setting all properties.
function slider11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                 SATURATION THRESHOLD LOW
function slider12_Callback(hObject, eventdata, handles)
% hObject    handle to slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

if v.preset==1
    % Green preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==2
    % Pink preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==3
    % Yellow preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==4
    % Blue preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
end

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

%function for spot mask
[maskedRGBImage] = spotmask(nframes,maxframes,handles);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
    axes(handles.axes2); 
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    str=sprintf('animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2);
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    hh=imshow(color);
    set(hh, 'AlphaData', maskedRGBImage(:,:,1));
end
hold off;

% --- Executes during object creation, after setting all properties.
function slider12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                        HUE THRESHOLD LOW
function slider13_Callback(hObject, eventdata, handles)
% hObject    handle to slider13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

if v.preset==1
    % Green preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==2
    % Pink preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==3
    % Yellow preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==4
    % Blue preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
end

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

%function for spot mask
[maskedRGBImage] = spotmask(nframes,maxframes,handles);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
    axes(handles.axes2); 
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    str=sprintf('animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2);
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    hh=imshow(color);
    set(hh, 'AlphaData', maskedRGBImage(:,:,1));
end
hold off;

% --- Executes during object creation, after setting all properties.
function slider13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                       HUE THRESHOLD HIGH
function slider14_Callback(hObject, eventdata, handles)
% hObject    handle to slider14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

if v.preset==1
    % Green preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==2
    % Pink preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==3
    % Yellow preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==4
    % Blue preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
end

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

%function for spot mask
[maskedRGBImage] = spotmask(nframes,maxframes,handles);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
    axes(handles.axes2); 
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    str=sprintf('animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2);
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    hh=imshow(color);
    set(hh, 'AlphaData', maskedRGBImage(:,:,1));
end
hold off;

% --- Executes during object creation, after setting all properties.
function slider14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on selection change in popupmenu1.              SELECT COLOR
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

global d
global v
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

%determining popup choice
v.preset=handles.popupmenu1.Value;
if v.preset==1
    % Green preset values
    hueThresholdLow = 0.25;
    hueThresholdHigh = 0.55;
    saturationThresholdLow = 0.16;
    saturationThresholdHigh = 1;
    valueThresholdLow = 0;
    valueThresholdHigh = 0.8;
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==2
    % Pink preset values
    hueThresholdLow = 0.80;
    hueThresholdHigh = 1;
    saturationThresholdLow = 0.36;
    saturationThresholdHigh = 1;
    valueThresholdLow = 0.0;
    valueThresholdHigh = 0.8;
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==3
    % Yellow preset values
    hueThresholdLow = 0.12;
    hueThresholdHigh = 0.25;
    saturationThresholdLow = 0.19;
    saturationThresholdHigh = 1;
    valueThresholdLow = 0;
    valueThresholdHigh = 0.8;
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==4
    % Blue preset values
    hueThresholdLow = 0.62;
    hueThresholdHigh = 1;
    saturationThresholdLow = 0.3;
    saturationThresholdHigh = 1;
    valueThresholdLow = 0.7;
    valueThresholdHigh = 1;
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
end

handles.slider14.Value = hueThresholdHigh;
handles.slider13.Value = hueThresholdLow;
handles.slider12.Value = saturationThresholdLow;
handles.slider11.Value = saturationThresholdHigh;
handles.slider9.Value = valueThresholdLow;
handles.slider10.Value = valueThresholdHigh;

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

%function for spot mask
[maskedRGBImage] = spotmask(nframes,maxframes,handles);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
    axes(handles.axes2); 
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2);
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    hh=imshow(color);
    set(hh, 'AlphaData', maskedRGBImage(:,:,1));
end
hold off;


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton36.               IMPORT PRESET
function pushbutton36_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
global p
%defining folder
%defining initial folder displayed in dialog window
if isempty(p.pnpreset)==1
    [p.pnpreset]=uigetdir(v.pn);
else
    [p.pnpreset]=uigetdir(p.pnpreset);
end
%loading preset
% Construct a questdlg with two options
choice = questdlg('Which preset would you like to import?', ...
    'Attention', ...
    'anterior','posterior','anterior');
% Handle response
switch choice
    case 'anterior'
        load([p.pnpreset '\presetA']);
        v.hueThresholdHigh=hueHigh;
        v.hueThresholdLow=hueLow;
        v.saturationThresholdLow=satHigh;
        v.saturationThresholdHigh=satLow;
        v.valueThresholdLow=valueLow;
        v.valueThresholdHigh=valueHigh;
        v.preset=vcolor;
    case 'posterior'
        load([p.pnpreset '\presetP']);
        v.hueThresholdHigh=hueHigh;
        v.hueThresholdLow=hueLow;
        v.saturationThresholdLow=satHigh;
        v.saturationThresholdHigh=satLow;
        v.valueThresholdLow=valueLow;
        v.valueThresholdHigh=valueHigh;
        v.preset=vcolor;
end

handles.popupmenu1.Value=v.preset;

if v.preset==1
    % Green preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==2
    % Pink preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==3
    % Yellow preset values
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==4
    % Blue preset values
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
end

handles.slider14.Value = v.hueThresholdHigh;
handles.slider13.Value = v.hueThresholdLow;
handles.slider12.Value = v.saturationThresholdLow;
handles.slider11.Value = v.saturationThresholdHigh;
handles.slider9.Value = v.valueThresholdLow;
handles.slider10.Value = v.valueThresholdHigh;

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

%function for spot mask
[maskedRGBImage] = spotmask(nframes,maxframes,handles);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
    axes(handles.axes2); 
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2);
    grid=imshow(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    hh=imshow(color);
    set(hh, 'AlphaData', maskedRGBImage(:,:,1));
end
hold off;




% --- Executes on button press in pushbutton10.      SAVE AS POSTERIOR SPOT
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('PLEASE PUSH STOP BUTTON BEFORE PROCEEDING!','PLEASE PUSH STOP BUTTON');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

v.hueThresholdHigh = handles.slider14.Value;
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

thresh.hueThresholdHigh=v.hueThresholdHigh;
thresh.hueThresholdLow=v.hueThresholdLow;
thresh.saturationThresholdLow=v.saturationThresholdLow;
thresh.saturationThresholdHigh=v.saturationThresholdHigh;
thresh.valueThresholdLow=v.valueThresholdLow;
thresh.valueThresholdHigh=v.valueThresholdHigh;
thresh.smallestArea=v.smallestArea;

nframes=size(v.imd,2);
x=zeros(nframes,1);
y=zeros(nframes,1);
v.traceP=zeros(nframes,2);
%tracing center of the extracted posterior dot
h=waitbar(0,'Tracing posterior spot');
for k=1:nframes
    %function for spot mask and center coordinates extraction
    imd=v.imd(k).cdata;
    [x,y] = savespot(x,y,k,thresh,imd);
    waitbar(k/nframes,h);
end
v.traceP(:,1)=x; %coordinates of the animal center
v.traceP(:,2)=y;
v.pushed=2; %signals posterior spot was saved
v.Pspot=1; %signals posterior spot was saved
close(h);

%plotting posterior trace
v.tracePplot=v.traceP(v.traceP>0);
v.tracePplot=reshape(v.tracePplot,[size(v.tracePplot,1)/2,2]);
OutofBounds=100-round(length(v.tracePplot)/length(v.traceP)*100);
str=sprintf('Animal is out of bounds in %g percent of cases',OutofBounds);
figure, image(v.imd(1).cdata); hold on;
%choosing color for plot
if v.preset==1
    v.colorP=('g');
elseif v.preset==2
    v.colorP=('r');
elseif v.preset==3
    v.colorP=('y');
elseif v.preset==4
    v.colorP=('b');
end

%saving posterior trace
filename=[v.pn '\traceP'];
traceP=v.traceP;
tracePplot=v.tracePplot;
colorP=v.colorP;
save(filename, 'traceP','tracePplot','colorP');
%saving preset
filename=[v.pn '\presetP'];
hueHigh=v.hueThresholdHigh;
hueLow=v.hueThresholdLow;
satHigh=v.saturationThresholdLow;
satLow=v.saturationThresholdHigh;
valueLow=v.valueThresholdLow;
valueHigh=v.valueThresholdHigh;
vcolor=v.preset;
save(filename, 'hueHigh','hueLow','satHigh','satLow','valueLow','valueHigh','vcolor');

plot(v.tracePplot(:,1),v.tracePplot(:,2),v.colorP);
text(20,20,str,'Color','r'); hold off;

msgbox('Saving Completed. Please save anterior spot as well!','Success');



% --- Executes on button press in pushbutton11.       SAVE AS ANTERIOR SPOT
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('PLEASE PUSH STOP BUTTON BEFORE PROCEEDING!','PLEASE PUSH STOP BUTTON');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
            
v.hueThresholdHigh = handles.slider14.Value;
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

thresh.hueThresholdHigh=v.hueThresholdHigh;
thresh.hueThresholdLow=v.hueThresholdLow;
thresh.saturationThresholdLow=v.saturationThresholdLow;
thresh.saturationThresholdHigh=v.saturationThresholdHigh;
thresh.valueThresholdLow=v.valueThresholdLow;
thresh.valueThresholdHigh=v.valueThresholdHigh;
thresh.smallestArea=v.smallestArea;

nframes=size(v.imd,2);
x=zeros(nframes,1);
y=zeros(nframes,1);
v.traceA=zeros(nframes,2);
%tracing center of the extracted anterior dot
h=waitbar(0,'Tracing anterior spot');
for k=1:nframes
    %function for spot mask and center coordinates extraction
    imd=v.imd(k).cdata;
    [x,y] = savespot(x,y,k,thresh,imd);
    waitbar(k/nframes,h);
end
v.traceA(:,1)=x; %coordinates of the animal center
v.traceA(:,2)=y;
v.pushed=3; %signals anterior spot was saved
v.Aspot=1; %signals anterior spot was saved
close(h);

%plotting anterior trace
v.traceAplot=v.traceA(v.traceA>0);
v.traceAplot=reshape(v.traceAplot,[size(v.traceAplot,1)/2,2]);
OutofBounds=100-round(length(v.traceAplot)/length(v.traceA)*100);
str=sprintf('Animal is out of bounds in %g percent of cases',OutofBounds);
figure, image(v.imd(1).cdata); hold on;
%choosing color for plot
if v.preset==1
    v.colorA=('g');
elseif v.preset==2
    v.colorA=('r');
elseif v.preset==3
    v.colorA=('y');
elseif v.preset==4
    v.colorA=('b');
end

%saving anterior trace
filename=[v.pn '\traceA'];
traceA=v.traceA;
traceAplot=v.traceAplot;
colorA=v.colorA;
save(filename, 'traceA','traceAplot','colorA');
%saving preset
filename=[v.pn '\presetA'];
hueHigh=v.hueThresholdHigh;
hueLow=v.hueThresholdLow;
satHigh=v.saturationThresholdLow;
satLow=v.saturationThresholdHigh;
valueLow=v.valueThresholdLow;
valueHigh=v.valueThresholdHigh;
vcolor=v.preset;
save(filename, 'hueHigh','hueLow','satHigh','satLow','valueLow','valueHigh','vcolor');

plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA);
text(20,20,str,'Color','r'); hold off;

msgbox('Saving Completed. If both spots are saved, please proceed by tracing the animal!','Success');






% --- Executes on button press in pushbutton12.                TRACE ANIMAL
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('PLEASE PUSH STOP BUTTON BEFORE PROCEEDING!','PLEASE PUSH STOP BUTTON');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop video first!','ERROR');
    return;
elseif d.pushed==0
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
%checks whether spots were selected
if v.Aspot==0 && v.Pspot==0
    msgbox('Please select colored spots!','ERROR');
    return;
elseif v.Aspot==0
    msgbox('Please select anterior colored spot!','ERROR');
    return;
elseif v.Pspot==0
    % Construct a questdlg with two options
    choice = questdlg('Do you have only one colored spot on your animal?', ...
        'Attention', ...
        'Yes','No','Yes');
    % Handle response
    switch choice
        case 'Yes'
            v.tracePplot=[];
            v.traceP=[];
        case 'No'
            msgbox('Then please select posterior colored spot!','Attention');
            return;
    end
end
%making sure that the ROIs were plotted
if isempty(d.ROImeans)==1 || d.dF==0
    msgbox('ROIs need to be plotted before you can see corresponding postition of the animal with cell activity!','ATTENTION');
    return;
end
if d.thresh==1 && size(d.ROIs,2)~=size(d.ROImeans,2) && d.dF==0
    msgbox('All ROIs need to be plotted before you can see corresponding postition of the animal with cell activity!','ATTENTION');
    return;
elseif d.thresh==0 && size(d.ROIs,2)~=size(d.ROImeans,2) && d.dF==0
    msgbox('All ROIs need to be plotted before you can see corresponding postition of the animal with cell activity!','ATTENTION');
    return;
end

%plotting posterior trace
if v.Pspot==1
    a=figure; image(v.imd(1).cdata); hold on;
    plot(v.tracePplot(:,1),v.tracePplot(:,2),v.colorP);
    %plotting anterior trace
    plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA); hold off;
else
    a=figure; image(v.imd(1).cdata); hold on;
    %plotting anterior trace
    plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA); hold off;
end

%saving plot
% checking whether ROI traces had been saved before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn))
    tf(k)=strcmp('location',files(k).name);
end
if sum(tf)==0
    mkdir([d.pn '\location']);
else
    rmdir([d.pn '\location'],'s');
    mkdir([d.pn '\location']);
end
name=sprintf('mouse_trace');
path=[d.pn '/location/',name,'.png'];
path=regexprep(path,'\','/');
print(a,'-dpng','-r100',path); %-depsc for vector graphic

%calculating the amount of time the animal was out of view in percent
percOutside=round((length(v.traceA)-length(v.traceAplot))/length(v.traceA)*100,1); %v.traceAplot excludes values of zero, which means animal was out of view

%calculating traveled distance
x=diff(v.traceAplot(:,1));
x=sqrt(x.^2);
y=diff(v.traceAplot(:,2));
y=sqrt(y.^2);
dist=sqrt(x.^2+y.^2);
totalDistInPx=sum(dist(dist>1 & dist<40)); %movement is consider at least 1 pixel and at most 40 pixels at once

%pixel in cm
h=figure;image(v.imd(1).cdata);hold on;
uiwait(msgbox('Please define the length of one side of the testing area by dragging a line, right-clicking, select "Copy Position" and close the figure. Then press "Next", "Finish"!','Attention'));
a=imline;
uiwait(h);
cropped=clipboard('pastespecial');
testsizepixel=round(str2num(cell2mat(cropped.A_pastespecial)));
testsizepixel=round(sqrt((abs(testsizepixel(2,1)-testsizepixel(1,1)))^2+(abs(testsizepixel(2,2)-testsizepixel(1,2)))^2));
prompt = {'Enter real length in cm:'};
dlg_title = 'Input';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
testsizecm=str2num(cell2mat(answer));
factor=testsizecm/testsizepixel;
totalDistIncm=round(totalDistInPx*factor,1);

%calculating percent pause
pause=sum(dist(:) <= 1); % change 1 to any other number if wanted, 1 is one pixel movement
percPause=round(pause/length(v.traceA)*100,1); %percent in regards to the whole time

%velocity in cm/s
VelocityIncms=round(totalDistIncm/(length(v.traceAplot)/d.framerate),1); %mean velocity while it was visible


%function for defining compartments
[cood] = defineComp;

%plotting cell activity
%checking whether animal is out of bounds at times
if length(v.tracePplot)~=length(v.traceP) || length(v.traceAplot)~=length(v.traceA)
    % Construct a questdlg with two options
    choice = questdlg('Does the animal ever leave the testing area?', ...
        'Attention', ...
        'Yes','No','No');
    % Handle response
    switch choice
        case 'Yes'
            mleft=0;
        case 'No'
            if v.Pspot==1
                cood=find(v.traceP==0);
                for k=1:length(cood)
                    if k==1
                        row=find(v.traceP>0,1,'first');
                        v.traceP(cood(k),:)=v.traceP(row,:);
                    else
                        v.traceP(cood(k))=v.traceP(cood(k)-1);
                    end
                end
            end
            cood=find(v.traceA==0);
            for k=1:length(cood)
                if k==1
                    row=find(v.traceP>0,1,'first');
                    v.traceA(cood(k),:)=v.traceA(row,:);
                else
                    v.traceA(cood(k))=v.traceA(cood(k)-1);
                end
            end
            mleft=1;
    end
else
    mleft=1;
end
%function for plotting location of animal while specified cells are active
activityLocation(mleft,totalDistIncm,VelocityIncms,percPause,percOutside);
v.pushed=1; %signals to show original video again
msgbox('Tracing Completed. ROI traces saved in folder "location"!','Success');
    

% --- Executes on button press in pushbutton37.                 IMPORT ROIs
function pushbutton37_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global p
%defining folder
%defining initial folder displayed in dialog window
if isempty(p.pnpreset)==1
    [p.pnpreset]=uigetdir(v.pn);
else
    [p.pnpreset]=uigetdir(p.pnpreset);
end
%loading preset
load([p.pnpreset '\tracingROIs']);
p.amount=amount;
p.name=name;
p.ROImask=ROImask;
p.import=1;
msgbox('Loading Complete.','Success');






%% BEHAVIORAL DETECTION


% --- Executes on button press in pushbutton29.            BUTTON DETECTION
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
d.stop=0;
%checks if a video file was selected
if v.pushed==0 && d.pushed==0
    msgbox('Please select folder first!','ERROR');
    return;
elseif v.pushed==0
    v.imd=[];
elseif v.pushed==1
    v.hsvA=[];
    v.hsvP=[];
end
if d.pushed==0
    d.imd=[];
    maxframes=size(v.imd,2);
else
    maxframes=size(d.imd,3);
end

if v.skdefined==0
    if d.help==1
        uiwait(msgbox('Please track behavior by pushing this button only! It will play the behavioral video while you push your self-defined shortkeys. Use the regular STOP button to STOP, but the BEHAVIORAL DETECTION button to continue!','Attention'));
    end
    %Question how many
    prompt = {'How many behaviors would you like to track? (8 maximum)'};
    dlg_title = 'Amount';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);
    if str2num(cell2mat(answer))>8
        uiwait(msgbox('Please define only up to 8 behaviors!'));
        return
    end
    v.amount=str2num(cell2mat(answer));
    %loop of naming behaviors
    v.shortkey=cell(1,v.amount);
    v.name=cell(1,v.amount);
    for k=1:v.amount
        %shortkey
        str=sprintf('Please define shortkey No. %d.',k);
        prompt = {str};
        dlg_title = 'Shortkey';
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        v.shortkey{1,k}=answer;
        %name of ROI
        prompt = {'What do you want to call it?'};
        dlg_title = 'Name';
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        v.name{1,k}=answer;
        %initializing event counter
        v.events.(char(v.name{1,k})) = zeros(size(v.imd,2),1);
    end
    v.skdefined=1;
end
    

if  v.pushed>=1
    v.play=1;
    axes(handles.axes2);
    for k=round(handles.slider7.Value):size(v.imd,2)
        v.k=k;
        image(v.imd(k).cdata); %original video
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
        if k==size(v.imd,2)
            d.stop=1;
            d.play=0;
            v.play=0;
        end
        if d.stop==1
            d.stop=1;
            d.play=0;
            a=figure;
            str={};
            for j=1:v.amount
                v.events.(char(v.name{1,j}))(v.events.(char(v.name{1,j}))>1)=1; %in case event was registered multiple times at the same frame
                %timebars
                bars=diff(v.events.(char(v.name{1,j})));
                bars(size(v.imd,2))=0;
                v.barstart.(char(v.name{1,j}))=find(bars==1);
                if numel(find(bars==1))>numel(find(bars==-1))
                    v.barstart.(char(v.name{1,j}))=v.barstart.(char(v.name{1,j}))(1:numel(find(bars==-1)),1);
                end
                v.barwidth.(char(v.name{1,j}))=find(bars==-1)-v.barstart.(char(v.name{1,j}));
                area(1:size(v.imd,2),v.events.(char(v.name{1,j})),'edgecolor',d.colors{1,j},'facecolor',d.colors{1,j},'facealpha',0.5),hold on;
                str(end+1)={char(v.name{1,j})}; %#ok<AGROW>
            end
            xlabel('Time in seconds');
            tlabel=get(gca,'XTickLabel');
            for i=1:length(tlabel)
                tlabel{i,1}=str2num(tlabel{i,1});
            end
                tlabel=cell2mat(tlabel);
                tlabel=tlabel./d.framerate;
                set(gca,'XTickLabel',tlabel);
                legend(str);
                hold off;
                %saving plot
                name=sprintf('mouse_behavior');
                path=[d.pn '/',name,'.png'];
                path=regexprep(path,'\','/');
                print(a,'-dpng','-r100',path); %-depsc for vector graphic
                %saving positions at ROIs
                filename=[d.pn '\Behavior'];
                Amount=v.amount;
                Events=v.events;
                Shortkeys=v.shortkey;
                BehavNames=v.name;
                barstart=v.barstart;
                barwidth=v.barwidth;
                save(filename, 'Amount','Events','Shortkeys','BehavNames','barstart','barwidth');
                v.behav=1;
                uiwait(msgbox('Plot and settings saved! You can now plot the behavior with the ROI traces together!'));
            return;
        end
    end
end




% --- Executes on key press with focus on pushbutton29 and none of its controls.
function pushbutton29_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global v
% determine the key that was pressed 
 keyPressed = eventdata.Key;

 for k=1:v.amount
     if strcmpi(keyPressed,v.shortkey{1,k})
         v.events.(char(v.name{1,k}))(v.k)=1;
     end
 end


% --- Executes on button press in pushbutton35.       RESET BEHAV DETECTION
function pushbutton35_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
v.amount=[];
v.shortkey=[];
v.name=[];
v.events=[];
v.skdefined=0;
v.behav=0;
msgbox('Behavioral detection was reset!');






% --------------------------------------------------------------------
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Documentation_Callback(hObject, eventdata, handles)
% hObject    handle to Documentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

path=cd;
filePattern = fullfile(path, '*.docx');
Files = dir(filePattern);
if isempty(Files)==1
   msgbox('Please change the current directory to ./roisub!');
   return;
end
fn = Files(1).name;
winopen(fn);
