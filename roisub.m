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
%       -crop the video to the area in which the mouse is moving by pushing
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
%       the desired colored spot from the back of the mouse by using the 
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
%       mouse during that frame. After you push STOP or the video ends, you
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
%       neurons in task performing mice using wide-field calcium imaging.'
%       
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roisub

% Last Modified by GUIDE v2.5 23-Jan-2017 18:28:29

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
d.pre=0; %no preprocessing
d.mip=0; %no maximum intensity projection
d.pn=[]; %no CI video path
d.ROIv=0; %no ROI values were loaded

%clear axes
cla(handles.axes1,'reset');
%resets frame slider
handles.slider7.Value=1;
%resets values of low in/out, high in/out to start values
handles.slider5.Value=0;
handles.slider15.Value=1;
handles.slider6.Value=0;
handles.slider16.Value=1;

if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end

% ms.UseParallel = true; %initializes parallel processing

%defining initial folder displayed in dialog window
if isempty(p.pn)==1;
    [d.pn]=uigetdir('F:\jenni\Documents\PhD PROJECT\Calcium Imaging\doric camera\');
else
    [d.pn]=uigetdir(p.pn);
end

%clears old behavioral video if new calcium imaging video is loaded
if v.pushed==1 && strcmp(v.pn,d.pn)==0;
    %clears cache
    %clears all global variables
    clear global v;
    %clears axes
    cla(handles.axes2,'reset');
    return;
end

%extracts filename
filePattern = fullfile(d.pn, '*.tif'); % *.tiff for 2-P
Files = dir(filePattern);
if size(Files,1)==0;
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
   if (strcmp(ME.identifier,'MATLAB:csvread:FileNotFound'))
        prompt = {'Enter framerate:'};
        dlg_title = 'Input';
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        d.framerate=str2num(cell2mat(answer));
   end
end 

%check whether video had been processed before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn));
    tf(k)=strcmp([d.fn(1:end-4) 'dFvid.mat'],files(k).name); %looking for dF/F processed video as .mat file
end
if sum(tf)>0; %if a file is found
    % Construct a questdlg with two options
    choice = questdlg('Would you like to load your last processed version?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    switch choice
        case 'YES'
            %loading delta F/F video
            h=msgbox('Loading... please wait!');
            load([d.pn '\' d.fn(1:end-4) 'dFvid']);
            d.imd=deltaFimd;
            close(h);
            d.pushed=1; %signals that CI video was loaded
            %loading MIP
            MaxIntensProj = max(d.imd, [], 3);
            stdIm = std(d.imd,0,3);
            d.mip=MaxIntensProj./stdIm;
            figure,imagesc(d.mip),title('Maximum Intensity Projection');
            %loading ROI mask
            %check whether ROI mask had been saved before
            files=dir(d.pn);
            tf=zeros(1,length(dir(d.pn)));
            for k=1:length(dir(d.pn));
                tf(k)=strcmp([d.fn(1:end-4) 'ROIs.mat'],files(k).name);
            end
            if sum(tf)>0;
                load([d.pn '\' d.fn(1:end-4) 'ROIs.mat']);
                d.mask=ROImask; %mask with all the ROIs
                d.ROIorder=ROIorder; %order of the ROIs
                d.labeled=ROIlabels; %mask with correctly ordered labels
                %plotting ROIs
                colors={[0    0.4471    0.7412],...
                    [0.8510    0.3255    0.0980],...
                    [0.9294    0.6941    0.1255],...
                    [0.4941    0.1843    0.5569],...
                    [0.4667    0.6745    0.1882],...
                    [0.3020    0.7451    0.9333],...
                    [0.6353    0.0784    0.1843],...
                    [0.6784    0.9216    1.0000]};

                singleFrame=d.imd(:,:,round(handles.slider7.Value));
                axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                B=bwboundaries(d.mask); %boundaries of ROIs
                stat = regionprops(d.labeled,'Centroid');
                d.b=cell(length(B),1);
                d.c=cell(length(B),1);
                colors=repmat(colors,1,ceil(length(B)/8));
                for j = 1 : length(B);
                    d.b{j,1} = B{j};
                    d.c{j,1} = stat(d.ROIorder(j)).Centroid;
                    plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
                    text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
                end
                hold off;
                %calculating background
                bg=cell(size(d.imd,3),1);
                d.bg=cell(size(d.imd,3),1);
                background=d.mask;
                background(background==1)=2;
                background(background==0)=1;
                background(background==2)=0;
                h=waitbar(0,'Labeling background');
                for k = 1:size(d.imd,3);
                    % You can only multiply integers if they are of the same type.
                    nn = find(background==1);
                    background = cast(background, class(d.imd(:,:,1)));
                    d.background{k,1} = background .* d.imd(:,:,k);
                    d.bg{k,1}=d.background{k,1}(nn);
                    waitbar(k/size(d.imd,3),h);
                end
                close(h);
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined
                d.load=1; %signals that a ROI mask was loaded
            end
            %loading ROI values
            %check whether ROI values had been saved before
            files=dir(d.pn);
            tf=zeros(1,length(dir(d.pn)));
            for k=1:length(dir(d.pn));
                tf(k)=strcmp([d.fn(1:end-4) 'ROIvalues.mat'],files(k).name);
            end
            if sum(tf)>0;
                load([d.pn '\' d.fn(1:end-4) 'ROIvalues.mat']);
                d.ROIs=ROIvalues; %ROI values trhoughout the video
            end
            d.ROIv=1;
            %loading original calcium imaging video
            % Construct a questdlg with two options
            choice = questdlg('Would you also like to load the original calcium imaging video?', ...
                'Attention', ...
                'YES','NO','YES');
            % Handle response
            switch choice
                case 'YES'
                    if length(Files)==1;
                        %putting each frame into variable 'Images'
                        h=waitbar(0,'Loading');
                        for k = 1:frames;
                            % Read in image into an array.
                            fullFileName = fullfile([d.pn '\' d.fn]);
                            Image = imread(fullFileName,k);
                            % Check to see if it's an 8-bit image needed later for scaling).
                            if strcmpi(class(Image), 'uint8')
                                % Flag for 256 gray levels.
                                eightBit = true;
                            else
                                eightBit = false;
                            end
                            if eightBit
                                Images = Image;
                            else
                            Imaged=double(Image);
                            Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
                            end
                            imd(:,:,k) = Images;
                            waitbar(k/frames,h);
                        end
                        close(h);
                        d.origCI=imd;
                    else
                        %putting each frame into variable 'images'
                        h=waitbar(0,'Loading');
                        for k = 1:length(Files);
                            waitbar(k/length(Files),h);
                            baseFileName = Files(k).name;
                            fullFileName = fullfile([d.pn '\' baseFileName]);
                            Image = imread(fullFileName); 
                            % Check to see if it's an 8-bit image needed later for scaling).
                            if strcmpi(class(Image), 'uint8')
                                % Flag for 256 gray levels.
                                eightBit = true;
                            else
                                eightBit = false;
                            end
                            if eightBit
                                Images = Image;
                            else
                            Imaged=double(Image);
                            Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
                            end
                            imd(:,:,k) = Images;
                        end
                        close(h);
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
            if length(Files)==1;
                %putting each frame into variable 'Images'
                h=waitbar(0,'Loading');
                for k = 1:frames;
                    % Read in image into an array.
                    fullFileName = fullfile([d.pn '\' d.fn]);
                    Image = imread(fullFileName,k);
                    % Check to see if it's an 8-bit image needed later for scaling).
                    if strcmpi(class(Image), 'uint8')
                        % Flag for 256 gray levels.
                        eightBit = true;
                    else
                        eightBit = false;
                    end
                    if eightBit
                        Images = Image;
                    else
                    Imaged=double(Image);
                    Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
                    end
                    d.imd(:,:,k) = Images;
                    waitbar(k/frames,h);
                end
                close(h);

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
            else
                %putting each frame into variable 'images'
                h=waitbar(0,'Loading');
                for k = 1:length(Files);
                    waitbar(k/length(Files),h);
                    baseFileName = Files(k).name;
                    fullFileName = fullfile([d.pn '\' baseFileName]);
                    Image = imread(fullFileName); 
                    % Check to see if it's an 8-bit image needed later for scaling).
                    if strcmpi(class(Image), 'uint8')
                        % Flag for 256 gray levels.
                        eightBit = true;
                    else
                        eightBit = false;
                    end
                    if eightBit
                        Images = Image;
                    else
                    Imaged=double(Image);
                    Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
                    end
                    d.imd(:,:,k) = Images;
                end
                close(h);

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

elseif length(Files)==1;
    %putting each frame into variable 'Images'
    h=waitbar(0,'Loading');
    for k = 1:frames;
        % Read in image into an array.
        fullFileName = fullfile([d.pn '\' d.fn]);
        Image = imread(fullFileName,k);
        % Check to see if it's an 8-bit image needed later for scaling).
        if strcmpi(class(Image), 'uint8')
            % Flag for 256 gray levels.
            eightBit = true;
        else
            eightBit = false;
        end
        if eightBit
            Images = Image;
        else
        Imaged=double(Image);
        Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
        end
        d.imd(:,:,k) = Images;
        waitbar(k/frames,h);
    end
    close(h);
    
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
else
    %putting each frame into variable 'images'
    h=waitbar(0,'Loading');
    for k = 1:length(Files);
        waitbar(k/length(Files),h);
        baseFileName = Files(k).name;
        fullFileName = fullfile([d.pn '\' baseFileName]);
        Image = imread(fullFileName); 
        % Check to see if it's an 8-bit image needed later for scaling).
        if strcmpi(class(Image), 'uint8')
            % Flag for 256 gray levels.
            eightBit = true;
        else
            eightBit = false;
        end
        if eightBit
            Images = Image;
        else
        Imaged=double(Image);
        Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
        end
        d.imd(:,:,k) = Images;
    end
    close(h);
    
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
p.pn=d.pn;

titleLabel = ['Calcium imaging video: ' d.fn]; %filename as title
set(handles.text27, 'String', titleLabel);
%if you hover with the mouse over the filename, you can see the path
handles.text27.TooltipString=d.pn;
textLabel = sprintf('%d / %d', 1,size(d.imd,3));
set(handles.text36, 'String', textLabel);

msgbox('Loading Completed.','Success');






% --- Executes on slider movement.                           CHANGES LOW IN
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1;
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider5.Value changes low in value
if d.pushed==4 || d.roisdefined==1; %if ROIs were defined
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1);
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
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1;
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider6.Value changes low out value
if d.pushed==4 || d.roisdefined==1; %if ROIs were defined
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1);
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
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1;
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider15.Value changes high in value
if d.pushed==4 || d.roisdefined==1; %if ROIs were defined
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1);
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
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1;
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider16.Value changes high out value
if d.pushed==4 || d.roisdefined==1; %if ROIs were defined
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1);
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
if d.pushed==0;
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






% --- Executes on button press in pushbutton23.               PREPROCESSING
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
if d.pre==1;
    msgbox('You already did preprocessing!','ATTENTION');
    return;
end
%variable initialization
imd=cast(zeros(ceil(size(d.imd,1)*0.4),ceil(size(d.imd,2)*0.4),size(d.imd,3)),class(d.imd));
meanChange=diff(mean(mean(d.imd,1),2));

%Downsampling
h=waitbar(0,'Downsampling');
for k=1:size(d.imd,3);
    imd(:,:,k)=imresize(d.imd(:,:,k),0.4); %evt. medfilt2() as median filter, downsampling fixed with 0.4
    waitbar(k/size(d.imd,3),h);
end
close(h);

%Eliminating faulty frames
h=waitbar(0,'Eliminating faulty frames');
for k=1:size(meanChange,3);
    if meanChange(1,1,k)<-(5*median(abs(meanChange)/0.6745)) || meanChange(1,1,k)>5*median(abs(meanChange)/0.6745); %quiroga, if sudden change in brightness = faulty frame
        if k+1 <= size(meanChange,3) && (meanChange(1,1,k)~=meanChange(1,1,k+1)); %if it is the last frame
            imd(:,:,k+1)=imd(:,:,k);
%         elseif k+1 <= size(meanChange,3) && (meanChange(1,1,k)==meanChange(1,1,k+1));
%             imd(:,:,k+1)=imd(:,:,k+3); % k+3 when the glitch lasted 2 frames!
        else %for all other frames
            imd(:,:,k+1)=imd(:,:,k-1);
        end
    end
    waitbar(k/size(meanChange,3),h);
end
d.imd=imd;
close(h);

d.origCI=imresize(d.imd,0.805); %keeping this file stored as original video but resized since original video is bigger than the downsampled video

%flatfield correction
H = fspecial('average',round(.08*size(d.imd,1))); %8 % blur
a=(imfilter(d.imd(:,:,1),H,'replicate')); %blur frame totally
d.imd=uint16(single(max(max(d.imd(:,:,1))))*bsxfun(@rdivide,single(d.imd),single(a)));
s=size(d.imd); %cut middle 80 % of image
d.imd=d.imd(round(.1*s(1)):round(.9*s(1)),round(.1*s(2)):round(.9*s(2)),:);

%showing resulting frame
singleFrame=d.imd(:,:,round(handles.slider7.Value));
axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);

d.pre=1; %preprocessing was done
%plotting mean change along the video
meanChange=diff(mean(mean(d.imd,1),2));
h=figure,plot(squeeze(meanChange)),title('Mean brightness over frames'),xlabel('Number of frames'),ylabel('Brightness in uint16');
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
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
if d.pre==0;
    msgbox('Please do preprocessing before proceeding!','ATTENTION');
    return;
end
% adapted from source: http://de.mathworks.com/help/vision/examples/video-stabilization-using-point-feature-matching.html
if d.dF==1;
     msgbox('Please align before calculating dF/F.','Attention');
     return
end

if handles.radiobutton1.Value==1;
    %SURF feature detection to align images
    imgA = d.imd(:,:,1);
    imgC = cast(zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3)),class(d.imd));
    imgC(:,:,1) =  d.imd(:,:,1);
    %aligning images to first image
    h=waitbar(0,'Aligning images');
    for k=1:size(d.imd,3)-1;
        imgB=d.imd(:,:,k+1);
        % figure(1); imshowpair(imgA,imgB,'ColorChannels','red-cyan');
        %detecting SURF features in first image and following images
        pointsA = detectSURFFeatures(imgA);
        pointsB = detectSURFFeatures(imgB);
    %     if isempty(pointsA)==1;
    % %         pointsA = detectHarrisFeatures(imgA);
    % %         pointsB = detectHarrisFeatures(imgB);
    %         [optimizer,metric] = imregconfig('monomodal');
    %         for j=1:size(d.imd,3)-1;
    %             imgB=d.imd(:,:,j+1);
    %             imgC(:,:,j+1) = imregister(imgB,imgA,'rigid',optimizer,metric);
    %             waitbar(j/(size(d.imd,3)-1),h);
    %         end
    %         d.imd=imgC;singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    %         axes(handles.axes1); imshow(singleFrame);
    %         close(h);
    %         % d.pushed=2; %signals that images were aligned
    %         msgbox('Aligning Completed.','Success');
    %         break
    %     end
        %extract FREAK descriptors for the SURF features
        [featuresA, pointsA] = extractFeatures(imgA, pointsA);
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);
        %match features of both pictures
        indexPairs = matchFeatures(featuresA, featuresB);
        pointsA = pointsA(indexPairs(:, 1), :);
        pointsB = pointsB(indexPairs(:, 2), :);
        %extract location coordinates of matched points
        pointsA=pointsA.Location;
        pointsB=pointsB.Location;
        %if there are no matching points, set the matrix to zeros
        if isempty(pointsA)==1;
            pointsA=zeros(1,2);
        end
        if isempty(pointsB)==1;
            pointsB=zeros(1,2);
        end
        %calculate shifting vector from matched points, how was the points
        %shifted from A to B
        tvector=[round(mean(pointsA(:,2)-pointsB(:,2))) round(mean(pointsA(:,1)-pointsB(:,1)))];
        if sum(tvector)<=5 && sum(tvector)>=-5 || sum(tvector)>=100 || sum(tvector)<=-100; %boundaries for not changing current image
            imgC(:,:,k+1)=imgB;
        else
            imgC(:,:,k+1)=circshift(imgB,tvector);
        end
        % figure(1); imshowpair(imgA,imgC(:,:,k+1),'ColorChannels','red-cyan');
        waitbar(k/(size(d.imd,3)-1),h);
    end
    d.imd=imgC;
    %showing resulting frame
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    close(h);
else
    %Lucas Kanade algorithm to align images
    transform = 'euclidean';
    % parameters for ECC and Lucas-Kanade 
    par = [];
    par.levels =    2;
    par.iterations = 30;
    par.transform = transform;
    tmp= d.imd(:,:,1);
    imgC = cast(zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3)),class(d.imd));
    imgC(:,:,1) =  d.imd(:,:,1);
    h=waitbar(0,'Aligning images');
    for k=1:size(d.imd,3)-1;
        img=d.imd(:,:,k+1);
        [LKWarp]=iat_LucasKanade(img,tmp,par);
        % Compute the warped image and visualize the error
        [wimageLK, supportLK] = iat_inverse_warping(img, LKWarp, par.transform, 1:size(tmp,2),1:size(tmp,1));
%         % draw mosaic
%         LKMosaic = iat_mosaic(tmp,img,[LKWarp; 0 0 1]);
        imgC(:,:,k)=wimageLK;
        waitbar(k/(size(d.imd,3)-1),h);
    end
    d.imd=imgC;
    %showing resulting frame
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    close(h);
end


d.align=1; %signals that images were aligned
msgbox('Aligning Completed.','Success');
if d.pushed==4;
    %resets all varibles needed for selecting ROIs
    d.bcount=0; %signals ROI button was not pressed
    d.pushed=1; %signals video was loaded
    d.ROIs=[];
    d.labeled = zeros(size(d.imd,1),size(d.imd,2));
    d.bg=[];
    d.b=[];
    d.c=[];
    d.roisdefined=0; %signals no ROIs were selected
    msgbox('Please re-select ROIs!','ATTENTION');
    return;
end


% --- Executes on button press in pushbutton28.            RESETS ALIGNMENT
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global d
d.imd=d.origCI;
d.align=0; %signals that image alignment was reset
msgbox('Alignment reset!');


% --- Executes on button press in pushbutton25.                   DELTA F/F
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d

if d.pre==0;
    msgbox('Please do preprocessing before proceeding!','ATTENTION');
    return;
end

if d.dF==1;
    msgbox('You already did delta F/F calculation!','ATTENTION');
    return;
end

%setting aligned images as original CI video
if d.align==1;
    d.origCI=d.imd;
end

%deltaF/F
h=waitbar(0,'Calculating deltaF/F');
Fmean=mean(d.imd(:,:,1:100:end),3); %mean frame of whole video
imddF=bsxfun(@rdivide,bsxfun(@minus,double(d.imd),Fmean),Fmean); %frame minus meanframe divided by meanframe
    %temporal filter below was removed because of artifacts
    % [bFilt,aFilt] = butter(4,.5, 'low');
    % 
    % for kr=1:size(imddF,1)
    %     for kc=1:size(imddF,2)
    %        imddF(kr,kc,:)=filtfilt(bFilt,aFilt,imddF(kr,kc,:)); %temporal low-passing
    %     end
    % %     disp(kr);
    % end

hhh = fspecial('gaussian', 5, 5); %gaussian blur
%SE = strel('disk', 15);

for k=1:size(d.imd,3);
%    imddF(:,:,k)=imtophat(imddF(:,:,k),SE);
%     imddF(imddF(:,:,k)<(max(max(imddF(:,:,k)))*0.5))=0;
    imddF(:,:,k)=imfilter(imddF(:,:,k),hhh); %filter taken from miniscope msRun ()
%     IM=imbothat(imddF(:,:,k),SE);
%     imddF(:,:,k)=imsubtract(imddF(:,:,k),IM);
%     imddF(:,:,k)=imclearborder(imddF(:,:,k),8);
    waitbar(k/size(d.imd,3),h);
end
d.imd=imddF;
close(h);

%saving deltaF video
h=msgbox('Program might seem unresponsive, please wait!');
filename=[d.pn '\' d.fn(1:end-4) 'dFvid'];
deltaFimd=d.imd;
save(filename, 'deltaFimd');
%saving whether images were aligned
filename=[d.pn '\' d.fn(1:end-4) 'vidalign'];
vidalign=d.align;
save(filename, 'vidalign');
close(h);

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
if handles.radiobutton2.Value==1;
    h=figure,imagesc(d.mip),title('Maximum Intensity Projection');
else
    h=figure,imagesc(d.mip),title('Maximum Intensity Projection');
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
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
if d.dF==0;
    msgbox('Please perform Delta F/F calculation before selection ROIs!','ATTENTION');
    return;
end

d.ROIv=0; %resetting ROIvalues loaded, since you are changing the ROI mask now

%colors for ROIs
colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};


%display instructions only if the button was pressed for the first time or
%a mistake was made and you want the help
if d.bcount==0 || d.valid==1 || d.help==1;
    d.valid=0;
    uiwait(msgbox('Please define the region of interest (ROI) by clicking around the area. The corners can be moved afterwards as well as the whole selected area. When satisfied with the selection please double-click!','Attention','modal'));
end

%displaying picture with previously marked ROIs
axes(handles.axes1);
if d.bcount>0;
    colors=repmat(colors,1,ceil(max(d.ROIorder)/8)); %selecting colors for ROIs
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable'); %determining the order of the ROIs
    singleFrame=d.mip./max(max(d.mip)); %getting picture into the value range from 0 to 1 for roipoly
    axes(handles.axes1); imshow(singleFrame);hold on;
    stat = regionprops(d.labeled,'Centroid'); %finding center of ROIs
    for k=1:size(d.b,1);
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end %drawing ROIs
    hold off;
    f=getframe(handles.axes1); %getting the MIP with ROI mask as one picture
    singleFrame=f.cdata;
elseif d.load==1;
    colors=repmat(colors,1,ceil(max(d.ROIorder)/8)); %selecting colors for ROIs
    singleFrame=d.mip./max(max(d.mip)); %getting picture into the value range from 0 to 1 for roipoly
    axes(handles.axes1); imshow(singleFrame);hold on;
    stat = regionprops(d.labeled,'Centroid'); %finding center of ROIs
    for k=1:size(d.b,1);
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end %drawing ROIs
    hold off;
    f=getframe(handles.axes1); %getting the MIP with ROI mask as one picture
    singleFrame=f.cdata;
elseif d.bcount==0;
    singleFrame=d.mip./max(max(d.mip)); %getting picture into the value range from 0 to 1 for roipoly
end

%manual ROI selection
ROI = roipoly(singleFrame);    %uint8 for CI_win_S1HL_02/20151118 & DORIC; int16 for CI_S1Hl_02
if d.bcount>0 || d.load==1; %resizing ROI since the figure from getframe is not the same resolution
    B=zeros(size(d.mip,1),size(d.mip,2));
    B=imresize(ROI, [size(d.mip,1) size(d.mip,2)]);
    ROI=B;
end
%check if ROI was selected correctly
if numel(find(ROI))==0;
    singleFrame=d.mip;
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    else
        axes(handles.axes1); imshow(singleFrame); hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for k=1:size(d.b,1);
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end
    hold off;
    d.valid=1;
    msgbox('Please select valid ROI! Check the instructions again.','ERROR');
    return;
end
%count times button is pressed
d.bcount=d.bcount+1;

if d.load==1; %if a ROI mask was loaded
    d.labeled = d.labeled+(ROI*(max(max(d.labeled))+1)); %labeling of ROIs
    d.mask = d.mask+ROI; %old ROI mask + new ROI mask
    %checking if ROIs are superimposed on each other
    if numel(find(d.mask>1))>0;
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
                if d.dF==1 || d.pre==1;
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                B=bwboundaries(d.mask); %boundaries of ROIs
                stat = regionprops(d.labeled,'Centroid');
                %check whether ROIs are touching
                if length(stat)>length(B);
                    d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
                    d.mask = d.mask-ROI;
                    singleFrame=d.mip;
                    if d.dF==1 || d.pre==1;
                        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                    else
                        axes(handles.axes1); imshow(singleFrame); hold on;
                    end
                    stat = regionprops(d.labeled,'Centroid');
                    for k=1:size(d.b,1);
                        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
                        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                    end
                    hold off;
                    msgbox('Please do not let ROIs touch!','ERROR');
                    return;
                end
                d.b=cell(length(B),1);
                d.c=cell(length(B),1);
                d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
                colors=repmat(colors,1,ceil(max(d.ROIorder)/8));
                for j = 1 : max(d.ROIorder);
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
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1;
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
                d.labeled(d.labeled<0)=0;
                d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
                stat = regionprops(d.labeled,'Centroid');
                for k=1:size(d.b,1);
                    d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
                    text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                end
                hold off;
                msgbox('Please do not superimpose ROIs!','ERROR');
                d.mask = d.mask-ROI;
                return;
        end
    else
        d.mask(d.mask>0)=1;
    end    

    %plotting ROIs
    singleFrame=d.mip;
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    else
        axes(handles.axes1); imshow(singleFrame); hold on;
    end
    B=bwboundaries(d.mask); %boundaries of ROIs
    stat = regionprops(d.labeled,'Centroid');
    %check whether ROIs are touching
    if length(stat)>length(B);
        d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
        d.mask = d.mask-ROI;
        singleFrame=d.mip;
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for k=1:size(d.b,1);
            d.c{k,1} = stat(d.ROIorder(k)).Centroid;
            plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
            text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
        end
        hold off;
        msgbox('Please do not let ROIs touch!','ERROR');
        return;
    end
    d.b=cell(length(B),1);
    d.c=cell(length(B),1);
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    colors=repmat(colors,1,ceil((max(max(d.labeled))+1)/8));
    for j = 1 : length(B);
        d.b{j,1} = B{j};
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end
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
    d.mask = d.mask+ROI;
    %checking if ROIs are superimposed on each other
    if numel(find(d.mask>1))>0;
        choice = questdlg('Would you like to remove this ROI?', ...
        'Attention', ...
        'YES','NO','YES');
        % Handle response
        switch choice
            case 'YES'
                d.mask=d.mask-(2*ROI);
                d.mask(d.mask<0)=0;
                d.labeled=bwlabel(d.mask);
                %plotting ROIs
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1;
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                B=bwboundaries(d.mask); %boundaries of ROIs
                stat = regionprops(d.labeled,'Centroid');
                %check whether ROIs are touching
                if length(stat)>length(B);
                    d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
                    d.mask = d.mask-ROI;
                    singleFrame=d.mip;
                    if d.dF==1 || d.pre==1;
                        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                    else
                        axes(handles.axes1); imshow(singleFrame); hold on;
                    end
                    stat = regionprops(d.labeled,'Centroid');
                    for k=1:size(d.b,1);
                        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
                        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                    end
                    hold off;
                    msgbox('Please do not let ROIs touch!','ERROR');
                    return;
                end
                d.b=cell(length(B),1);
                d.c=cell(length(B),1);
                d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
                colors=repmat(colors,1,ceil(max(d.ROIorder)/8));
                for j = 1 : max(d.ROIorder);
                    d.b{j,1} = B{j};
                    d.c{j,1} = stat(d.ROIorder(j)).Centroid;
                    plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
                    text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
                end
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
                if d.dF==1 || d.pre==1;
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                stat = regionprops(d.labeled,'Centroid');
                for k=1:size(d.b,1);
                    d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
                    text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                end
                hold off;
                msgbox('Please do not superimpose ROIs!','ERROR');
                return;
        end
    else
        d.mask(d.mask>0)=1;
    end
    

    %plotting ROIs
    singleFrame=d.mip;
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    else
        axes(handles.axes1); imshow(singleFrame); hold on;
    end
    B=bwboundaries(d.mask); %boundaries of ROIs
    stat = regionprops(d.labeled,'Centroid');
    %check whether ROIs are touching
    if length(stat)>length(B);
        d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
        d.mask = d.mask-ROI;
        singleFrame=d.mip;
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for k=1:size(d.b,1);
            d.c{k,1} = stat(d.ROIorder(k)).Centroid;
            plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
            text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
        end
        hold off;
        msgbox('Please do not let ROIs touch!','ERROR');
        return;
    end
    d.b=cell(length(B),1);
    d.c=cell(length(B),1);
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    colors=repmat(colors,1,ceil((max(max(d.labeled))+1)/8));
    for j = 1 : length(B);
        d.b{j,1} = B{j};
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end
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
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
%resets all varibles needed for selecting ROIs
d.bcount=0; %signals ROI button was not pressed
d.pushed=1; %signals video was loaded
d.ROIs=[];
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.labeled = zeros(size(d.imd,1),size(d.imd,2));
d.bg=[];
d.b=[];
d.c=[];
d.ROIorder=[];
d.roisdefined=0; %signals no ROIs were selected
d.load=0; %signals that no ROI mask was loaded

if d.align==1 && handles.radiobutton2.Value==1;
    imdMax=(1/(mean(mean(mean(d.imd))))+1/(max(max(max(d.imd)))))/2;
else
    imdMax=1/(max(max(max(d.imd))));
end

singleFrame=d.mip;
if d.dF==1;
    singleFrame=d.imd(:,:,round(handles.slider7.Value))*imdMax;
    axes(handles.axes1);imshow(singleFrame); colormap(handles.axes1, gray);
else
    axes(handles.axes1); imshow(singleFrame);
end
msgbox('ROIs cleared!','Success');





% --- Executes on button press in pushbutton27.          LOAD EXISTING ROIs
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global d
%resets all varibles needed for selecting ROIs
d.bcount=0; %signals ROI button was not pressed
d.pushed=1; %signals video was loaded
d.ROIs=[];
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.labeled = zeros(size(d.imd,1),size(d.imd,2));
d.bg=[];
d.b=[];
d.c=[];
d.ROIorder=[];
d.roisdefined=0; %signals no ROIs were selected
d.load=0; %signals that no ROI mask was loaded
d.ROIv=0; %no ROI values loaded

if d.pre==0;
    msgbox('Please do preprocessing & Delta F/F calculation before proceeding!','ATTENTION');
    return;
elseif d.dF==0;
    msgbox('Please do Delta F/F calculation before proceeding!','ATTENTION');
    return;
end

filepath=[d.pn '\'];
[fn,pn,~]=uigetfile([filepath '*.mat']);
%extracts filename
load([pn fn]);
d.mask=ROImask;
d.ROIorder=ROIorder;
d.labeled=ROIlabels;
%plotting ROIs
colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};

singleFrame=d.imd(:,:,round(handles.slider7.Value));
if d.dF==1 || d.pre==1;
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
else
    axes(handles.axes1); imshow(singleFrame); hold on;
end
B=bwboundaries(d.mask); %boundaries of ROIs
stat = regionprops(d.labeled,'Centroid');
d.b=cell(length(B),1);
d.c=cell(length(B),1);
colors=repmat(colors,1,ceil(length(B)/8));
for j = 1 : length(B);
    d.b{j,1} = B{j};
    d.c{j,1} = stat(d.ROIorder(j)).Centroid;
    plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
    text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
end
hold off;
d.pushed=4; %signals that ROIs were selected
d.roisdefined=1; %signals that ROIs were defined
d.load=1;
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





% --- Executes on button press in pushbutton14.             PLOT ROI VALUES
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
%check whether ROIs were selected
if d.roisdefined==0;
    msgbox('Please label ROIs first!','ERROR');
    return;
end
%check whether dF/F was calculated
if d.dF==0;
    msgbox('Please calculate Delta F/F first!','ERROR');
    return;
end


colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};

colorsb={[0    0.4    0.7],...
    [0.8    0.3    0.09],...
    [0.9    0.6    0.1],...
    [0.4    0.1    0.5],...
    [0.4    0.6    0.1],...
    [0.3    0.7    0.9],...
    [0.6    0.07   0.1],...
    [0.6    0.9    1]};

%checking whether ROI values had been saved before and no ROI was added
if d.ROIv==0;
    %labeling ROIs
    n=size(d.imd,3);
    numROIs=max(d.ROIorder); %number of ROIs
    d.imdrem=cell(size(d.imd,3),numROIs);
    d.ROIs=cell(size(d.imd,3),numROIs);
    h=waitbar(0,'Labeling ROIs');
    for j=1:n;
        for i=1:numROIs;
            ROIs=zeros(size(d.imd,1),size(d.imd,2));
            m = find(d.labeled==i);
            ROIs(m)=1;
            % You can only multiply integers if they are of the same type.
            ROIs = cast(ROIs, class(d.imd(:,:,1)));
            d.imdrem{j,i} = ROIs .* d.imd(:,:,j);
            d.ROIs{j,i}=d.imdrem{j,i}(m);
        end
        waitbar(j/size(d.imd,3),h);
    end
    close(h);
    %saving ROI values
    filename=[d.pn '\' d.fn(1:end-4) 'ROIvalues'];
    ROIvalues=d.ROIs;
    save(filename, 'ROIvalues');
end

% % %high band pass filter of ROIvalues
% % b=fir1(256,[400 5000]/(32000/2)); %detection threshold
% % temp=single(filter(b,1,d.ROImeans(:,1)));
% % %or
[b,a]=butter(1,0.01*(d.framerate/2),'high');
% % bla=filtfilt(b,a,d.ROImeans(:,1));
    
%dF/f and thresholded ROIs
if d.load==1;
    colors=repmat(colors,1,ceil(size(d.ROIs,2)/8));
    %background
    bg=cell(size(d.imd,3),1);
    d.bg=cell(size(d.imd,3),1);
    background=d.mask;
    background(background==1)=2;
    background(background==0)=1;
    background(background==2)=0;
    h=waitbar(0,'Labeling background');
    for k = 1:size(d.imd,3);
        % You can only multiply integers if they are of the same type.
        nn = find(background==1);
        background = cast(background, class(d.imd(:,:,1)));
        d.background{k,1} = background .* d.imd(:,:,k);
        d.bg{k,1}=d.background{k,1}(nn);
        waitbar(k/size(d.imd,3),h);
    end
    close(h);
    % calculate mean grey value of ROIs in percent
    d.ROImeans=zeros(size(d.ROIs,1),size(d.ROIs,2));
    d.bgmeans=zeros(size(d.ROIs,1),1);
    h=waitbar(0,'Calculating ROI values');
    for k=1:size(d.ROIs,2);
        for i=1:size(d.ROIs,1);
            d.ROImeans(i,k)=mean(d.ROIs{i,k});
            d.bgmean(i,1)=mean(d.bg{i,1});
            d.ROImeans(i,k)=(d.ROImeans(i,k)-d.bgmean(i,1))*100;
        end
        d.ROImeans(:,k)=filtfilt(b,a,d.ROImeans(:,k)); %high band pass filter
        waitbar(k/size(d.ROIs,2),h);
    end
    close(h);
    % plotting ROI values
    NoofSpikes=zeros(size(d.ROIs,2),1);
    spikes=cell(1,size(d.ROIs,2));
    ts=cell(1,size(d.ROIs,2));
    amp=cell(1,size(d.ROIs,2));
    %initializing that only 8 subplots will be in one figure
    onesub=(1:8);
    anysub=repmat(onesub,1,ceil(size(d.ROIs,2)/8));
    check=(9:8:100);
    check2=(8:8:100);

    figure('color','w');
    for j=1:size(d.ROIs,2);
        if ismember(j,check)==1;
            figure('color','w');
        end
        subplot(8,1,anysub(j));
        plot(d.ROImeans(:,j),'Color',colors{1,j}),hold on;
        axlim=get(gca,'YLim');
        ylim([-1 2*round(axlim(2)/2)]); %round to next even number
        if v.behav==1;
            axlim=get(gca,'YLim');
            for l=1:v.amount;
                for m=1:length(v.barstart.(char(v.name{1,l})));
                rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),axlim(1),v.barwidth.(char(v.name{1,l}))(m),axlim(2)*2],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
                end
            end
            plot(d.ROImeans(:,j),'Color',colors{1,j}),hold on;
        end
        strings=sprintf('ROI No.%d',j);
        %title('ROI values in percent');
        if ismember(j,check2)==1 || j==size(d.ROIs,2);
            xlabel('Time in seconds');
        end
        ylabel('%');
        legend(strings,'Location','eastoutside');
        tlabel=get(gca,'XTickLabel');
        for k=1:length(tlabel);
            tlabel{k,1}=str2num(tlabel{k,1});
        end
        tlabel=cell2mat(tlabel);
        tlabel=tlabel./d.framerate;
        set(gca,'XTickLabel',tlabel);
        set(gca, 'box', 'off');
        hold on;
        [y,x]=findpeaks(d.ROImeans(:,j),'MinPeakHeight',5*median(abs(d.ROImeans(:,j))/0.6745)); %quiroga spike detection formula
        spikes{1,j}=x;
        ts{1,j}=x/d.framerate;
        amp{1,j}=y;
        if isempty(x)==0;
            plot(x,max(d.ROImeans(:,j))+0.5,'k.');
        else
            spikes{1,j}=1;
        end
        %calculating number of spikes
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
    if v.behav==1;
        for l=1:v.amount;
            for m=1:length(v.barstart.(char(v.name{1,l})));
            rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),0,v.barwidth.(char(v.name{1,l}))(m),size(d.ROImeans,2)],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
            end
        end
    end
    for j=1:size(d.ROImeans,2);
        plot(spikes{1,j},j,'k.');
        hold on;
        b(spikes{1,j})=b(spikes{1,j})+1;
        title('Cell activity raster plot');
        xlabel('Time in seconds');
        ylabel('ROI number');
        xlim([0 round(size(d.imd,3))]);
        ylim([0 size(d.ROImeans,2)+1]);
    end
    tilabel=get(gca,'XTickLabel');
    for k=1:length(tilabel);
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
    ticlabel=get(gca,'XTickLabel');
    for k=1:length(ticlabel);
        ticlabel{k,1}=str2num(ticlabel{k,1});
    end
    ticlabel=cell2mat(ticlabel);
    ticlabel=ticlabel./d.framerate;
    set(gca,'XTickLabel',ticlabel);
    
    
    %dF/F and manual ROIs
elseif d.load==0;
    colors=repmat(colors,1,ceil(size(d.ROIs,2)/8));
    %background
    bg=cell(size(d.imd,3),1);
    d.bg=cell(size(d.imd,3),1);
    background=d.mask;
    background(background==1)=2;
    background(background==0)=1;
    background(background==2)=0;
    h=waitbar(0,'Labeling background');
    for k = 1:size(d.imd,3);
        % You can only multiply integers if they are of the same type.
        nn = find(background==1);
        background = cast(background, class(d.imd(:,:,1)));
        d.background{k,1} = background .* d.imd(:,:,k);
        d.bg{k,1}=d.background{k,1}(nn);
        waitbar(k/size(d.imd,3),h);
    end
    close(h);
    
    % calculate mean grey value of ROIs in percent
    d.ROImeans=zeros(size(d.ROIs,1),size(d.ROIs,2));
    d.bgmeans=zeros(size(d.ROIs,1),1);
    h=waitbar(0,'Calculating ROI values');
    for k=1:size(d.ROIs,2);
        for i=1:size(d.ROIs,1);
            d.ROImeans(i,k)=mean(d.ROIs{i,k});
            d.bgmean(i,1)=mean(d.bg{i,1});
            d.ROImeans(i,k)=(d.ROImeans(i,k)-d.bgmean(i,1))*100;
        end
        waitbar(k/size(d.ROIs,2),h);
    end
    close(h);
    % plotting ROI values
    NoofSpikes=zeros(size(d.ROIs,2),1);
    spikes=cell(1,size(d.ROIs,2));
    ts=cell(1,size(d.ROIs,2));
    amp=cell(1,size(d.ROIs,2));
    %initializing that only 8 subplots will be in one figure
    onesub=(1:8);
    anysub=repmat(onesub,1,ceil(size(d.ROIs,2)/8));
    check=(9:8:100);
    check2=(8:8:100);

    figure('color','w');
    for j=1:size(d.ROIs,2);
        if ismember(j,check)==1;
            figure('color','w');
        end
        subplot(8,1,anysub(j));
        plot(d.ROImeans(:,j),'Color',colors{1,j});
        axlim=get(gca,'YLim');
        ylim([-1 2*round(axlim(2)/2)]); %round to next even number
        if v.behav==1;
            axlim=get(gca,'YLim');
            for l=1:v.amount;
                for m=1:length(v.barstart.(char(v.name{1,l})));
                rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),axlim(1),v.barwidth.(char(v.name{1,l}))(m),axlim(2)*2],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
                end
            end
            plot(d.ROImeans(:,j),'Color',colors{1,j}),hold on;
        end
        strings=sprintf('ROI No.%d',j);
        %title('ROI values in percent');
        if ismember(j,check2)==1 || j==size(d.ROIs,2);
            xlabel('Time in seconds');
        end
        ylabel('%');
        legend(strings,'Location','eastoutside');
        tlabel=get(gca,'XTickLabel');
        for k=1:length(tlabel);
            tlabel{k,1}=str2num(tlabel{k,1});
        end
        tlabel=cell2mat(tlabel);
        tlabel=tlabel./d.framerate;
        set(gca,'XTickLabel',tlabel);
        set(gca, 'box', 'off');
        hold on;
        [y,x]=findpeaks(d.ROImeans(:,j),'MinPeakHeight',5*median(abs(d.ROImeans(:,j))/0.6745)); %quiroga spike detection formula
        spikes{1,j}=x;
        ts{1,j}=x/d.framerate;
        amp{1,j}=y;
        if isempty(x)==0;
            plot(x,max(d.ROImeans(:,j))+0.5,'k.');
        else
            spikes{1,j}=1;
        end
        %calculating number of spikes
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
    if v.behav==1;
        for l=1:v.amount;
            for m=1:length(v.barstart.(char(v.name{1,l})));
            rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),0,v.barwidth.(char(v.name{1,l}))(m),size(d.ROImeans,2)],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
            end
        end
    end
    for j=1:size(d.ROImeans,2);
        plot(spikes{1,j},j,'k.');
        hold on;
        b(spikes{1,j})=b(spikes{1,j})+1;
        title('Cell activity raster plot');
        xlabel('Time in seconds');
        ylabel('ROI number');
        xlim([0 round(size(d.imd,3))]);
        ylim([0 size(d.ROImeans,2)+1]);
    end
    tilabel=get(gca,'XTickLabel');
    for k=1:length(tilabel);
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
    ticlabel=get(gca,'XTickLabel');
    for k=1:length(ticlabel);
        ticlabel{k,1}=str2num(ticlabel{k,1});
    end
    ticlabel=cell2mat(ticlabel);
    ticlabel=ticlabel./d.framerate;
    set(gca,'XTickLabel',ticlabel);
end
%saving traces
% Construct a questdlg with two options
choice = questdlg('Would you like to save these traces?', ...
    'Attention', ...
    'YES','NO','YES');
% Handle response
switch choice
    case 'YES'
        files=dir(d.pn);
        tf=zeros(1,length(dir(d.pn)));
        for k=1:length(dir(d.pn));
            tf(k)=strcmp('traces',files(k).name);
        end
        if sum(tf)==0;
            mkdir([d.pn '\traces']);
            tnum=ceil(size(d.ROImeans,2)/8);
            hfnum=get(fig,'Number');
            numseries=(hfnum-tnum:1:hfnum-1);
            for j=1:tnum;
                figurenum=sprintf('-f%d',numseries(j));
                name=sprintf('traces_%d',j);
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
            end
            figurenum=sprintf('-f%d',hfnum);
            name=('rasterplot');
            path=[d.pn '/traces/',name,'.png'];
            path=regexprep(path,'\','/');
            print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
            
            %saving table
            filename=[d.pn '\traces\ROIs_' d.fn(1:end-4) '.xls'];
            ROInumber=cell(size(d.ROImeans,2),1);
            for k=1:size(d.ROImeans,2);
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
    
            msgbox('Done!','Attention');
        else
            if v.behav==1;
                tnum=ceil(size(d.ROImeans,2)/8);
                hfnum=get(fig,'Number');
                numseries=(hfnum-tnum:1:hfnum-1);
                for j=1:tnum;
                    name=sprintf('traces_behav_%d',j);
                    figurenum=sprintf('-f%d',numseries(j));
                    path=[d.pn '/traces/',name,'.png'];
                    path=regexprep(path,'\','/');
                    print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
                end
                name=('rasterplot_behav');
                figurenum=sprintf('-f%d',hfnum);
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
                msgbox('Done!','Attention');
            else
                rmdir([d.pn '\traces'],'s');
                mkdir([d.pn '\traces']);
                tnum=ceil(size(d.ROImeans,2)/8);
                hfnum=get(fig,'Number');
                numseries=(hfnum-tnum:1:hfnum-1);
                for j=1:tnum;
                    if v.behav==1;
                        name=sprintf('traces_behav_%d',j);
                    else
                        name=sprintf('traces_%d',j);
                    end
                    figurenum=sprintf('-f%d',numseries(j));
                    path=[d.pn '/traces/',name,'.png'];
                    path=regexprep(path,'\','/');
                    print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
                end
                if v.behav==1;
                    name=('rasterplot_behav');
                else
                    name=('rasterplot');
                end
                figurenum=sprintf('-f%d',hfnum);
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic

                %saving table
                filename=[d.pn '\traces\ROIs_' d.fn(1:end-4) '.xls'];
                ROInumber=cell(size(d.ROImeans,2),1);
                for k=1:size(d.ROImeans,2);
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

if d.align==1 && handles.radiobutton2.Value==1;
    imdMax=1/(mean(mean(mean(d.imd))));
else
    imdMax=1/(max(max(max(d.imd))));
end

if isempty(d.origCI)==1&&d.pushed==1;
    d.origCI=d.imd;
elseif isempty(d.origCI)==1&&d.pushed==4;
    d.origCI=[];
end



if d.dF==0; %saving video if it was not processed further
    %converting original CI video to double precision and to values between 1 and 0
    h=waitbar(0,'Saving calcium imaging video');
    origCIconv=double(d.origCI);
    origCIconv=origCIconv./max(max(max(origCIconv)));

    filename=[d.pn '\' d.fn(1:end-4)];
    v = VideoWriter(filename,'Grayscale AVI');
    v.FrameRate=d.framerate;
    open(v);
    for k=1:size(d.imd,3);
        singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
%             figure(100),imshow(singleFrame);
        writeVideo(v,singleFrame);
        waitbar(k/size(d.imd,3),h);
    end
    close(v);
    close(h);
%         close(gcf);
    msgbox('Saving video completed.');
elseif isempty(d.origCI)==1&&d.pushed==4;
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
            %defining dimensions of video
            frames=size(imfinfo([d.pn '\' d.fn]),1);
            if length(Files)==1;
                %putting each frame into variable 'Images'
                h=waitbar(0,'Loading');
                for k = 1:frames;
                    % Read in image into an array.
                    fullFileName = fullfile([d.pn '\' d.fn]);
                    Image = imread(fullFileName,k);
                    % Check to see if it's an 8-bit image needed later for scaling).
                    if strcmpi(class(Image), 'uint8')
                        % Flag for 256 gray levels.
                        eightBit = true;
                    else
                        eightBit = false;
                    end
                    if eightBit
                        Images = Image;
                    else
                    Imaged=double(Image);
                    Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
                    end
                    imd(:,:,k) = Images;
                    waitbar(k/frames,h);
                end
                close(h);
                d.origCI=imd;
            else
                %putting each frame into variable 'images'
                h=waitbar(0,'Loading');
                for k = 1:length(Files);
                    waitbar(k/length(Files),h);
                    baseFileName = Files(k).name;
                    fullFileName = fullfile([d.pn '\' baseFileName]);
                    Image = imread(fullFileName); 
                    % Check to see if it's an 8-bit image needed later for scaling).
                    if strcmpi(class(Image), 'uint8')
                        % Flag for 256 gray levels.
                        eightBit = true;
                    else
                        eightBit = false;
                    end
                    if eightBit
                        Images = Image;
                    else
                    Imaged=double(Image);
                    Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
                    end
                    imd(:,:,k) = Images;
                end
                close(h);
                d.origCI=imd;
            end
            d.dF=1;
            load([d.pn '\' d.fn(1:end-4) 'vidalign']);
            d.align=vidalign;
            d.pre=1;

            msgbox('Loading complete!');
            
            % Construct a questdlg with two options
            choice = questdlg('Would you like to save only the dF/F video or the combined one?', ...
                'Attention', ...
                'Original','dF/F','Combined','Original');
            % Handle response
            switch choice
                case 'Original'
                    %converting original CI video to double precision and to values between 1 and 0
                    h=waitbar(0,'Saving calcium imaging video');
                    origCIconv=double(d.origCI);
                    origCIconv=origCIconv./max(max(max(origCIconv)));

                    filename=[d.pn '\' d.fn(1:end-4)];
                    v = VideoWriter(filename,'Grayscale AVI');
                    v.FrameRate=d.framerate;
                    open(v);
                    for k=1:size(d.imd,3);
                        singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
            %             figure(100),imshow(singleFrame);
                        writeVideo(v,singleFrame);
                        waitbar(k/size(d.imd,3),h);
                    end
                    close(v);
                    close(h);
            %         close(gcf);
                    msgbox('Saving video completed.');
                case 'dF/F'
                    h=waitbar(0,'Saving calcium imaging video');
                    filename=[d.pn '\' d.fn(1:end-4) 'dF'];
                    v = VideoWriter(filename,'Grayscale AVI');
                    v.FrameRate=d.framerate;
                    open(v);
                    for k = 1:size(d.imd,3);
                        frame = d.imd(:,:,k)*imdMax; %scaling images so that values are between 0 and 1 and the maximum value of d.imd is almost 1 d.imd(:,:,k)*(floor((1/max(max(max(d.imd))))));
                        frame(frame<0)=0;

                        writeVideo(v,frame);
                        waitbar(k/size(d.imd,3),h);
                    end
                    close(v);
                    close(h);
                    msgbox('Saving video completed.');
                case 'Combined'
                    %converting original CI video to double precision and to values between 1 and 0
                    %checking whether original video was preprocessed because of dimensions
                    if size(d.origCI,1)~=size(d.imd,1);
                        %variable initialization
                        imd=cast(zeros(ceil(size(d.origCI,1)*0.4),ceil(size(d.origCI,2)*0.4),size(d.origCI,3)),class(d.origCI));
                        meanChange=diff(mean(mean(d.origCI,1),2));
                        %Downsampling
                        h=waitbar(0,'Downsampling of Original');
                        for k=1:size(d.origCI,3);
                            imd(:,:,k)=imresize(d.origCI(:,:,k),0.4); %evt. medfilt2() as median filter, downsampling fixed with 0.4
                            waitbar(k/size(d.origCI,3),h);
                        end
                        close(h);
                        %Eliminating faulty frames
                        h=waitbar(0,'Eliminating faulty frames from Original');
                        for k=1:size(meanChange,3);
                            if meanChange(1,1,k)<-(5*median(abs(meanChange)/0.6745)) || meanChange(1,1,k)>5*median(abs(meanChange)/0.6745);
                                if k+1 <= size(meanChange,3) && (meanChange(1,1,k)~=meanChange(1,1,k+1));
                                    imd(:,:,k+1)=imd(:,:,k);
                        %         elseif k+1 <= size(meanChange,3) && (meanChange(1,1,k)==meanChange(1,1,k+1));
                        %             imd(:,:,k+1)=imd(:,:,k+3); % k+3 when the glitch lasted 2 frames!
                                else
                                    imd(:,:,k+1)=imd(:,:,k-1);
                                end
                            end
                            waitbar(k/size(meanChange,3),h);
                        end
                        d.origCI=imd;
                        close(h);
                        d.origCI=imresize(d.origCI,0.805); %keeping this file stored as original video
                    end
                    h=waitbar(0,'Saving calcium imaging video');
                    origCIconv=double(d.origCI);
                    origCIconv=origCIconv./max(max(max(origCIconv)));
                    %converting dF/F video such that all pixels below 50% of absolute maximum
                    %intensity are zero
                    imdconv=zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3));
                    smallestAcceptableArea = 30;
                    structuringElement = strel('disk', 2);
                    hh=waitbar(0,'Converting dF/F calcium imaging video');
                    for k=1:size(d.imd,3);
                        frame=d.imd(:,:,k);
            %             frame(frame<(mean(mean(mean(d.imd)))*2))=0;
            %             mask = imclearborder(imclose(bwareaopen(frame,smallestAcceptableArea),structuringElement));
                        frame=frame.*d.mask;
                        frame(frame<(max(max(max(d.imd)))*0.25))=0;
                        imdconv(:,:,k)=frame;
                        waitbar(k/size(d.imd,3),hh);
                    end
                    close(hh);
                    %converting video such that values are between 1 and 0
                    if d.align==1 && handles.radiobutton2.Value==1;
                        imdMax=1/(mean(mean(mean(imdconv))));
                    else
                        imdMax=1/(max(max(max(imdconv))));
                    end
                    imdconv=imdconv.*imdMax;

                    filename=[d.pn '\' d.fn(1:end-4) 'combo'];
                    v = VideoWriter(filename,'Uncompressed AVI');
                    v.FrameRate=d.framerate;
                    open(v);
                    for k=1:size(d.imd,3);
                        singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
                        figure(100),imshow(singleFrame);
                        red = cat(3, ones(size(origCIconv(:,:,1))), zeros(size(origCIconv(:,:,1))), zeros(size(origCIconv(:,:,1))));
                        hold on 
                        hh = imshow(red); 
                        hold off
                        set(hh, 'AlphaData', imdconv(:,:,k));
                        f=getframe(gcf);
                        newframe=f.cdata;
                        writeVideo(v,singleFrame);
                        waitbar(k/size(d.imd,3),h);
                    end
                    close(v);
                    close(h);
                    close(gcf);
                    msgbox('Saving video completed.');
            end
            
        case 'NO'
            h=waitbar(0,'Saving calcium imaging video');
            filename=[d.pn '\' d.fn(1:end-4) 'dF'];
            v = VideoWriter(filename,'Grayscale AVI');
            v.FrameRate=d.framerate;
            open(v);
            for k = 1:size(d.imd,3);
                frame = d.imd(:,:,k)*imdMax; %scaling images so that values are between 0 and 1 and the maximum value of d.imd is almost 1 d.imd(:,:,k)*(floor((1/max(max(max(d.imd))))));
                frame(frame<0)=0;

                writeVideo(v,frame);
                waitbar(k/size(d.imd,3),h);
            end
            close(v);
            close(h);
            msgbox('Saving video completed.');
    end
else
    % Construct a questdlg with two options
    choice = questdlg('Would you like to save only the dF/F video or the combined one?', ...
        'Attention', ...
        'Original','dF/F','Combined','Original');
    % Handle response
    switch choice
        case 'Original'
            %converting original CI video to double precision and to values between 1 and 0
            h=waitbar(0,'Saving calcium imaging video');
            origCIconv=double(d.origCI);
            origCIconv=origCIconv./max(max(max(origCIconv)));

            filename=[d.pn '\' d.fn(1:end-4)];
            v = VideoWriter(filename,'Grayscale AVI');
            v.FrameRate=d.framerate;
            open(v);
            for k=1:size(d.imd,3);
                singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    %             figure(100),imshow(singleFrame);
                writeVideo(v,singleFrame);
                waitbar(k/size(d.imd,3),h);
            end
            close(v);
            close(h);
    %         close(gcf);
            msgbox('Saving video completed.');
        case 'dF/F'
            h=waitbar(0,'Saving calcium imaging video');
            filename=[d.pn '\' d.fn(1:end-4) 'dF'];
            v = VideoWriter(filename,'Grayscale AVI');
            v.FrameRate=d.framerate;
            open(v);
            for k = 1:size(d.imd,3);
                frame = d.imd(:,:,k)*imdMax; %scaling images so that values are between 0 and 1 and the maximum value of d.imd is almost 1 d.imd(:,:,k)*(floor((1/max(max(max(d.imd))))));
                frame(frame<0)=0;

                writeVideo(v,frame);
                waitbar(k/size(d.imd,3),h);
            end
            close(v);
            close(h);
            msgbox('Saving video completed.');
        case 'Combined'
            %converting original CI video to double precision and to values between 1 and 0
            %checking whether original video was preprocessed because of dimensions
            if size(d.origCI,1)~=size(d.imd,1);
                %variable initialization
                imd=cast(zeros(ceil(size(d.origCI,1)*0.4),ceil(size(d.origCI,2)*0.4),size(d.origCI,3)),class(d.origCI));
                meanChange=diff(mean(mean(d.origCI,1),2));
                %Downsampling
                h=waitbar(0,'Downsampling of Original');
                for k=1:size(d.origCI,3);
                    imd(:,:,k)=imresize(d.origCI(:,:,k),0.4); %evt. medfilt2() as median filter, downsampling fixed with 0.4
                    waitbar(k/size(d.origCI,3),h);
                end
                close(h);
                %Eliminating faulty frames
                h=waitbar(0,'Eliminating faulty frames from Original');
                for k=1:size(meanChange,3);
                    if meanChange(1,1,k)<-(5*median(abs(meanChange)/0.6745)) || meanChange(1,1,k)>5*median(abs(meanChange)/0.6745);
                        if k+1 <= size(meanChange,3) && (meanChange(1,1,k)~=meanChange(1,1,k+1));
                            imd(:,:,k+1)=imd(:,:,k);
                %         elseif k+1 <= size(meanChange,3) && (meanChange(1,1,k)==meanChange(1,1,k+1));
                %             imd(:,:,k+1)=imd(:,:,k+3); % k+3 when the glitch lasted 2 frames!
                        else
                            imd(:,:,k+1)=imd(:,:,k-1);
                        end
                    end
                    waitbar(k/size(meanChange,3),h);
                end
                d.origCI=imd;
                close(h);
                d.origCI=imresize(d.origCI,0.805); %keeping this file stored as original video
            end
            h=waitbar(0,'Saving calcium imaging video');
            origCIconv=double(d.origCI);
            origCIconv=origCIconv./max(max(max(origCIconv)));
            %converting dF/F video such that all pixels below 50% of absolute maximum
            %intensity are zero
            imdconv=zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3));
            smallestAcceptableArea = 30;
            structuringElement = strel('disk', 2);
            hh=waitbar(0,'Converting dF/F calcium imaging video');
            for k=1:size(d.imd,3);
                frame=d.imd(:,:,k);
    %             frame(frame<(mean(mean(mean(d.imd)))*2))=0;
    %             mask = imclearborder(imclose(bwareaopen(frame,smallestAcceptableArea),structuringElement));
                frame=frame.*d.mask;
                frame(frame<(max(max(max(d.imd)))*0.25))=0;
                imdconv(:,:,k)=frame;
                waitbar(k/size(d.imd,3),hh);
            end
            close(hh);
            %converting video such that values are between 1 and 0
            if d.align==1 && handles.radiobutton2.Value==1;
                imdMax=1/(mean(mean(mean(imdconv))));
            else
                imdMax=1/(max(max(max(imdconv))));
            end
            imdconv=imdconv.*imdMax;

            filename=[d.pn '\' d.fn(1:end-4) 'combo'];
            v = VideoWriter(filename,'Uncompressed AVI');
            v.FrameRate=d.framerate;
            open(v);
            for k=1:size(d.imd,3);
                singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
                figure(100),imshow(singleFrame);
                red = cat(3, ones(size(origCIconv(:,:,1))), zeros(size(origCIconv(:,:,1))), zeros(size(origCIconv(:,:,1))));
                hold on 
                hh = imshow(red); 
                hold off
                set(hh, 'AlphaData', imdconv(:,:,k));
                f=getframe(gcf);
                newframe=f.cdata;
                writeVideo(v,singleFrame);
                waitbar(k/size(d.imd,3),h);
            end
            close(v);
            close(h);
            close(gcf);
            msgbox('Saving video completed.');
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
if d.pushed==0 && v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if v.pushed==0;
    v.imd=[];
    nframes=[];
elseif v.pushed==1;
    v.hsvA=[];
    v.hsvP=[];
    nframes=size(v.imd,2);
elseif v.pushed>=1;
    nframes=size(v.imd,2);
end
if d.pushed==0;
    d.imd=[];
    maxframes=size(v.imd,2);
    handles.slider7.Max=maxframes;
else
    maxframes=size(d.imd,3);
    handles.slider7.Max=maxframes;
end

if d.align==1 && handles.radiobutton2.Value==1;
    imdMax=(1/(mean(mean(mean(d.imd))))+1/(max(max(max(d.imd)))))/2;
else
    imdMax=1/(max(max(max(d.imd))));
end
cla(handles.axes1);
cla(handles.axes2);
colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};
if d.pushed==4;
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    colors=repmat(colors,1,(ceil(size(d.b,1)/8)));
end

if d.pre==1 && d.pushed==1;
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    axes(handles.axes1);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif d.pushed==1;
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif d.pushed==4;
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    axes(handles.axes1);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame);hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for k=1:size(d.b,1);
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end
    hold off;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
end
if v.pushed==1 && d.pushed>=1;
    axes(handles.axes2); image(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata); %original video
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed==1;
    axes(handles.axes2); image(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata); %original video
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed==2;
    v.valueThresholdLow=handles.slider9.Value; %slider9 value for value threshold low
    %other slider values
    v.hueThresholdLow = handles.slider13.Value;
    v.hueThresholdHigh = handles.slider14.Value;
    v.saturationThresholdLow = handles.slider12.Value;
    v.saturationThresholdHigh = handles.slider11.Value;
    v.valueThresholdHigh = handles.slider10.Value;

    % Convert RGB image to HSV
    hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);

    % Now apply each color band's particular thresholds to the color band
    hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
    saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
    valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

    % Combine the masks to find where all 3 are "true."
    % Then we will have the mask of only the green parts of the image.
    coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

    % Filter out small objects.
    smallestAcceptableArea = 50;
    % Get rid of small objects.  Note: bwareaopen returns a logical.
    coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
    % Smooth the border using a morphological closing operation, imclose().
    structuringElement = strel('disk', 4);
    coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
    % Fill in any holes in the regions, since they are most likely green also.
    coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

    % You can only multiply integers if they are of the same type.
    % (coloredObjectsMask is a logical array.)
    % We need to convert the type of coloredObjectsMask to the same data type as hImage.
    % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
    coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

    % Use the colored object mask to mask out the colored-only portions of the rgb image.
    maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
    maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
    maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
    % Concatenate the masked color bands to form the rgb image.
    maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

    %showing thresholded image in GUI
    if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
        axes(handles.axes2); imshow(maskedRGBImage); hold on;
        str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
        text(20,20,str,'Color','r');
        hold off;
    else
        axes(handles.axes2); imshow(maskedRGBImage);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed==3;
    v.valueThresholdLow=handles.slider9.Value; %slider9 value for value threshold low
    %other slider values
    v.hueThresholdLow = handles.slider13.Value;
    v.hueThresholdHigh = handles.slider14.Value;
    v.saturationThresholdLow = handles.slider12.Value;
    v.saturationThresholdHigh = handles.slider11.Value;
    v.valueThresholdHigh = handles.slider10.Value;

    % Convert RGB image to HSV
    hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);

    % Now apply each color band's particular thresholds to the color band
    hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
    saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
    valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

    % Combine the masks to find where all 3 are "true."
    % Then we will have the mask of only the green parts of the image.
    coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

    % Filter out small objects.
    smallestAcceptableArea = 50;
    % Get rid of small objects.  Note: bwareaopen returns a logical.
    coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
    % Smooth the border using a morphological closing operation, imclose().
    structuringElement = strel('disk', 4);
    coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
    % Fill in any holes in the regions, since they are most likely green also.
    coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

    % You can only multiply integers if they are of the same type.
    % (coloredObjectsMask is a logical array.)
    % We need to convert the type of coloredObjectsMask to the same data type as hImage.
    % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
    coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

    % Use the colored object mask to mask out the colored-only portions of the rgb image.
    maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
    maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
    maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
    % Concatenate the masked color bands to form the rgb image.
    maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

    %showing thresholded image in GUI
    if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
        axes(handles.axes2); imshow(maskedRGBImage); hold on;
        str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
        text(20,20,str,'Color','r');
        hold off;
    else
        axes(handles.axes2); imshow(maskedRGBImage);
    end
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
if v.pushed==0 && d.pushed==0;
    msgbox('Please select folder first!','ERROR');
    return;
elseif v.pushed==0;
    v.imd=[];
    nframes=[];
elseif v.pushed==1;
    v.hsvA=[];
    v.hsvP=[];
    nframes=size(v.imd,2);
elseif v.pushed>=1;
    nframes=size(v.imd,2);
end
if d.pushed==0;
    d.imd=[];
    maxframes=size(v.imd,2);
else
    maxframes=size(d.imd,3);
end

if d.align==1 && handles.radiobutton2.Value==1;
    imdMax=(1/(mean(mean(mean(d.imd))))+1/(max(max(max(d.imd)))))/2;
else
    imdMax=1/(max(max(max(d.imd))));
end
cla(handles.axes1);
cla(handles.axes2);
colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};
if d.pushed==4;
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    colors=repmat(colors,1,ceil(size(d.b,1)/8));
end

%if both videos were loaded
if v.pushed==1 && d.pre==1 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
        axes(handles.axes2);
        image(v.imd(round(k*round((nframes/maxframes),2))).cdata); %original video
        axes(handles.axes1); %thresholded video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            axes(handles.axes1); imshow(singleFrame);
        end
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
elseif v.pushed==1 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
        axes(handles.axes2);
        image(v.imd(round(k*round((nframes/maxframes),2))).cdata); %original video
        axes(handles.axes1); %original video
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
elseif v.pushed==1 && d.pushed==4;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
        axes(handles.axes2);
        image(v.imd(round(k*round((nframes/maxframes),2))).cdata); %original video
        axes(handles.axes1); %ROIs with video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
        else
            imshow(singleFrame);hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for j=1:size(d.b,1);
            d.c{j,1} = stat(d.ROIorder(j)).Centroid;
            plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
            text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
        end
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
elseif v.pushed==2 && d.pre==1 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
        v.valueThresholdLow=handles.slider9.Value; %slider9 value for value threshold low
        %other slider values
        v.hueThresholdLow = handles.slider13.Value;
        v.hueThresholdHigh = handles.slider14.Value;
        v.saturationThresholdLow = handles.slider12.Value;
        v.saturationThresholdHigh = handles.slider11.Value;
        v.valueThresholdHigh = handles.slider10.Value;

        % Convert RGB image to HSV
        hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);

        % Now apply each color band's particular thresholds to the color band
        hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
        saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
        valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

        % Combine the masks to find where all 3 are "true."
        % Then we will have the mask of only the green parts of the image.
        coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

        % Filter out small objects.
        smallestAcceptableArea = 50;
        % Get rid of small objects.  Note: bwareaopen returns a logical.
        coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
        % Smooth the border using a morphological closing operation, imclose().
        structuringElement = strel('disk', 4);
        coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
        % Fill in any holes in the regions, since they are most likely green also.
        coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

        % You can only multiply integers if they are of the same type.
        % (coloredObjectsMask is a logical array.)
        % We need to convert the type of coloredObjectsMask to the same data type as hImage.
        % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
        coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

        % Use the colored object mask to mask out the colored-only portions of the rgb image.
        maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
        maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
        maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
        % Concatenate the masked color bands to form the rgb image.
        maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

        %showing thresholded image in GUI
        if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
            axes(handles.axes2); imshow(maskedRGBImage); hold on;
            str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2); imshow(maskedRGBImage);
        end
        axes(handles.axes1); %thresholded video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            axes(handles.axes1); imshow(singleFrame);
        end
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
elseif  v.pushed==2 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
        v.valueThresholdLow=handles.slider9.Value; %slider9 value for value threshold low
        %other slider values
        v.hueThresholdLow = handles.slider13.Value;
        v.hueThresholdHigh = handles.slider14.Value;
        v.saturationThresholdLow = handles.slider12.Value;
        v.saturationThresholdHigh = handles.slider11.Value;
        v.valueThresholdHigh = handles.slider10.Value;

        % Convert RGB image to HSV
        hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);

        % Now apply each color band's particular thresholds to the color band
        hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
        saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
        valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

        % Combine the masks to find where all 3 are "true."
        % Then we will have the mask of only the green parts of the image.
        coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

        % Filter out small objects.
        smallestAcceptableArea = 50;
        % Get rid of small objects.  Note: bwareaopen returns a logical.
        coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
        % Smooth the border using a morphological closing operation, imclose().
        structuringElement = strel('disk', 4);
        coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
        % Fill in any holes in the regions, since they are most likely green also.
        coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

        % You can only multiply integers if they are of the same type.
        % (coloredObjectsMask is a logical array.)
        % We need to convert the type of coloredObjectsMask to the same data type as hImage.
        % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
        coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

        % Use the colored object mask to mask out the colored-only portions of the rgb image.
        maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
        maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
        maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
        % Concatenate the masked color bands to form the rgb image.
        maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

        %showing thresholded image in GUI
        if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
            axes(handles.axes2); imshow(maskedRGBImage); hold on;
            str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2); imshow(maskedRGBImage);
        end
        axes(handles.axes1); %original video
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
elseif v.pushed==2 && d.pushed==4;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
        v.valueThresholdLow=handles.slider9.Value; %slider9 value for value threshold low
        %other slider values
        v.hueThresholdLow = handles.slider13.Value;
        v.hueThresholdHigh = handles.slider14.Value;
        v.saturationThresholdLow = handles.slider12.Value;
        v.saturationThresholdHigh = handles.slider11.Value;
        v.valueThresholdHigh = handles.slider10.Value;

        % Convert RGB image to HSV
        hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);

        % Now apply each color band's particular thresholds to the color band
        hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
        saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
        valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

        % Combine the masks to find where all 3 are "true."
        % Then we will have the mask of only the green parts of the image.
        coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

        % Filter out small objects.
        smallestAcceptableArea = 50;
        % Get rid of small objects.  Note: bwareaopen returns a logical.
        coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
        % Smooth the border using a morphological closing operation, imclose().
        structuringElement = strel('disk', 4);
        coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
        % Fill in any holes in the regions, since they are most likely green also.
        coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

        % You can only multiply integers if they are of the same type.
        % (coloredObjectsMask is a logical array.)
        % We need to convert the type of coloredObjectsMask to the same data type as hImage.
        % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
        coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

        % Use the colored object mask to mask out the colored-only portions of the rgb image.
        maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
        maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
        maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
        % Concatenate the masked color bands to form the rgb image.
        maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

        %showing thresholded image in GUI
        if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
            axes(handles.axes2); imshow(maskedRGBImage); hold on;
            str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2); imshow(maskedRGBImage);
        end
        axes(handles.axes1); %ROIs with video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
        else
            imshow(singleFrame);hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for j=1:size(d.b,1);
            d.c{j,1} = stat(d.ROIorder(j)).Centroid;
            plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
            text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
        end
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
elseif v.pushed==3 && d.pre==1 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
        v.valueThresholdLow=handles.slider9.Value; %slider9 value for value threshold low
        %other slider values
        v.hueThresholdLow = handles.slider13.Value;
        v.hueThresholdHigh = handles.slider14.Value;
        v.saturationThresholdLow = handles.slider12.Value;
        v.saturationThresholdHigh = handles.slider11.Value;
        v.valueThresholdHigh = handles.slider10.Value;

        % Convert RGB image to HSV
        hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);

        % Now apply each color band's particular thresholds to the color band
        hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
        saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
        valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

        % Combine the masks to find where all 3 are "true."
        % Then we will have the mask of only the green parts of the image.
        coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

        % Filter out small objects.
        smallestAcceptableArea = 50;
        % Get rid of small objects.  Note: bwareaopen returns a logical.
        coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
        % Smooth the border using a morphological closing operation, imclose().
        structuringElement = strel('disk', 4);
        coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
        % Fill in any holes in the regions, since they are most likely green also.
        coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

        % You can only multiply integers if they are of the same type.
        % (coloredObjectsMask is a logical array.)
        % We need to convert the type of coloredObjectsMask to the same data type as hImage.
        % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
        coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

        % Use the colored object mask to mask out the colored-only portions of the rgb image.
        maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
        maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
        maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
        % Concatenate the masked color bands to form the rgb image.
        maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

        %showing thresholded image in GUI
        if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
            axes(handles.axes2); imshow(maskedRGBImage); hold on;
            str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2); imshow(maskedRGBImage);
        end
        axes(handles.axes1); %thresholded video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            axes(handles.axes1); imshow(singleFrame);
        end
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
elseif v.pushed==3 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
        v.valueThresholdLow=handles.slider9.Value; %slider9 value for value threshold low
        %other slider values
        v.hueThresholdLow = handles.slider13.Value;
        v.hueThresholdHigh = handles.slider14.Value;
        v.saturationThresholdLow = handles.slider12.Value;
        v.saturationThresholdHigh = handles.slider11.Value;
        v.valueThresholdHigh = handles.slider10.Value;

        % Convert RGB image to HSV
        hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);

        % Now apply each color band's particular thresholds to the color band
        hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
        saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
        valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

        % Combine the masks to find where all 3 are "true."
        % Then we will have the mask of only the green parts of the image.
        coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

        % Filter out small objects.
        smallestAcceptableArea = 50;
        % Get rid of small objects.  Note: bwareaopen returns a logical.
        coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
        % Smooth the border using a morphological closing operation, imclose().
        structuringElement = strel('disk', 4);
        coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
        % Fill in any holes in the regions, since they are most likely green also.
        coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

        % You can only multiply integers if they are of the same type.
        % (coloredObjectsMask is a logical array.)
        % We need to convert the type of coloredObjectsMask to the same data type as hImage.
        % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
        coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

        % Use the colored object mask to mask out the colored-only portions of the rgb image.
        maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
        maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
        maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
        % Concatenate the masked color bands to form the rgb image.
        maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

        %showing thresholded image in GUI
        if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
            axes(handles.axes2); imshow(maskedRGBImage); hold on;
            str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2); imshow(maskedRGBImage);
        end
        axes(handles.axes1); %original video
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
elseif v.pushed==3 && d.pushed==4;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
        v.valueThresholdLow=handles.slider9.Value; %slider9 value for value threshold low
        %other slider values
        v.hueThresholdLow = handles.slider13.Value;
        v.hueThresholdHigh = handles.slider14.Value;
        v.saturationThresholdLow = handles.slider12.Value;
        v.saturationThresholdHigh = handles.slider11.Value;
        v.valueThresholdHigh = handles.slider10.Value;

        % Convert RGB image to HSV
        hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);

        % Now apply each color band's particular thresholds to the color band
        hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
        saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
        valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

        % Combine the masks to find where all 3 are "true."
        % Then we will have the mask of only the green parts of the image.
        coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

        % Filter out small objects.
        smallestAcceptableArea = 50;
        % Get rid of small objects.  Note: bwareaopen returns a logical.
        coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
        % Smooth the border using a morphological closing operation, imclose().
        structuringElement = strel('disk', 4);
        coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
        % Fill in any holes in the regions, since they are most likely green also.
        coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

        % You can only multiply integers if they are of the same type.
        % (coloredObjectsMask is a logical array.)
        % We need to convert the type of coloredObjectsMask to the same data type as hImage.
        % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
        coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

        % Use the colored object mask to mask out the colored-only portions of the rgb image.
        maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
        maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
        maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
        % Concatenate the masked color bands to form the rgb image.
        maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

        %showing thresholded image in GUI
        if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
            axes(handles.axes2); imshow(maskedRGBImage); hold on;
            str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2); imshow(maskedRGBImage);
        end
        axes(handles.axes1); %ROIs with video
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
        else
            imshow(singleFrame);hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for j=1:size(d.b,1);
            d.c{j,1} = stat(d.ROIorder(j)).Centroid;
            plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
            text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
        end
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
end


%if only calcium video was loaded
if d.pre==1 && d.pushed<4;
    d.play=1;
    axes(handles.axes1);
    for k=round(handles.slider7.Value):size(d.imd,3);
        singleFrame=d.imd(:,:,round(handles.slider7.Value));
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            axes(handles.axes1); imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
elseif d.pushed==1;
    d.play=1;
    axes(handles.axes1); %original video
    for k=round(handles.slider7.Value):size(d.imd,3);
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
elseif d.pushed==4;
    d.play=1;
    axes(handles.axes1); %video with ROIs
    for k=round(handles.slider7.Value):size(d.imd,3);
    singleFrame=d.imd(:,:,k);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame);hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for j=1:size(d.b,1);
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.1);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
            return;
        end
    end
end


%if only behavioral video was loaded
if  v.pushed==1;
    v.play=1;
    axes(handles.axes2);
    for k=round(handles.slider7.Value):size(v.imd,2);
        image(v.imd(k).cdata); %original video
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(0.05);
        if k==size(d.imd,3);
            d.play=0;
            d.stop=1;
        end
        if d.stop==1;
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
if d.pushed==0;
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
%clears cache
%clears all global variables
clear global v;
%reinitializes global variables
global v
v.pushed=0;
v.play=0;
v.pn=[];
v.amount=[];
v.shortkey=[];
v.name=[];
v.events=[];
v.skdefined=0;
v.behav=0;
p.import=0;
%clears axes
cla(handles.axes2,'reset');
%resets frame slider
handles.slider7.Value=1;

if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end

%checks whether calcium imaging video was loaded
if d.pushed==0;
    msgbox('Please select calcium imaging video first!','ATTENTION');
    return;
end        

v.pn=[];
v.fn=[];
v.crop=0; %signals video is not cropped
v.hsv=0; %signals video is not converted to hsv color space
v.Pspot=0; %signals green spot is not saved
v.Aspot=0; %signals pink spot is not saved
if d.pushed>=1;
    [v.pn]=uigetdir(d.pn);
else
    [v.pn]=uigetdir('F:\jenni\Documents\PhD PROJECT\Calcium Imaging\doric camera\');
end

%check whether converted video had been saved before
filePattern = fullfile(v.pn, '*.mp4');
Files = dir(filePattern);
v.fn = Files(1).name;
files=dir(v.pn);
tf=zeros(1,length(dir(v.pn)));
for k=1:length(dir(v.pn));
    tf(k)=strcmp([v.fn(1:end-4) '_converted.mat'],files(k).name);
end
if sum(tf)>0;
    % Construct a questdlg with two options
    choice = questdlg('Would you like to load your last processed version?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    switch choice
        case 'YES'
            %loading cropped and converted video
            h=msgbox('Loading... please wait!');
            load([v.pn '\' v.fn(1:end-4) '_converted']);
            v.imd=convVimd;
            v.pushed=1; %signals video is loaded
            v.crop=1; %signals that video was cropped
            %loading traces
            files=dir(v.pn);
            tfA=zeros(1,length(dir(v.pn)));
            tfP=zeros(1,length(dir(v.pn)));
            for k=1:length(dir(v.pn));
                tfA(k)=strcmp('traceA.mat',files(k).name);
                tfP(k)=strcmp('traceP.mat',files(k).name);
            end
            if sum(tfA)>0;
                load([v.pn '\traceA']);
                v.traceA=traceA;
                v.traceAplot=traceAplot;
                v.colorA=colorA;
                v.Aspot=1;
            end
            if sum(tfP)>0;
                load([v.pn '\traceP']);
                v.traceP=traceP;
                v.tracePplot=tracePplot;
                v.colorP=colorP;
                v.Pspot=1;
            end
            if sum(tfA)>0&&sum(tfP)>0;
                %plotting trace
                a=figure, image(v.imd(1).cdata); hold on;
                plot(v.tracePplot(:,1),v.tracePplot(:,2),v.colorP);
                plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA); hold off;
            end
            %loading behavior
            files=dir(v.pn);
            tfb=zeros(1,length(dir(v.pn)));
            for k=1:length(dir(v.pn));
                tfb(k)=strcmp('Behavior.mat',files(k).name);
            end
            if sum(tfb)>0;
                %saving positions at ROIs
                load([v.pn '\Behavior']);
                v.amount=Amount;
                v.events=Events;
                v.shortkey=Shortkeys;
                v.name=BehavNames;
                v.barstart=barstart;
                v.barwidth=barwidth;
                v.skdefined=1;
                v.behav=1;
                %showing plot
                colors={[0    0.4471    0.7412],...
                        [0.8510    0.3255    0.0980],...
                        [0.9294    0.6941    0.1255],...
                        [0.4941    0.1843    0.5569],...
                        [0.4667    0.6745    0.1882],...
                        [0.3020    0.7451    0.9333],...
                        [0.6353    0.0784    0.1843],...
                        [0.6784    0.9216    1.0000]};
                figure;
                str={};
                skeys={};
                for j=1:v.amount;
                    v.events.(char(v.name{1,j}))(v.events.(char(v.name{1,j}))>1)=1; %in case event was registered multiple times at the same frame
                    area(1:size(v.imd,2),v.events.(char(v.name{1,j})),'edgecolor',colors{1,j},'facecolor',colors{1,j},'facealpha',0.5),hold on;
                    str(end+1)={char(v.name{1,j})};
                    skeys(end+1)={char(v.shortkey{1,j})};
                end
                xlabel('Time in seconds');
                tlabel=get(gca,'XTickLabel');
                for k=1:length(tlabel);
                    tlabel{k,1}=str2num(tlabel{k,1});
                end
                tlabel=cell2mat(tlabel);
                tlabel=tlabel./d.framerate;
                set(gca,'XTickLabel',tlabel);
                legend(str);
                hold off;
            end
            close(h);
            %looking at first original picture
            axes(handles.axes2); image(v.imd(1).cdata);
            titleLabel = ['Behavioral video: ' v.fn];
            set(handles.text28, 'String', titleLabel);
            handles.text28.TooltipString=v.pn;
            if sum(tfb)>0;
                msgbox(cat(2, {'Loading Completed. Your shortkeys are:'}, skeys),'Success');
            else
                msgbox(sprintf('Loading Completed.'),'Success');
            end
        case 'NO'
            %loading raw video
            v.vid = VideoReader([v.pn '\' v.fn]);

            %defining dimensions of video
            nframes=get(v.vid,'NumberOfFrames');
            vidObj = VideoReader([v.pn '\' v.fn]);
            vidHeight = vidObj.Height;
            vidWidth = vidObj.Width;
            v.framerate=vidObj.FrameRate;
            v.imd = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'));

            %putting each frame into variable 'v.imd'
            h=waitbar(0,'Loading');
            c=1;
            if v.framerate>d.framerate;
                for k=1:ceil(v.framerate/d.framerate):nframes
                    v.imd(c).cdata = read(vidObj,k);
                    c=c+1;
                    waitbar(k/nframes,h);
                end
            else
                for k=1:nframes
                    v.imd(c).cdata = read(vidObj,k);
                    c=c+1;
                    waitbar(k/nframes,h);
                end
            end
            sframe=size(v.imd,2)-size(d.imd,3);
            v.imd=v.imd(1:size(d.imd,3));
            v.pushed=1; %signals video is loaded
            close(h);
            %looking at first original picture
            axes(handles.axes2); image(v.imd(1).cdata);
            titleLabel = ['Behavioral video: ' v.fn];
            set(handles.text28, 'String', titleLabel);
            handles.text28.TooltipString=v.pn;
            msgbox(sprintf('Loading Completed. Frames cut off: %d',sframe),'Success');
    end
else
    %loading raw video
    v.vid = VideoReader([v.pn '\' v.fn]);

    %defining dimensions of video
    nframes=get(v.vid,'NumberOfFrames');
    vidObj = VideoReader([v.pn '\' v.fn]);
    vidHeight = vidObj.Height;
    vidWidth = vidObj.Width;
    v.framerate=vidObj.FrameRate;
    v.imd = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'));

    %putting each frame into variable 'v.imd'
    h=waitbar(0,'Loading');
    c=1;
    if v.framerate>d.framerate; %making framrate identical for behavioral video
        for k=1:ceil(v.framerate/d.framerate):nframes
            v.imd(c).cdata = read(vidObj,k);
            c=c+1;
            waitbar(k/nframes,h);
        end
    else
        for k=1:nframes
            v.imd(c).cdata = read(vidObj,k);
            c=c+1;
            waitbar(k/nframes,h);
        end
    end
    sframe=size(v.imd,2)-size(d.imd,3); %calculating how many frames the behavioral video has more than the CI video
    v.imd=v.imd(1:size(d.imd,3)); %making behavioral video as long as calcium imaging video
    v.pushed=1; %signals video is loaded
    close(h);
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
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
axes(handles.axes2); image(v.imd(1).cdata); %displays first image
if d.help==1;
    uiwait(msgbox('Please define the area where the mouse is running by left-click and dragging the cursor over the area! Then right click and select Copy Position, finish by double-clicking!','Attention','modal'));
end
%initializes interactive cropping
h=imcrop;
cropped=clipboard('pastespecial');
cropCoordinates=str2num(cell2mat(cropped.A_pastespecial));
%checks if cropping coordinates are valid
if isempty(cropCoordinates)==1 || cropCoordinates(1,3)==0 || cropCoordinates(1,4)==0;
    msgbox('Please select valid cropping area! Check the instructions again.','ERROR');
    return;
end
cc=floor(cropCoordinates);
%cropping frames
h=waitbar(0,'Cropping frames');
for k=1:size(v.imd,2);
    v.imd(k).cdata=v.imd(k).cdata(cc(2):cc(2)+cc(4),cc(1):cc(1)+cc(3),:);
    waitbar(k/size(v.imd,2),h);
end
v.crop=1; %signals that video was cropped
close(h);
%downsampling
imd = struct('cdata',zeros(size(v.imd(1),1),size(v.imd(1),2),3,'uint8'));
h=waitbar(0,'Downsampling');
for k=1:size(v.imd,2);
    imd(k).cdata=imresize(v.imd(k).cdata,0.6);
    waitbar(k/size(v.imd,2),h);
end
v.imd=imd;
close(h);
axes(handles.axes2); image(v.imd(1).cdata);

%saving cropped video
h=msgbox('Program might seem unresponsive, please wait!');
filename=[v.pn '\' v.fn(1:end-4) '_converted'];
convVimd=v.imd;
save(filename, 'convVimd');
close(h);

if d.help==1;
    msgbox('Cropping and downsampling completed. Please select a color preset to view only the colored spot. If needed adjust thresholds manually! If satisfied save the two colored spots by clicking SAVE ANTERIOR SPOT and SAVE POSTERIOR SPOT.','Success');
else
    msgbox('Cropping and downsampling completed.','Success');
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
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

v.valueThresholdLow=handles.slider9.Value; %slider9 value for value threshold low
%other slider values
v.hueThresholdLow = handles.slider13.Value;
v.hueThresholdHigh = handles.slider14.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdHigh = handles.slider10.Value;

% Convert RGB image to HSV
hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);
 
% Now apply each color band's particular thresholds to the color band
hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
    axes(handles.axes2); imshow(maskedRGBImage); hold on;
    str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2); imshow(maskedRGBImage);
end

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
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

v.valueThresholdHigh=handles.slider10.Value; %slider10 value for value threshold high
%other slider values
v.hueThresholdLow = handles.slider13.Value;
v.hueThresholdHigh = handles.slider14.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow = handles.slider9.Value;

% Convert RGB image to HSV
hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);
 
% Now apply each color band's particular thresholds to the color band
hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
    axes(handles.axes2); imshow(maskedRGBImage); hold on;
    str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2); imshow(maskedRGBImage);
end

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
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
maxframes=size(d.imd,3);
nframes=size(v.imd,2);
v.saturationThresholdHigh = handles.slider11.Value; %slider11 value for saturation threshold high
%other slider values
v.hueThresholdLow = handles.slider13.Value;
v.hueThresholdHigh = handles.slider14.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

% Convert RGB image to HSV
hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);
 
% Now apply each color band's particular thresholds to the color band
hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
    axes(handles.axes2); imshow(maskedRGBImage); hold on;
    str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2); imshow(maskedRGBImage);
end

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
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
maxframes=size(d.imd,3);
nframes=size(v.imd,2);
v.saturationThresholdLow = handles.slider12.Value; %slider12 value for saturation threshold low
%other slider values
v.hueThresholdLow = handles.slider13.Value;
v.hueThresholdHigh = handles.slider14.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

% Convert RGB image to HSV
hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);
 
% Now apply each color band's particular thresholds to the color band
hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
    axes(handles.axes2); imshow(maskedRGBImage); hold on;
    str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2); imshow(maskedRGBImage);
end

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
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
maxframes=size(d.imd,3);
nframes=size(v.imd,2);
v.hueThresholdLow = handles.slider13.Value; %slider13 value for hue threshold low
%other slider values
v.hueThresholdHigh = handles.slider14.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

% Convert RGB image to HSV
hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);
 
% Now apply each color band's particular thresholds to the color band
hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
    axes(handles.axes2); imshow(maskedRGBImage); hold on;
    str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2); imshow(maskedRGBImage);
end

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
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
maxframes=size(d.imd,3);
nframes=size(v.imd,2);
v.hueThresholdHigh = handles.slider14.Value; %slider14 value for hue threshold high
%other slider values
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

% Convert RGB image to HSV
hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);
 
% Now apply each color band's particular thresholds to the color band
hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
    axes(handles.axes2); imshow(maskedRGBImage); hold on;
    str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2); imshow(maskedRGBImage);
end

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
global p
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

%determining popup choice
v.preset=handles.popupmenu1.Value;
if v.preset==1;
    % Green preset values
    hueThresholdLow = 0.25;
    hueThresholdHigh = 0.55;
    saturationThresholdLow = 0.16;
    saturationThresholdHigh = 1;
    valueThresholdLow = 0;
    valueThresholdHigh = 0.8;
elseif v.preset==2;
    % Pink preset values
    hueThresholdLow = 0.80;
    hueThresholdHigh = 1;
    saturationThresholdLow = 0.36;
    saturationThresholdHigh = 1;
    valueThresholdLow = 0.0;
    valueThresholdHigh = 0.8;
elseif v.preset==3;
    % Yellow preset values
    hueThresholdLow = 0.12;
    hueThresholdHigh = 0.25;
    saturationThresholdLow = 0.19;
    saturationThresholdHigh = 1;
    valueThresholdLow = 0;
    valueThresholdHigh = 0.8;
elseif v.preset==4;
    % Blue preset values
    hueThresholdLow = 0.62;
    hueThresholdHigh = 1;
    saturationThresholdLow = 0.3;
    saturationThresholdHigh = 1;
    valueThresholdLow = 0.7;
    valueThresholdHigh = 1;
end

handles.slider14.Value = hueThresholdHigh;
handles.slider13.Value = hueThresholdLow;
handles.slider12.Value = saturationThresholdLow;
handles.slider11.Value = saturationThresholdHigh;
handles.slider9.Value = valueThresholdLow;
handles.slider10.Value = valueThresholdHigh;

v.hueThresholdHigh = handles.slider14.Value;
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

% Convert RGB image to HSV
hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);
    
% Now apply each color band's particular thresholds to the color band
hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
    axes(handles.axes2); imshow(maskedRGBImage); hold on;
    str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2); imshow(maskedRGBImage);
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
if isempty(p.pnpreset)==1;
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
    case 'posterior'
        load([p.pnpreset '\presetP']);
        v.hueThresholdHigh=hueHigh;
        v.hueThresholdLow=hueLow;
        v.saturationThresholdLow=satHigh;
        v.saturationThresholdHigh=satLow;
        v.valueThresholdLow=valueLow;
        v.valueThresholdHigh=valueHigh;
end

handles.slider14.Value = v.hueThresholdHigh;
handles.slider13.Value = v.hueThresholdLow;
handles.slider12.Value = v.saturationThresholdLow;
handles.slider11.Value = v.saturationThresholdHigh;
handles.slider9.Value = v.valueThresholdLow;
handles.slider10.Value = v.valueThresholdHigh;

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

% Convert RGB image to HSV
hsvImage= rgb2hsv(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata);
    
% Now apply each color band's particular thresholds to the color band
hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
    axes(handles.axes2); imshow(maskedRGBImage); hold on;
    str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2); imshow(maskedRGBImage);
end
hold off;




% --- Executes on button press in pushbutton10.      SAVE AS POSTERIOR SPOT
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('PLEASE PUSH STOP BUTTON BEFORE PROCEEDING!','PLEASE PUSH STOP BUTTON');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

v.hueThresholdHigh = handles.slider14.Value;
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

nframes=size(v.imd,2);
x=zeros(nframes,1);
y=zeros(nframes,1);
v.v.traceP=zeros(nframes,2);
%tracing center of the extracted posterior dot
h=waitbar(0,'Tracing posterior spot');
for k=1:nframes;
    % Convert RGB image to HSV
    hsvImage= rgb2hsv(v.imd(k).cdata);

    % Now apply each color band's particular thresholds to the color band
    hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
    saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
    valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

    % Combine the masks to find where all 3 are "true."
    % Then we will have the mask of only the green parts of the image.
    coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

    % Filter out small objects.
    smallestAcceptableArea = 50;
    % Get rid of small objects.  Note: bwareaopen returns a logical.
    coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
    % Smooth the border using a morphological closing operation, imclose().
    structuringElement = strel('disk', 4);
    coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
    % Fill in any holes in the regions, since they are most likely green also.
    coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

    % You can only multiply integers if they are of the same type.
    % (coloredObjectsMask is a logical array.)
    % We need to convert the type of coloredObjectsMask to the same data type as hImage.
    % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
    coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(1).cdata(:,:,1))));

    % Use the colored object mask to mask out the colored-only portions of the rgb image.
    maskedImageR = coloredObjectsMask .* v.imd(1).cdata(:,:,1);
    maskedImageG = coloredObjectsMask .* v.imd(1).cdata(:,:,2);
    maskedImageB = coloredObjectsMask .* v.imd(1).cdata(:,:,3);
    % Concatenate the masked color bands to form the rgb image.
    maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);
    
    %tracing
    stats=regionprops(maskedRGBImage, {'Centroid','Area'});
    if ~isempty([stats.Area])
        areaArray = [stats.Area];
        [junk,idx] = max(areaArray);
        c = stats(idx).Centroid;
        x(k,:) = c(1);
        y(k,:) = c(2);
    else
        x(k,:) = 0;
        y(k,:) = 0;
    end
    v.traceP(:,1)=x; %coordinates of the mouse center
    v.traceP(:,2)=y;
    waitbar(k/nframes,h);
end
v.pushed=2; %signals posterior spot was saved
v.Pspot=1; %signals posterior spot was saved
close(h);

%plotting posterior trace
v.tracePplot=v.traceP(v.traceP>0);
v.tracePplot=reshape(v.tracePplot,[size(v.tracePplot,1)/2,2]);
OutofBounds=100-round(length(v.tracePplot)/length(v.traceP)*100);
str=sprintf('Mouse is out of bounds in %g percent of cases',OutofBounds);
figure, image(v.imd(1).cdata); hold on;
%choosing color for plot
if v.preset==1;
    v.colorP=('g');
elseif v.preset==2;
    v.colorP=('r');
elseif v.preset==3;
    v.colorP=('y');
elseif v.preset==4;
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
save(filename, 'hueHigh','hueLow','satHigh','satLow','valueLow','valueHigh');

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
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('PLEASE PUSH STOP BUTTON BEFORE PROCEEDING!','PLEASE PUSH STOP BUTTON');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
            
v.hueThresholdHigh = handles.slider14.Value;
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

nframes=size(v.imd,2);
x=zeros(nframes,1);
y=zeros(nframes,1);
v.traceA=zeros(nframes,2);
%tracing center of the extracted anterior dot
h=waitbar(0,'Tracing anterior spot');
for k=1:nframes;
    % Convert RGB image to HSV
    hsvImage= rgb2hsv(v.imd(k).cdata);

    % Now apply each color band's particular thresholds to the color band
    hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
    saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
    valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

    % Combine the masks to find where all 3 are "true."
    % Then we will have the mask of only the green parts of the image.
    coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

    % Filter out small objects.
    smallestAcceptableArea = 50;
    % Get rid of small objects.  Note: bwareaopen returns a logical.
    coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
    % Smooth the border using a morphological closing operation, imclose().
    structuringElement = strel('disk', 4);
    coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
    % Fill in any holes in the regions, since they are most likely green also.
    coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

    % You can only multiply integers if they are of the same type.
    % (coloredObjectsMask is a logical array.)
    % We need to convert the type of coloredObjectsMask to the same data type as hImage.
    % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
    coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(1).cdata(:,:,1))));

    % Use the colored object mask to mask out the colored-only portions of the rgb image.
    maskedImageR = coloredObjectsMask .* v.imd(1).cdata(:,:,1);
    maskedImageG = coloredObjectsMask .* v.imd(1).cdata(:,:,2);
    maskedImageB = coloredObjectsMask .* v.imd(1).cdata(:,:,3);
    % Concatenate the masked color bands to form the rgb image.
    maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);
    
    %tracing
    stats=regionprops(maskedRGBImage, {'Centroid','Area'});
    if ~isempty([stats.Area])
        areaArray = [stats.Area];
        [junk,idx] = max(areaArray);
        c = stats(idx).Centroid;
        x(k,:) = c(1);
        y(k,:) = c(2);
    else
        x(k,:) = 0;
        y(k,:) = 0;
    end
    v.traceA(:,1)=x; %coordinates of the mouse center
    v.traceA(:,2)=y;
    waitbar(k/nframes,h);
end
v.pushed=3; %signals anterior spot was saved
v.Aspot=1; %signals anterior spot was saved
close(h);

%plotting anterior trace
v.traceAplot=v.traceA(v.traceA>0);
v.traceAplot=reshape(v.traceAplot,[size(v.traceAplot,1)/2,2]);
OutofBounds=100-round(length(v.traceAplot)/length(v.traceA)*100);
str=sprintf('Mouse is out of bounds in %g percent of cases',OutofBounds);
figure, image(v.imd(1).cdata); hold on;
%choosing color for plot
if v.preset==1;
    v.colorA=('g');
elseif v.preset==2;
    v.colorA=('r');
elseif v.preset==3;
    v.colorA=('y');
elseif v.preset==4;
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
save(filename, 'hueHigh','hueLow','satHigh','satLow','valueLow','valueHigh');

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
global p
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('PLEASE PUSH STOP BUTTON BEFORE PROCEEDING!','PLEASE PUSH STOP BUTTON');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
%checks whether spots were selected
if v.Aspot==0 && v.Pspot==0;
    msgbox('Please select colored spots!','ERROR');
    return;
elseif v.Aspot==0;
    msgbox('Please select anterior colored spot!','ERROR');
    return;
elseif v.Pspot==0;
    msgbox('Please select posterior colored spot!','ERROR');
    return;
end
%making sure that the ROIs were plotted
if isempty(d.ROImeans)==1 || d.dF==0;
    msgbox('ROIs need to be plotted before you can see corresponding postition of the mouse with cell activity!','ATTENTION');
    return;
end
if d.thresh==1 && size(d.ROIs,2)~=size(d.ROImeans,2) && d.dF==0;
    msgbox('All ROIs need to be plotted before you can see corresponding postition of the mouse with cell activity!','ATTENTION');
    return;
elseif d.thresh==0 && size(d.ROIs,2)~=size(d.ROImeans,2) && d.dF==0;
    msgbox('All ROIs need to be plotted before you can see corresponding postition of the mouse with cell activity!','ATTENTION');
    return;
end

%plotting posterior trace
a=figure, image(v.imd(1).cdata); hold on;
plot(v.tracePplot(:,1),v.tracePplot(:,2),v.colorP);

%plotting anterior trace
plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA); hold off;

%saving plot
% checking whether ROI traces had been saved before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn));
    tf(k)=strcmp('location',files(k).name);
end
if sum(tf)==0;
    mkdir([d.pn '\location']);
else
    rmdir([d.pn '\location'],'s');
    mkdir([d.pn '\location']);
end
name=sprintf('mouse_trace');
path=[d.pn '/location/',name,'.png'];
path=regexprep(path,'\','/');
print(a,'-dpng','-r100',path); %-depsc for vector graphic

%calculating the amount of time the mouse was out of view in percent
percOutside=round((length(v.traceA)-length(v.traceAplot))/length(v.traceA)*100,1); %v.traceAplot excludes values of zero, which means mouse was out of view

%calculating traveled distance
x=diff(v.traceAplot(:,1));
x=sqrt(x.^2);
y=diff(v.traceAplot(:,2));
y=sqrt(y.^2);
dist=sqrt(x.^2+y.^2);
totalDistInPx=sum(dist(dist>1 & dist<40)); %movement is consider at least 1 pixel and at most 40 pixels at once

%pixel in cm
h=figure,image(v.imd(1).cdata);hold on;
uiwait(msgbox('Please define the length of one side of the testing area by dragging a line, right-clicking, select "Copy Position" and close the figure. Then press "Next", "Finish"!','Attention'));
a=imline;
uiwait(h);
cropped=clipboard('pastespecial');
testsizepixel=round(str2num(cell2mat(cropped.A_pastespecial)));
testsizepixel=round(sqrt((abs(testsizepixel(2,1)-testsizepixel(1,1)))^2+(abs(testsizepixel(2,2)-testsizepixel(1,2)))^2))
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


%defining compartments
%check whether compartments have been imported
if p.import==1
    %loop of selecting compartments, giving names and calculations
        perccomp=zeros(1,p.amount);
        for k=1:p.amount;
            %calculating amount of time the mouse (the head) was in a compartment in percent
            [y,x]=find(p.ROImask(:,:,k)>0);
            cood=[x,y];
            v.traceAround=round(v.traceAplot);
            mhead=accumarray(v.traceAround,1);
            Mhead=imresize(mhead, [size(p.ROImask(:,:,k),1) size(p.ROImask(:,:,k),2)]);
            Mhead(Mhead<0.1)=0;
            Mhead(Mhead>0.1)=1;
            combi=p.ROImask(:,:,k)+Mhead;
            numpixel=numel(find(combi>1));
            numpixel=numpixel*((size(mhead,1)/size(p.ROImask(:,:,k),1)+size(mhead,2)/size(p.ROImask(:,:,k),2))/2);
            perccomp(1,k)=round(numpixel/length(v.traceA)*100,2); %percent in regards to the whole time
            Compartments.(char(p.name{1,k})) = perccomp(1,k);
        end
        %saving table
        T=struct2table(Compartments);
        filename=[d.pn '\location\' d.fn(1:end-4) 'compartments.xls'];
        writetable(T,filename);
        %saving tracing ROIs
        filename=[d.pn '\tracingROIs'];
        save(filename, 'amount','name','ROImask');
else
    %question if
    % Construct a questdlg with two options
    choice = questdlg('Would you like to define regions of interest?', ...
        'Attention', ...
        'Yes','No','No');
    % Handle response
    switch choice
        case 'Yes'
            %question how many
            prompt = {'How many?'};
            dlg_title = 'Input';
            num_lines = 1;
            answer = inputdlg(prompt,dlg_title,num_lines);
            amount=str2num(cell2mat(answer));
            %loop of selecting compartments, giving names and calculations
            perccomp=zeros(1,amount);
            name=cell(1,amount);
            ROImask=zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),amount);
            for k=1:amount;
                %selecting ROI
                figure,image(v.imd(1).cdata);
                str=sprintf('Please define compartment No. %d by clicking around the area!',k);
                uiwait(msgbox(str,'Attention'));
                ROI=roipoly;
                ROImask(:,:,k)=ROI;
                %name of ROI
                prompt = {'What do you want to call it?'};
                dlg_title = 'Input';
                num_lines = 1;
                answer = inputdlg(prompt,dlg_title,num_lines);
                name{1,k}=answer;
                close(gcf);
                %calculating amount of time the mouse (the head) was in a compartment in percent
                [y,x]=find(ROI>0);
                cood=[x,y];
                v.traceAround=round(v.traceAplot);
                mhead=accumarray(v.traceAround,1);
                Mhead=imresize(mhead, [size(ROI,1) size(ROI,2)]);
                Mhead(Mhead<0.1)=0;
                Mhead(Mhead>0.1)=1;
                combi=ROI+Mhead;
                numpixel=numel(find(combi>1));
                numpixel=numpixel*((size(mhead,1)/size(ROI,1)+size(mhead,2)/size(ROI,2))/2);
                perccomp(1,k)=round(numpixel/length(v.traceA)*100,2); %percent in regards to the whole time
                Compartments.(char(name{1,k})) = perccomp(1,k);
            end
            %saving table
            T=struct2table(Compartments);
            filename=[d.pn '\location\' d.fn(1:end-4) 'compartments.xls'];
            writetable(T,filename);
            %saving tracing ROIs
            filename=[d.pn '\tracingROIs'];
            save(filename, 'amount','name','ROImask');
        case 'No'
    end
end


%plotting cell activity
%checking whether mouse is out of bounds at times
if length(v.tracePplot)~=length(v.traceP) || length(v.traceAplot)~=length(v.traceA)
    % Construct a questdlg with two options
    choice = questdlg('Does the mouse ever leave the testing area?', ...
        'Attention', ...
        'Yes','No','No');
    % Handle response
    switch choice
        case 'Yes'
            mleft=0;
        case 'No'
            cood=find(v.traceP==0);
            for k=1:length(cood)
                v.traceP(cood(k))=v.traceP(cood(k)-1);
            end
            cood=find(v.traceA==0);
            for k=1:length(cood)
                v.traceA(cood(k))=v.traceA(cood(k)-1);
            end
            mleft=1;
    end
end
printyn=1; %for printing figures
x=zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),size(d.ROImeans,2));
xts=[];
for j=1:size(d.ROImeans,2);
    n=0;
    c=0;
    a=0;
    ArrowCoord=[];
    for k=1:floor(length(v.traceP)/round(length(v.traceP)/size(d.ROImeans,1),2));
        if d.ROImeans(k,j)>5*median(abs(d.ROImeans(:,j))/0.6745)  && v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)>0 && v.traceA(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)>0; %quiroga spike detection
            c=c+1;
            a=a+1;
            ArrowCoord{a,j}=[v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1);v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)];
            x(round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2)),round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)),j)=x(round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2)),round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)),j)+1;
            x(round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)),round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)),j)=x(round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)),round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)),j)+1;
            xts(c,j)=k/d.framerate;
        elseif d.ROImeans(k,j)>5*median(abs(d.ROImeans(:,j))/0.6745)  && v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)>0 && v.traceA(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)==0; %>=0.6
%         drawArrow([v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)],[v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)],'MaxHeadSize',10,'LineWidth',3,'Color',[1 0 0]);
            x(round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2)),round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)),j)=x(round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2)),round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)),j)+1;
            c=c+1;
            xts(c,j)=k/d.framerate;
%             ArrowCoord{c,j}=[v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1);v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)];
        elseif d.ROImeans(k,j)>5*median(abs(d.ROImeans(:,j))/0.6745)  && v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)==0 && v.traceA(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)>0; %>=0.6
%         drawArrow([v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)],[v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)],'MaxHeadSize',10,'LineWidth',3,'Color',[1 0 0]);
            x(round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)),round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)),j)=x(round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)),round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)),j)+1;
            c=c+1;
            xts(c,j)=k/d.framerate;
%             ArrowCoord{c,j}=[v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1);v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)];
        end
        if d.ROImeans(k,j)>5*median(abs(d.ROImeans(:,j))/0.6745) && (v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)==0 && v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)==0); %>=0.6
            n=n+1;
        end
    end
    %plot cell activity
    h=figure(4+j), image(v.imd(1).cdata); hold on;
    string=sprintf('ROI No.%d',j);
    title(string);
    cellactive=imresize(imresize(x,0.25),4);
    colormap(jet),grid=imagesc(cellactive(:,:,j)),cb=colorbar,cb.Label.String = 'Relative position distribution';
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.75);
    %display how many percent mouse was registered out of bounds
    OoB=round(100*(n/(n+c)));
    str=sprintf('Cell fires when mouse is out of bounds in %d percent of cases',OoB);
    if mleft==0;
        text(20,20,str,'Color','r');
    end
    % plot direction
    drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:});
    for  k=1:size(ArrowCoord,1);
        drawArrow([ArrowCoord{k,j}(1,1) ArrowCoord{k,j}(1,2)],[ArrowCoord{k,j}(2,1) ArrowCoord{k,j}(2,2)],'MaxHeadSize',5,'LineWidth',1,'Color',[1 0 0]);
    end
    hold off;
    %saving plots
    if printyn==1
        name=sprintf('ROI%d_trace',j);
        path=[d.pn '/location/',name,'.png'];
        path=regexprep(path,'\','/');
        print(h,'-dpng','-r100',path); %-depsc for vector graphic

        %saving table
        T=table(totalDistIncm,VelocityIncms,percPause,percOutside);
        filename=[d.pn '\location\' d.fn(1:end-4) 'behavior.xls'];
        writetable(T,filename);

        %saving positions at ROIs
        filename=[d.pn '\location\ROIposition'];
        field1='ROIposition';
        field2='ts';
        value1{j,1}=x;
        value2{j,1}=xts;
        Positions=struct(field1,value1,field2,value2);
        OutofBounds=OoB;
        save(filename, 'Positions','OutofBounds');
    end
end
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
if v.pushed==0 && d.pushed==0;
    msgbox('Please select folder first!','ERROR');
    return;
elseif v.pushed==0;
    v.imd=[];
    nframes=[];
elseif v.pushed==1;
    v.hsvA=[];
    v.hsvP=[];
    nframes=size(v.imd,2);
elseif v.pushed>=1;
    nframes=size(v.imd,2);
end
if d.pushed==0;
    d.imd=[];
    maxframes=size(v.imd,2);
else
    maxframes=size(d.imd,3);
end

if d.align==1 && handles.radiobutton2.Value==1;
    imdMax=(1/(mean(mean(mean(d.imd))))+1/(max(max(max(d.imd)))))/2;
else
    imdMax=1/(max(max(max(d.imd))));
end

if v.skdefined==0 && d.help==1;
    uiwait(msgbox('Please track behavior by pushing this button only! It will play the behavioral video while you can push your self-defined shortkeys. Use the regular STOP button to STOP, but the BEHAVIORAL DETECTION button to continue!','Attention'));
    %Question how many
    prompt = {'How many behaviors would you like to track? (8 maximum)'};
    dlg_title = 'Input';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);
    if str2num(cell2mat(answer))>8;
        uiwait(msgbox('Please define only up to 8 behaviors!'));
        return
    end
    v.amount=str2num(cell2mat(answer));
    %loop of naming behaviors
    v.shortkey=cell(1,v.amount);
    v.name=cell(1,v.amount);
    for k=1:v.amount;
        %shortkey
        str=sprintf('Please define shortkey No. %d.',k);
        prompt = {str};
        dlg_title = 'Input';
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        v.shortkey{1,k}=answer;
        %name of ROI
        prompt = {'What do you want to call it?'};
        dlg_title = 'Input';
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        v.name{1,k}=answer;
        %initializing event counter
        v.events.(char(v.name{1,k})) = zeros(size(v.imd,2),1);
    end
    v.skdefined=1;
end
    

if  v.pushed==1;
    v.play=1;
    axes(handles.axes2);
    for k=round(handles.slider7.Value):size(v.imd,2);
        v.k=k;
        image(v.imd(k).cdata); %original video
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
        if k==size(d.imd,3);
            d.stop=1;
            d.play=0;
        end
        if d.stop==1;
            colors={[0    0.4471    0.7412],...
                    [0.8510    0.3255    0.0980],...
                    [0.9294    0.6941    0.1255],...
                    [0.4941    0.1843    0.5569],...
                    [0.4667    0.6745    0.1882],...
                    [0.3020    0.7451    0.9333],...
                    [0.6353    0.0784    0.1843],...
                    [0.6784    0.9216    1.0000]};
            a=figure;
            str={};
            for j=1:v.amount;
                v.events.(char(v.name{1,j}))(v.events.(char(v.name{1,j}))>1)=1; %in case event was registered multiple times at the same frame
                %timebars
                bars=diff(v.events.(char(v.name{1,j})));
                v.barstart.(char(v.name{1,j}))=find(bars==1);
                v.barwidth.(char(v.name{1,j}))=find(bars==-1)-v.barstart.(char(v.name{1,j}));
                area(1:size(v.imd,2),v.events.(char(v.name{1,j})),'edgecolor',colors{1,j},'facecolor',colors{1,j},'facealpha',0.5),hold on;
                str(end+1)={char(v.name{1,j})};
            end
            xlabel('Time in seconds');
            tlabel=get(gca,'XTickLabel');
            for k=1:length(tlabel);
                tlabel{k,1}=str2num(tlabel{k,1});
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

 for k=1:v.amount;
     if strcmpi(keyPressed,v.shortkey{1,k})
         v.events.(char(v.name{1,k}))(v.k)=1;
     end
 end


% --- Executes on button press in pushbutton35.       RESET BEHAV DETECTION
function pushbutton35_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v.amount=[];
v.shortkey=[];
v.name=[];
v.events=[];
v.skdefined=0;
v.behav=0;


% --- Executes on button press in pushbutton38.                 REMOVE DUST
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
if d.pre==1;
    msgbox('You have to remove dust before preprocessing!','ATTENTION');
    return;
end

%display instructions only if the button was pressed for the first time or
%a mistake was made and you want the help
if d.bcountd==0 || d.help==1;
    uiwait(msgbox('Please define the region of dust by clicking around the area. The corners can be moved afterwards as well as the whole selected area. When satisfied with the selection please double-click!','Attention','modal'));
end

singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1);
%manual dust selection
Dust = roipoly(singleFrame);    %uint8 for CI_win_S1HL_02/20151118 & DORIC; int16 for CI_S1Hl_02

%check if ROI was selected correctly
if numel(find(Dust))==0;
    msgbox('Please select valid dust ROI!','ERROR');
    return;
end

%count times button is pressed
d.bcountd=d.bcountd+1;

Dust=~Dust;
Dust=cast(Dust,class(d.imd(:,:,1)));
h=waitbar(0,'Removing dust specs');
for k=1:size(d.imd,3)
    d.imd(:,:,k)=Dust.*d.imd(:,:,k);
    waitbar(k/size(d.imd,3),h);
end
close(h);
%showing resulting frame
singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1);imshow(singleFrame);
msgbox('Removal complete!','Success');