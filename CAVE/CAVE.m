function varargout = CAVE(varargin)
% Calcium ActiVity Explorer MATLAB code for CAVE.fig
%      CAVE, by itself, creates a new CAVE or raises the existing
%      singleton*.
%
%      H = CAVE returns the handle to a new ROISUB or the handle to
%      the existing singleton*.
%
%      CAVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAVE.M with the given input arguments.
%
%      CAVE('Property','Value',...) creates a new CAVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roisub_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roisub_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%       
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CAVE

% Last Modified by GUIDE v2.5 11-Jan-2018 10:17:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CAVE_OpeningFcn, ...
                   'gui_OutputFcn',  @CAVE_OutputFcn, ...
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


% --- Executes just before CAVE is made visible.
function CAVE_OpeningFcn(hObject, ~, handles, varargin)
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
d.triggerts=[]; % no trigger event file was loaded
p.nscale=[]; %no scale for microscope field of view defined
p.ascale=[]; %no scale for animal arena defined
p.win=[]; %no window for trigger or behaviour defined
p.pnpreset=[]; %no color preset imported
d.alignCI=[]; %alignment video is empty
p.roisave=1; %ROI masks will be saved automatically
p.roistate=0; %no method of manipulating ROIs was selected
p.F2=[]; %PCA was not calculated yet

p.options = SetParams(varargin); %initializes all constant values

%loading preferences if existing
path=cd;
pcd=strfind(path,'CAVE');
if isempty(pcd)==1
    uiwait(msgbox('Please change the current directory to ./CAVE and restart the program!'));
    close(gcf);
    return;
end
files=dir(path);
tf=zeros(1,length(dir(path)));
for k=1:length(dir(path))
    tf(k)=strcmp('preferences.mat',files(k).name);
end
if sum(tf)>0 %if a file is found
    load([path '\preferences.mat']);
    try
        p.nscale=preferences.nscale;
        p.ascale=preferences.ascale;
        p.win=preferences.win;
    catch
    end
end

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CAVE (see VARARGIN)

% Choose default command line output for CAVE
handles.output = hObject;

% create the listener for the frame slider
handles.sliderListener = addlistener(handles.slider7,'ContinuousValueChange', ...
                                      @(hObject,eventdata) slider7_Callback(...
                                        handles.axes1,eventdata));

% Update handles structure
guidata(hObject, handles);

% Construct a questdlg with two options
if sum(tf)>0 %if a file is found
        load([path '\preferences.mat']);
        try
        p.help=preferences.help;
        catch
            choice = questdlg('Is this your first time working with this software? Do you need the help messages?', ...
            'Attention', ...
            'YES','NO','YES');
            % Handle response
            if isempty(choice)==1
                exit;
            end
            switch choice
                case 'YES'
                    p.help=1;
                    handles.disphelp.Checked='on';
                case 'NO'
                    p.help=0;
                    %saving preference
                    filename=[cd '\preferences'];
                    preferences.help=p.help;
                    save(filename, 'preferences');
            end
        end
    else
    choice = questdlg('Is this your first time working with this software? Do you need the help messages?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    if isempty(choice)==1
        exit;
    end
    switch choice
        case 'YES'
            p.help=1;
            handles.disphelp.Checked='on';
            %saving preference
            filename=[cd '\preferences'];
            preferences.help=p.help;
            save(filename, 'preferences');
        case 'NO'
            p.help=0;
            %saving preference
            filename=[cd '\preferences'];
            preferences.help=p.help;
            save(filename, 'preferences');
    end
end


% UIWAIT makes CAVE wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CAVE_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------

%% ---------------------------Processing calcium imaging video

%%---------------------------Loading calcium imaging video
% --------------------------------------------------------------------
% LOAD CALCIUM IMAGING VIDEO
function CI_Callback(hObject, eventdata, handles)
% hObject    handle to CI (see GCBO)
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
d.auto=0; %ROIs were not detected automatically
d.align=0; %no alignment
d.alignCI=[]; %alignment video is empty
d.pre=0; %no preprocessing
d.mip=0; %no maximum intensity projection
d.pn=[]; %no CI video path
d.ROIv=0; %no ROI values were loaded
d.ROIs=[]; %no ROI values have been collected
d.ROImeans=[]; %no mean ROI values have been calculated
d.decon=0; %calcium signal was not deconvoluted
d.name=[]; %no name defined
d.triggerts=[]; % no triggerfile loaded
p.F2=[];
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
elseif  d.pn==0
    [d.pn]=uigetdir('F:\jenni\Documents\PhD PROJECT\Calcium Imaging\doric camera\');
else
    [d.pn]=uigetdir(p.pn);
end
%if cancel was pressed
if d.pn==0
    return;
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
        if isempty(answer)==1
            return;
        end
        d.framerate=str2num(cell2mat(answer));
   end
end 

%check whether video had been processed before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn))
    tf(k)=strcmp('name.mat',files(k).name); %looking for dF/F processed video as .mat file
end
if sum(tf)>0 %if a file is found
    % Construct a questdlg with two options
    choice = questdlg('Would you like to load your last processed version?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    if isempty(choice)==1 %window was closed
        return;
    end
    switch choice
        case 'YES'
            %function for loading last processed version
            loadlastCI;
            if isempty(d.imd)==1
                return;
            end
            if sum(sum(d.mask))~=0 %if a ROI mask was loaded, plot the ROIs
                %plotting ROIs
                singleFrame=d.imd(:,:,round(handles.slider7.Value));
                axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8)); %repeat color scheme as many times as there are ROIs
                for j=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,j)))>0
                        B=bwboundaries(d.ROIsbw(:,:,j)); %boundaries of ROIs
                        stat = regionprops(d.ROIsbw(:,:,j),'Centroid');
                        %drawing ROIs
                        plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,j});
                        text(stat.Centroid(1),stat.Centroid(2),num2str(j));
                    end
                end
                hold off;
            else
                singleFrame=d.imd(:,:,round(handles.slider7.Value));
                axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
            end
            if d.decon==1
                h=msgbox('Please wait while calcium signal is being plotted...');
                %plotting ROI values
                colors=repmat(d.colors,1,ceil(size(d.ROImeans,2)/8)); %repeat color scheme as many times as there are ROIs
                %initializing that only 8 subplots will be in one figure
                onesub=(1:8);
                anysub=repmat(onesub,1,ceil(size(d.ROImeans,2)/8));
                check=(9:8:200);
                check2=(8:8:200);

                figure('color','w');
                for j=1:size(d.ROImeans,2)
                    if ismember(j,check)==1 %if ROI number is 9, 18, 27... new figure is initialized, this way there are only 8 ROIs per figure
                        figure('color','w');
                    end
                    subaxis(8,1,anysub(j),'SpacingVert',.01,'ML',.1,'MR',.1); %using subaxis for tight layout of traces
                    plot(d.cCaSignal(:,j),'Color',colors{1,j}),hold on;
                    axlim=get(gca,'YLim');
                    ylim([min(d.cCaSignal(:,j)) 2*round((axlim(2)+1)/2)]); %y-axis limits: from minimum value of the current ROI to round to next even number of current axis maximum value
                    strings=sprintf('ROI No.%d',j);
                    %title('ROI values in percent');
                    if ismember(j,check2)==1 || j==size(d.ROImeans,2) %writing x-axis label only for last plot in the figure
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
                    if sum(d.spikes(:,j))>0
                        plot(find(d.spikes(:,j)),max(d.cCaSignal(:,j))+0.5,'k.');
                    end
                end
                hold off;

                %plotting raster plot
                figure;
                subplot(2,1,1);
                for j=1:size(d.ROImeans,2)
                    if sum(d.spikes(:,j))>0
                        plot(find(d.spikes(:,j)),j,'k.');
                    end
                    hold on;
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
                plot(sum(d.spikes,2));
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
                    close(h);
                catch
                end
            end
            %loading original calcium imaging video
            % Construct a questdlg with two options
            choice = questdlg('Would you also like to load the original calcium imaging video?', ...
                'Attention', ...
                'YES','NO','YES');
            % Handle response
            if isempty(choice)==1 %window was closed
                return;
            end
            switch choice
                case 'YES'
                    if length(Files)==1
                        %function for loading TIFF stack
                        pn=d.pn;
                        fn=d.fn;
                        [imd,origCI,pre] = loadCIstack(pn,fn);
                        if isempty(imd)==1
                            return;
                        end
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
                        if isempty(imd)==1
                            return;
                        end
                        d.origCI=imd;
                    end
                    d.dF=1; %signals that dF/F was performed
                    load([d.pn '\' cell2mat(d.name) 'vidalign']);
                    d.align=vidalign; %whether alignment was applied
                    d.pre=1; %presprocessing was performed

                    msgbox('Loading complete!');
                case 'NO'
                    d.dF=1; %signals that dF/F was performed
                    load([d.pn '\' cell2mat(d.name) 'vidalign']);
                    d.align=vidalign; %whether alignment was applied
                    d.pre=1; %presprocessing was performed
                    d.origCI=[];
            end
        case 'NO'
            if length(Files)==1
                %function for loading TIFF stack
                pn=d.pn;
                fn=d.fn;
                [imd,origCI,pre] = loadCIstack(pn,fn);
                if isempty(imd)==1
                    return;
                end
                d.origCI=origCI;
                d.pre=pre;
                d.imd=imd;

                d.pushed=1; %signals that file was selected
                d.roisdefined=0; %no rois defined
                d.dF=0; %no dF/F performed
                d.load=0; %no ROIs loaded
                d.align=0; %no alignment
                d.mip=0; %no maximum intensity projection
                d.origCI=d.imd; %saving original CI video seperately

                %looking at first original picture
                if pre==1
                    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
                    axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
                else
                    axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
                end
            else
                %function for loading single TIFFs together
                pn=d.pn;
                fn=d.fn;
                [imd] = loadCIsingle(pn,fn,Files);
                if isempty(imd)==1
                    return;
                end
                d.imd=imd;

                d.pushed=1; %signals that file was selected
                d.roisdefined=0; %no rois defined
                d.dF=0; %no dF/F performed
                d.load=0; %no ROIs loaded
                d.align=0; %no alignment
                d.pre=0; %no preprocessing
                d.mip=0; %no maximum intensity projection
                d.origCI=d.imd; %saving original CI video seperately

                %looking at first original picture
                axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
            end
    end

elseif length(Files)==1
    %function for loading TIFF stack
    pn=d.pn;
    fn=d.fn;
    [imd,origCI,pre] = loadCIstack(pn,fn);
    if isempty(imd)==1
        return;
    end
    d.origCI=origCI;
    d.pre=pre;
    d.imd=imd;
    
    d.pushed=1; %signals that file was selected
    d.roisdefined=0; %no rois defined
    d.dF=0; %no dF/F performed
    d.load=0; %no ROIs loaded
    d.align=0; %no alignment
    d.mip=0; %no maximum intensity projection
    d.origCI=d.imd; %saving original CI video seperately
    
    %looking at first original picture
    if pre==1
        singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
    end
else
    %function for loading single TIFFs together
    pn=d.pn;
    fn=d.fn;
    [imd] = loadCIsingle(pn,fn,Files);
    if isempty(imd)==1
        return;
    end
    d.imd=imd;
    
    d.pushed=1; %signals that file was selected
    d.roisdefined=0; %no rois defined
    d.dF=0; %no dF/F performed
    d.load=0; %no ROIs loaded
    d.align=0; %no alignment
    d.pre=0; %no preprocessing
    d.mip=0; %no maximum intensity projection
    d.origCI=d.imd; %saving original CI video seperately
    
    %looking at first original picture
    axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
end
p.pn=d.pn; %saving current file directory so it can be displayed next time you want to select a folder

titleLabel = ['Calcium imaging video: ' d.fn]; %filename as title
set(handles.text27, 'String', titleLabel);
%if you hover with the animal over the filename, you can see the path
handles.text27.TooltipString=d.pn;
textLabel = sprintf('%d / %d', 1,size(d.imd,3));
set(handles.text36, 'String', textLabel);
handles.slider7.Max=size(d.imd,3);
handles.slider7.SliderStep=[1/size(d.imd,3) 1/size(d.imd,3)*10];

msgbox('Loading Completed.','Success');





%%---------------------------Changing contrast of calcium imaging video

% --- Executes on slider movement.                           CHANGES LOW IN
function slider5_Callback(~, ~, handles)
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
function slider5_CreateFcn(hObject, ~, ~)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                          CHANGES LOW OUT
function slider6_Callback(~, ~, handles)
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
function slider6_CreateFcn(hObject, ~, ~)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                          CHANGES HIGH IN
function slider15_Callback(~, ~, handles)
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
function slider15_CreateFcn(hObject, ~, ~)
% hObject    handle to slider15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                         CHANGES HIGH OUT
function slider16_Callback(~, ~, handles)
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
function slider16_CreateFcn(hObject, ~, ~)
% hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in pushbutton22.                       RESET
function pushbutton22_Callback(~, ~, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

if d.pushed<4
%resets values of low in/out, high in/out to start values
handles.slider5.Value=0;
handles.slider15.Value=1;
handles.slider6.Value=0;
handles.slider16.Value=1;
singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1); imshow(singleFrame); %shows image in axes1
end




%%---------------------------Processing calcium imaging video

% --- Executes on button press in pushbutton38.                 REMOVE DUST
function pushbutton38_Callback(~, ~, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p
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
if d.bcountd==0 && p.help==1
    uiwait(msgbox('Please define the region of dust by clicking around the area. The corners can be moved afterwards as well as the whole selected area. When satisfied with the selection please double-click!','Attention','modal'));
end

%display current image to select ROI
singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1);

%function for removing dust
bcountd=d.bcountd;
imd=d.imd;
[imd,bcountd] = removeDust(singleFrame,bcountd,imd);
if isempty(imd)==1
    return;
end
d.bcountd=bcountd;
d.imd=imd;

%showing resulting frame
singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1);imshow(singleFrame);
msgbox('Removal complete!','Success');



% --- Executes on button press in pushbutton41.          RESET DUST REMOVAL
function pushbutton41_Callback(~, ~, handles)
% hObject    handle to pushbutton41 (see GCBO)
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
    msgbox('You already did preprocessing!','ATTENTION');
    return;
end

d.imd=d.origCI;
d.bcountd=0;
%showing resulting frame
singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1);imshow(singleFrame);
msgbox('Dust removal reset!');


% --- Executes on button press in pushbutton23.               PREPROCESSING
function pushbutton23_Callback(~, ~, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global p
if d.pre==1
    msgbox('You already did preprocessing!','ATTENTION');
    return;
end

%asking for animal name/session/date
prompt = {'Enter your preferred name for this session (e.g. animalNo.-date):'};
dlg_title = 'Name';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
%if cancel was pressed
if isempty(answer)==1
    return;
end
%check whether another version already exists
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn))
    tf(k)=strcmp('name.mat',files(k).name);
end

if sum(tf)>0 %if a file is found
    load([d.pn '\name.mat']);
    for k=1:size(name,2)
        tff(k)=strcmp(name{1,k},answer);
    end
    if sum(tff)>0
        %when name already exist as previous version
        % Construct a questdlg with two options
        choice = questdlg('This name already exists, do you wish to overwrite it?', ...
            'Attention', ...
            'YES','NO','YES');
        % Handle response
        if isempty(choice)==1 %window was closed
            return;
        end
        switch choice
            case 'YES'
                d.name=answer;
            case 'NO'
                return;
        end
    else
        d.name=answer;
        name{1,size(name,2)+1}=cell2mat(answer);
        filename=[d.pn '\name'];
        save(filename, 'name');
    end
else    
    d.name=answer;
    filename=[d.pn '\name'];
    name=d.name;
    save(filename, 'name');
end

%Downsampling only if Width > 100 pixel
if size(d.imd,2)>p.options.dsw
    h=msgbox('Downsampling... please wait!');
    imd=imresize(d.imd,p.options.dsr);
    close(h);
end

%function for eliminating faulty frames
[imd] = faultyFrames(imd);
if isempty(imd)==1
    return;
end

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
fname=[cell2mat(d.name) '_MeanChange'];
path=[d.pn '/',fname,'.png'];
path=regexprep(path,'\','/');
print(h,'-dpng','-r100',path); %-depsc for vector graphic
msgbox('Preprocessing done!','Success');


% --- Executes on button press in pushbutton9.                ALIGNS IMAGES
function pushbutton9_Callback(~, ~, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p
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

if d.dF==1
     msgbox('Please align before calculating dF/F.','Attention');
     return
end

%saves original in different variable
d.alignCI=d.imd;

%alignment to a specified ROI from one specific frame or alignment to the respective previous frame
choice = questdlg('Would you like to use an area to align to or just the previous frame?', ...
'Attention', ...
'Area','Previous frame','Area');
% Handle response
if isempty(choice)==1
    return;
end
switch choice
    case 'Area'
        if d.bcountd==0 && p.help==1
            uiwait(msgbox('Please define a region with distinct landmarks by drawing a rectangle around the area. The corners can be moved afterwards as well as the whole selected area. When satisfied with the selection please right-click, select copy position and double-click within the selected area. Press next and finish!','Attention','modal'));
        end
        %define ROI that is used for transformation
        axes(handles.axes1);
        a=imcrop;
        cropped=clipboard('pastespecial');
        %if cancel was pressed
        if isempty(cropped)==1
            return;
        end

        cropCoordinates=str2num(cell2mat(cropped.A_pastespecial));
        %checks if cropping coordinates are valid
        if isempty(cropCoordinates)==1 || cropCoordinates(1,3)==0 || cropCoordinates(1,4)==0
            msgbox('Please select valid cropping area! Check the instructions again.','ERROR');
            return;
        end
        for i=1:4
            if cropCoordinates(1,i)<1
                cc(1,i)=ceil(cropCoordinates(1,i));
            else
                cc(1,i)=floor(cropCoordinates(1,i));
            end
        end
        %function for extracting and enhancing alignment ROI
        imd=d.imd;
        [ROI] = alignmentROI(cc,imd);
        if isempty(ROI)==1
            return;
        end
        imgA =ROI(:,:,round(handles.slider7.Value));
        tmp=ROI(:,:,round(handles.slider7.Value));
    case 'Previous frame'
        ROI=d.imd; %the area to align to is the whole video
        imgA =d.imd(:,:,1); %the template is the first frame for the second frame
        tmp=d.imd(:,:,1); %the template is the first frame for the second frame
end

if handles.radiobutton1.Value==1
    %function for using subpixel registration algorithm
    [imdC,Bvector]=subpixel(ROI,imgA);
    if isempty(imdC)==1
        return;
    end
    d.Bvector=Bvector;
    d.imd=imdC;
    %showing resulting frame
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
else
    %function for using LucasKanade algorithm
    imd=d.imd;
    [imdC,Bvector]=lucasKanade(ROI,imd,tmp);
    if isempty(imdC)==1
        return;
    end
    d.Bvector=Bvector;
    d.imd=imdC;
    %showing resulting frame
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
end


d.align=1; %signals that images were aligned
msgbox('Aligning Completed.','Success');


% --- Executes on button press in pushbutton28.            RESETS ALIGNMENT
function pushbutton28_Callback(~, ~, handles)
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
function pushbutton25_Callback(~, ~, handles)
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

%asking for animal name/session/date if not defined
if isempty(d.name)==1
    prompt = {'Enter your preferred name for this session (e.g. animalNo.-date):'};
    dlg_title = 'Name';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);
    %if cancel was pressed
    if isempty(answer)==1
        return;
    end
    %check whether another version already exists
    files=dir(d.pn);
    tf=zeros(1,length(dir(d.pn)));
    for k=1:length(dir(d.pn))
        tf(k)=strcmp('name.mat',files(k).name);
    end
    
    if sum(tf)>0 %if a file is found
        load([d.pn '\name.mat']);
        for k=1:size(name,2)
            tff(k)=strcmp(name{1,k},answer);
        end
        if sum(tff)>0
            %when name already exist as previous version
            % Construct a questdlg with two options
            choice = questdlg('This name already exists, do you wish to overwrite it?', ...
                'Attention', ...
                'YES','NO','YES');
            % Handle response
            if isempty(choice)==1 %window was closed
                return;
            end
            switch choice
                case 'YES'
                    d.name=answer;
                case 'NO'
                    return;
            end
        else
            d.name=answer;
            name{1,size(name,2)+1}=cell2mat(answer);
            filename=[d.pn '\name'];
            save(filename, 'name');
        end
    else    
        d.name=answer;
        filename=[d.pn '\name'];
        name=d.name;
        save(filename, 'name');
    end
end

%function for calculating deltaF/F
imd=d.imd;
pn=d.pn;
fn=cell2mat(d.name);
align=d.align;
[imddFF] = deltaFF(imd,pn,fn,align);
d.imd=imddFF;

%variable initialization for ROI processing
d.ROIsbw=zeros(size(d.imd,1),size(d.imd,2),1);
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.ROIs=[];
d.neuropil=[];

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
fname=[cell2mat(d.name) '_MIP'];
path=[d.pn '/',fname,'.png'];
path=regexprep(path,'\','/');
print(h,'-dpng','-r100',path); %-depsc for vector graphic
msgbox('Calculation done!','Success');





%%---------------------------Selecting and processing ROIs in calcium imaging video

% --- Executes on button press in pushbutton3.                         ROIs
function pushbutton3_Callback(~, ~, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p
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
if (d.bcount==0 || d.valid==1) && p.help==1
    d.valid=0;
    uiwait(msgbox('Please define the region of interest (ROI) by clicking around the area. The corners can be moved afterwards as well as the whole selected area. When satisfied with the selection please double-click!','Attention','modal'));
end

%displaying picture with previously marked ROIs
axes(handles.axes1);
if d.bcount>0
    colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8)); %selecting colors for ROIs
    singleFrame=d.mip; %getting picture into the value range from 0 to 1 for roipoly
    axes(handles.axes1); imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    for k=1:size(d.ROIsbw,3)
        if sum(sum(d.ROIsbw(:,:,k)))>0
            B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
            stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
            %drawing ROIs
            plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
            text(stat.Centroid(1),stat.Centroid(2),num2str(k));
        end
    end
    hold off;
    f=getframe(handles.axes1); %getting the MIP with ROI mask as one picture
    singleFrame=f.cdata;
elseif d.load==1 || d.auto==1
    colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8)); %selecting colors for ROIs
    singleFrame=d.mip; %getting picture into the value range from 0 to 1 for roipoly
    axes(handles.axes1); imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    for k=1:size(d.ROIsbw,3)
        if sum(sum(d.ROIsbw(:,:,k)))>0
            B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
            stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
            %drawing ROIs
            plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
            text(stat.Centroid(1),stat.Centroid(2),num2str(k));
        end
    end
    hold off;
    f=getframe(handles.axes1); %getting the MIP with ROI mask as one picture
    singleFrame=f.cdata;
elseif d.bcount==0
    singleFrame=d.mip; %getting picture into the value range from 0 to 1 for roipoly
    axes(handles.axes1); imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    f=getframe(handles.axes1); %getting the MIP with ROI mask as one picture
    singleFrame=f.cdata;
end

%manual ROI selection
ROI = roipoly(singleFrame);    %uint8 for CI_win_S1HL_02/20151118 & DORIC; int16 for CI_S1Hl_02
%resizing ROI since the figure from getframe is not the same resolution
B=imresize(ROI, [size(d.mip,1) size(d.mip,2)]);
ROI=B;

%check if ROI was selected correctly
if numel(find(ROI))==0
    singleFrame=d.mip;
    if d.dF==1 || d.pre==1
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    else
        axes(handles.axes1); imshow(singleFrame); hold on;
    end
    colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8)); %selecting colors for ROIs
    for k=1:size(d.ROIsbw,3)
        if sum(sum(d.ROIsbw(:,:,k)))>0
            B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
            stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
            %drawing ROIs
            plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
            text(stat.Centroid(1),stat.Centroid(2),num2str(k));
        end
    end
    hold off;
    d.valid=1;
    msgbox('Please select valid ROI! Check the instructions again.','ERROR');
    return;
end
%count times button is pressed
d.bcount=d.bcount+1;

if d.load==1 || d.auto==1 %if a ROI mask was loaded or automatic ROI detection was used
    d.ROIsbw(:,:,size(d.ROIsbw,3)+1)=ROI;
    d.mask = d.mask+ROI; %old ROI mask + new ROI mask
    %checking if ROIs are superimposed on each other
    if numel(find(d.mask>1))>0 && p.roistate==0
        choice = questdlg('Would you like to remove, add or make a new ROI?', ...
        'Attention', ...
        'Remove','Add','New','Remove');
        % Handle response
        if isempty(choice)==1
            d.bcount=d.bcount-1;
            d.ROIsbw=d.ROIsbw(:,:,1:size(d.ROIsbw,3)-1);
            d.mask = d.mask-ROI;
            return;
        end
        switch choice
            case 'Remove'
                %deleting the double assignments
                for m=1:size(d.ROIsbw,3)
                    ROIboth=d.ROIsbw(:,:,m)+ROI;
                    overlay=numel(find(ROIboth==2));
                    if overlay>0
                        ROIboth=ROIboth-(2*ROI);%removing 2*ROI since overlaps = 2
                        ROIboth(ROIboth<0)=0; %the romved ROI is -1 at some places, to remove that, everything below 0 = 0
                        d.ROIsbw(:,:,m)=ROIboth;
                    end
                end
                %determining indices where there are ROIs
                c=0;
                for j=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,j)))>0
                        c=c+1;
                        ROIindices(c,1)=j;
                    end
                end
                d.ROIsbw=d.ROIsbw(:,:,ROIindices);
                
                mask=sum(d.ROIsbw,3);
                mask(mask>1)=1;
                d.mask=mask;
                %plotting ROIs
                singleFrame=d.imd(:,:,round(handles.slider7.Value));
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
                for k=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,k)))>0
                        B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                        stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                        %drawing ROIs
                        plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                        text(stat.Centroid(1),stat.Centroid(2),num2str(k));
                    end
                end
                hold off;
                if length(ROIindices)+2==d.bcount
                    d.bcount=d.bcount-2;
                else
                    d.bcount=d.bcount-1;
                end
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined

                %saving ROI mask
                if p.roisave==0
                    % Construct a questdlg with two options
                    choice = questdlg('Would you like to save this ROI mask?', ...
                        'Attention', ...
                        'YES','NO','YES');
                    % Handle response
                    if isempty(choice)==1
                        return;
                    end
                    switch choice
                        case 'YES'
                            %saving ROI mask
                            filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                            ROImask=d.mask;
                            ROIsingles=d.ROIsbw;
                            save(filename, 'ROImask','ROIsingles');
                        case 'NO'
                            return;
                    end
                else
                    %saving ROI mask
                    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                    ROImask=d.mask;
                    ROIsingles=d.ROIsbw;
                    save(filename, 'ROImask','ROIsingles');
                    return;
                end
            case 'Add'
                %adding new ROI to old ROI
                for m=1:size(d.ROIsbw,3)
                    ROIboth=d.ROIsbw(:,:,m)+ROI;
                    overlay=numel(find(ROIboth==2));
                    if overlay>0
                        ROIboth=ROIboth+ROI;%removing 2*ROI since overlaps = 2
                        ROIboth(ROIboth>1)=1; %the romved ROI is -1 at some places, to remove that, everything below 0 = 0
                        d.ROIsbw(:,:,m)=ROIboth;
                    end
                end
                %deleting addition of new ROI
                d.ROIsbw=d.ROIsbw(:,:,1:size(d.ROIsbw,3)-1);
                
                mask=sum(d.ROIsbw,3);
                mask(mask>1)=1;
                d.mask=mask;
                %plotting ROIs
                singleFrame=d.imd(:,:,round(handles.slider7.Value));
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
                for k=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,k)))>0
                        B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                        stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                        %drawing ROIs
                        plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                        text(stat.Centroid(1),stat.Centroid(2),num2str(k));
                    end
                end
                hold off;
                d.bcount=d.bcount-1;
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined

                %saving ROI mask
                if p.roisave==0
                    % Construct a questdlg with two options
                    choice = questdlg('Would you like to save this ROI mask?', ...
                        'Attention', ...
                        'YES','NO','YES');
                    % Handle response
                    if isempty(choice)==1
                        return;
                    end
                    switch choice
                        case 'YES'
                            %saving ROI mask
                            filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                            ROImask=d.mask;
                            ROIsingles=d.ROIsbw;
                            save(filename, 'ROImask','ROIsingles');
                        case 'NO'
                            return;
                    end
                else
                    %saving ROI mask
                    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                    ROImask=d.mask;
                    ROIsingles=d.ROIsbw;
                    save(filename, 'ROImask','ROIsingles');
                    return;
                end
            case 'New'
                d.mask(d.mask>0)=1;
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
                for k=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,k)))>0
                        B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                        stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                        %drawing ROIs
                        plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                        text(stat.Centroid(1),stat.Centroid(2),num2str(k));
                    end
                end
                hold off;
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined

                %saving ROI mask
                filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                ROImask=d.mask;
                ROIsingles=d.ROIsbw;
                save(filename, 'ROImask','ROIsingles');
                return;
        end
    elseif numel(find(d.mask>1))>0 && p.roistate==1
        %adding new ROI to old ROI
        for m=1:size(d.ROIsbw,3)
            ROIboth=d.ROIsbw(:,:,m)+ROI;
            overlay=numel(find(ROIboth==2));
            if overlay>0
                ROIboth=ROIboth+ROI;%removing 2*ROI since overlaps = 2
                ROIboth(ROIboth>1)=1; %the romved ROI is -1 at some places, to remove that, everything below 0 = 0
                d.ROIsbw(:,:,m)=ROIboth;
            end
        end
        %deleting addition of new ROI
        d.ROIsbw=d.ROIsbw(:,:,1:size(d.ROIsbw,3)-1);

        mask=sum(d.ROIsbw,3);
        mask(mask>1)=1;
        d.mask=mask;
        %plotting ROIs
        singleFrame=d.imd(:,:,round(handles.slider7.Value));
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
        for k=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,k)))>0
                B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                text(stat.Centroid(1),stat.Centroid(2),num2str(k));
            end
        end
        hold off;
        d.bcount=d.bcount-1;
        d.pushed=4; %signals that ROIs were selected
        d.roisdefined=1; %signals that ROIs were defined

        %saving ROI mask
        if p.roisave==0
            % Construct a questdlg with two options
            choice = questdlg('Would you like to save this ROI mask?', ...
                'Attention', ...
                'YES','NO','YES');
            % Handle response
            if isempty(choice)==1
                return;
            end
            switch choice
                case 'YES'
                    %saving ROI mask
                    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                    ROImask=d.mask;
                    ROIsingles=d.ROIsbw;
                    save(filename, 'ROImask','ROIsingles');
                case 'NO'
                    return;
            end
        else
            %saving ROI mask
            filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
            ROImask=d.mask;
            ROIsingles=d.ROIsbw;
            save(filename, 'ROImask','ROIsingles');
            return;
        end
    elseif numel(find(d.mask>1))>0 && p.roistate==2
        %deleting the double assignments
        for m=1:size(d.ROIsbw,3)
            ROIboth=d.ROIsbw(:,:,m)+ROI;
            overlay=numel(find(ROIboth==2));
            if overlay>0
                ROIboth=ROIboth-(2*ROI);%removing 2*ROI since overlaps = 2
                ROIboth(ROIboth<0)=0; %the romved ROI is -1 at some places, to remove that, everything below 0 = 0
                d.ROIsbw(:,:,m)=ROIboth;
            end
        end
        %determining indices where there are ROIs
        c=0;
        for j=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,j)))>0
                c=c+1;
                ROIindices(c,1)=j;
            end
        end
        d.ROIsbw=d.ROIsbw(:,:,ROIindices);

        mask=sum(d.ROIsbw,3);
        mask(mask>1)=1;
        d.mask=mask;
        %plotting ROIs
        singleFrame=d.imd(:,:,round(handles.slider7.Value));
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
        for k=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,k)))>0
                B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                text(stat.Centroid(1),stat.Centroid(2),num2str(k));
            end
        end
        hold off;
        if length(ROIindices)+2==d.bcount
            d.bcount=d.bcount-2;
        else
            d.bcount=d.bcount-1;
        end
        d.pushed=4; %signals that ROIs were selected
        d.roisdefined=1; %signals that ROIs were defined

        %saving ROI mask
        if p.roisave==0
            % Construct a questdlg with two options
            choice = questdlg('Would you like to save this ROI mask?', ...
                'Attention', ...
                'YES','NO','YES');
            % Handle response
            if isempty(choice)==1
                return;
            end
            switch choice
                case 'YES'
                    %saving ROI mask
                    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                    ROImask=d.mask;
                    ROIsingles=d.ROIsbw;
                    save(filename, 'ROImask','ROIsingles');
                case 'NO'
                    return;
            end
        else
            %saving ROI mask
            filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
            ROImask=d.mask;
            ROIsingles=d.ROIsbw;
            save(filename, 'ROImask','ROIsingles');
            return;
        end
    elseif numel(find(d.mask>1))>0 && p.roistate==3
        d.mask(d.mask>0)=1;
        singleFrame=d.mip;
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
        for k=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,k)))>0
                B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                text(stat.Centroid(1),stat.Centroid(2),num2str(k));
            end
        end
        hold off;
        d.pushed=4; %signals that ROIs were selected
        d.roisdefined=1; %signals that ROIs were defined

        %saving ROI mask
        filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
        ROImask=d.mask;
        ROIsingles=d.ROIsbw;
        save(filename, 'ROImask','ROIsingles');
        return;
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
    colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
    for k=1:size(d.ROIsbw,3)
        if sum(sum(d.ROIsbw(:,:,k)))>0
            B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
            stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
            %drawing ROIs
            plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
            text(stat.Centroid(1),stat.Centroid(2),num2str(k));
        end
    end
    hold off;
    d.pushed=4; %signals that ROIs were selected
    d.roisdefined=1; %signals that ROIs were defined

    %saving ROI mask
    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
    ROImask=d.mask;
    ROIsingles=d.ROIsbw;
    save(filename, 'ROImask','ROIsingles');
else
    d.ROIsbw(:,:,d.bcount)=ROI;
    d.mask = d.mask+ROI; %old ROI mask + new ROI mask
    %checking if ROIs are superimposed on each other
    if numel(find(d.mask>1))>0 && p.roistate==0
        choice = questdlg('Would you like to remove, add or make a new ROI?', ...
        'Attention', ...
        'Remove','Add','New','Remove');
        % Handle response
        if isempty(choice)==1
            d.bcount=d.bcount-1;
            d.ROIsbw=d.ROIsbw(:,:,1:size(d.ROIsbw,3)-1);
            d.mask = d.mask-ROI;
            return;
        end
        switch choice
            case 'Remove'
                %deleting the double assignments
                for m=1:size(d.ROIsbw,3)
                    ROIboth=d.ROIsbw(:,:,m)+ROI;
                    overlay=numel(find(ROIboth==2));
                    if overlay>0
                        ROIboth=ROIboth-(2*ROI);%removing 2*ROI since overlaps = 2
                        ROIboth(ROIboth<0)=0; %the romved ROI is -1 at some places, to remove that, everything below 0 = 0
                        d.ROIsbw(:,:,m)=ROIboth;
                    end
                end
                %determining indices where there are ROIs
                c=0;
                for j=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,j)))>0
                        c=c+1;
                        ROIindices(c,1)=j;
                    end
                end
                d.ROIsbw=d.ROIsbw(:,:,ROIindices);
                
                mask=sum(d.ROIsbw,3);
                mask(mask>1)=1;
                d.mask=mask;
                %plotting ROIs
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
                for k=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,k)))>0
                        B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                        stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                        %drawing ROIs
                        plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                        text(stat.Centroid(1),stat.Centroid(2),num2str(k));
                    end
                end
                hold off;
                if length(ROIindices)+2==d.bcount
                    d.bcount=d.bcount-2;
                else
                    d.bcount=d.bcount-1;
                end
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined

                %saving ROI mask & ROI order
                if p.roisave==0
                    % Construct a questdlg with two options
                    choice = questdlg('Would you like to save this ROI mask?', ...
                        'Attention', ...
                        'YES','NO','YES');
                    % Handle response
                    if isempty(choice)==1
                        return;
                    end
                    switch choice
                        case 'YES'
                            %saving ROI mask
                            filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                            ROImask=d.mask;
                            ROIsingles=d.ROIsbw;
                            save(filename, 'ROImask','ROIsingles');
                        case 'NO'
                            return;
                    end
                else
                    %saving ROI mask
                    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                    ROImask=d.mask;
                    ROIsingles=d.ROIsbw;
                    save(filename, 'ROImask','ROIsingles');
                    return;
                end
            case 'Add'
                %adding new ROI to old ROI
                for m=1:size(d.ROIsbw,3)
                    ROIboth=d.ROIsbw(:,:,m)+ROI;
                    overlay=numel(find(ROIboth==2));
                    if overlay>0
                        ROIboth=ROIboth+ROI;%removing 2*ROI since overlaps = 2
                        ROIboth(ROIboth>1)=1; %the romved ROI is -1 at some places, to remove that, everything below 0 = 0
                        d.ROIsbw(:,:,m)=ROIboth;
                    end
                end
                %deleting addition of new ROI
                d.ROIsbw=d.ROIsbw(:,:,1:size(d.ROIsbw,3)-1);
                
                mask=sum(d.ROIsbw,3);
                mask(mask>1)=1;
                d.mask=mask;
                %plotting ROIs
                singleFrame=d.imd(:,:,round(handles.slider7.Value));
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
                for k=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,k)))>0
                        B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                        stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                        %drawing ROIs
                        plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                        text(stat.Centroid(1),stat.Centroid(2),num2str(k));
                    end
                end
                hold off;
                d.bcount=d.bcount-1;
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined

                %saving ROI mask
                if p.roisave==0
                    % Construct a questdlg with two options
                    choice = questdlg('Would you like to save this ROI mask?', ...
                        'Attention', ...
                        'YES','NO','YES');
                    % Handle response
                    if isempty(choice)==1
                        return;
                    end
                    switch choice
                        case 'YES'
                            %saving ROI mask
                            filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                            ROImask=d.mask;
                            ROIsingles=d.ROIsbw;
                            save(filename, 'ROImask','ROIsingles');
                        case 'NO'
                            return;
                    end
                else
                    %saving ROI mask
                    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                    ROImask=d.mask;
                    ROIsingles=d.ROIsbw;
                    save(filename, 'ROImask','ROIsingles');
                    return;
                end
            case 'New'
                d.mask(d.mask>0)=1;
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
                for k=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,k)))>0
                        B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                        stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                        %drawing ROIs
                        plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                        text(stat.Centroid(1),stat.Centroid(2),num2str(k));
                    end
                end
                hold off;
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined

                %saving ROI mask
                filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                ROImask=d.mask;
                ROIsingles=d.ROIsbw;
                save(filename, 'ROImask','ROIsingles');
                return;
        end
    elseif numel(find(d.mask>1))>0 && p.roistate==1
        %adding new ROI to old ROI
        for m=1:size(d.ROIsbw,3)
            ROIboth=d.ROIsbw(:,:,m)+ROI;
            overlay=numel(find(ROIboth==2));
            if overlay>0
                ROIboth=ROIboth+ROI;%removing 2*ROI since overlaps = 2
                ROIboth(ROIboth>1)=1; %the romved ROI is -1 at some places, to remove that, everything below 0 = 0
                d.ROIsbw(:,:,m)=ROIboth;
            end
        end
        %deleting addition of new ROI
        d.ROIsbw=d.ROIsbw(:,:,1:size(d.ROIsbw,3)-1);

        mask=sum(d.ROIsbw,3);
        mask(mask>1)=1;
        d.mask=mask;
        %plotting ROIs
        singleFrame=d.imd(:,:,round(handles.slider7.Value));
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
        for k=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,k)))>0
                B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                text(stat.Centroid(1),stat.Centroid(2),num2str(k));
            end
        end
        hold off;
        d.bcount=d.bcount-1;
        d.pushed=4; %signals that ROIs were selected
        d.roisdefined=1; %signals that ROIs were defined

        %saving ROI mask
        if p.roisave==0
            % Construct a questdlg with two options
            choice = questdlg('Would you like to save this ROI mask?', ...
                'Attention', ...
                'YES','NO','YES');
            % Handle response
            if isempty(choice)==1
                return;
            end
            switch choice
                case 'YES'
                    %saving ROI mask
                    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                    ROImask=d.mask;
                    ROIsingles=d.ROIsbw;
                    save(filename, 'ROImask','ROIsingles');
                case 'NO'
                    return;
            end
        else
            %saving ROI mask
            filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
            ROImask=d.mask;
            ROIsingles=d.ROIsbw;
            save(filename, 'ROImask','ROIsingles');
            return;
        end
    elseif numel(find(d.mask>1))>0 && p.roistate==2
        %deleting the double assignments
        for m=1:size(d.ROIsbw,3)
            ROIboth=d.ROIsbw(:,:,m)+ROI;
            overlay=numel(find(ROIboth==2));
            if overlay>0
                ROIboth=ROIboth-(2*ROI);%removing 2*ROI since overlaps = 2
                ROIboth(ROIboth<0)=0; %the romved ROI is -1 at some places, to remove that, everything below 0 = 0
                d.ROIsbw(:,:,m)=ROIboth;
            end
        end
        %determining indices where there are ROIs
        c=0;
        for j=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,j)))>0
                c=c+1;
                ROIindices(c,1)=j;
            end
        end
        d.ROIsbw=d.ROIsbw(:,:,ROIindices);

        mask=sum(d.ROIsbw,3);
        mask(mask>1)=1;
        d.mask=mask;
        %plotting ROIs
        singleFrame=d.imd(:,:,round(handles.slider7.Value));
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
        for k=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,k)))>0
                B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                text(stat.Centroid(1),stat.Centroid(2),num2str(k));
            end
        end
        hold off;
        if length(ROIindices)+2==d.bcount
            d.bcount=d.bcount-2;
        else
            d.bcount=d.bcount-1;
        end
        d.pushed=4; %signals that ROIs were selected
        d.roisdefined=1; %signals that ROIs were defined

        %saving ROI mask
        if p.roisave==0
            % Construct a questdlg with two options
            choice = questdlg('Would you like to save this ROI mask?', ...
                'Attention', ...
                'YES','NO','YES');
            % Handle response
            if isempty(choice)==1
                return;
            end
            switch choice
                case 'YES'
                    %saving ROI mask
                    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                    ROImask=d.mask;
                    ROIsingles=d.ROIsbw;
                    save(filename, 'ROImask','ROIsingles');
                case 'NO'
                    return;
            end
        else
            %saving ROI mask
            filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
            ROImask=d.mask;
            ROIsingles=d.ROIsbw;
            save(filename, 'ROImask','ROIsingles');
            return;
        end
    elseif numel(find(d.mask>1))>0 && p.roistate==3
        d.mask(d.mask>0)=1;
        singleFrame=d.mip;
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
        for k=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,k)))>0
                B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                text(stat.Centroid(1),stat.Centroid(2),num2str(k));
            end
        end
        hold off;
        d.pushed=4; %signals that ROIs were selected
        d.roisdefined=1; %signals that ROIs were defined

        %saving ROI mask
        filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
        ROImask=d.mask;
        ROIsingles=d.ROIsbw;
        save(filename, 'ROImask','ROIsingles');
        return;
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
    colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
    for k=1:size(d.ROIsbw,3)
        if sum(sum(d.ROIsbw(:,:,k)))>0
            B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
            stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
            %drawing ROIs
            plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
            text(stat.Centroid(1),stat.Centroid(2),num2str(k));
        end
    end
    hold off;
    d.pushed=4; %signals that ROIs were selected
    d.roisdefined=1; %signals that ROIs were defined

    %saving ROI mask
    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
    ROImask=d.mask;
    ROIsingles=d.ROIsbw;
    save(filename, 'ROImask','ROIsingles');
end
d.decon=0; %calcium signal was not deconvoluted


% --- Executes on button press in pushbutton16.              CLEAR ALL ROIS
function pushbutton16_Callback(~, ~, handles)
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
d.neuropil=[];
d.ROIsbw=zeros(size(d.imd,1),size(d.imd,2),1);
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.roisdefined=0; %signals no ROIs were selected
d.load=0; %signals that no ROI mask was loaded
d.auto=0; %ROIs were not detected automatically
d.decon=0; %calcium signal was not deconvoluted

singleFrame=d.mip;
if d.dF==1
    axes(handles.axes1);
    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
else
    axes(handles.axes1); imshow(singleFrame);
end
msgbox('ROIs cleared!','Success');



% ---------------------------------------------------- IMPORT ROIs of cells
function CIrois_Callback(hObject, eventdata, handles)
% hObject    handle to CIrois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global p
%resets all varibles needed for selecting ROIs
d.bcount=0; %signals ROI button was not pressed
d.pushed=1; %signals video was loaded
%re-initialization of variables for ROI calculations
d.ROIs=[];
d.neuropil=[];
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.ROIsbw=zeros(size(d.imd,1),size(d.imd,2));
d.roisdefined=0; %signals no ROIs were selected
d.load=0; %signals that no ROI mask was loaded
d.ROIv=0; %no ROI values loaded
d.decon=0;

if d.pre==0
    msgbox('Please do preprocessing & Delta F/F calculation before proceeding!','ATTENTION');
    return;
elseif d.dF==0
    msgbox('Please do Delta F/F calculation before proceeding!','ATTENTION');
    return;
end

if p.help==1
    uiwait(msgbox('Select a "filename"ROIs.mat file!'));
end

%extracts filename
filepath=[d.pn '\'];
[fn,pn,~]=uigetfile([filepath '*.mat']);
TF = strfind(fn,'ROIs.mat');
%if cancel was pressed
if fn==0
    return;
elseif isempty(TF)==1
    uiwait(msgbox('You did not select a "filename"ROIs.mat file!','ERROR'));
end

%load the saved ROI mask, and order of labels
load([pn fn]);
d.mask=imresize(ROImask,[size(d.imd,1) size(d.imd,2)]);
ROIsbw=ROIsingles;
%plotting ROIs
singleFrame=d.imd(:,:,round(handles.slider7.Value));
axes(handles.axes1);
if d.dF==1 || d.pre==1
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
else
    imshow(singleFrame); hold on;
end
colors=repmat(d.colors,1,ceil(size(ROIsbw,3)/8));
for k=1:size(ROIsbw,3)
    if sum(sum(ROIsbw(:,:,k)))>0
        d.ROIsbw(:,:,k)=imresize(ROIsbw(:,:,k),[size(d.imd,1) size(d.imd,2)]);
        B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
        stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
        %drawing ROIs
        plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
        text(stat.Centroid(1),stat.Centroid(2),num2str(k));
    end
end
hold off;
d.pushed=4; %signals that ROIs were selected
d.roisdefined=1; %signals that ROIs were defined
d.load=1; %signals that ROIs were manually loaded
msgbox('Loading complete!');



% --- Executes on button press in pushbutton34.                   AUTO ROIs
function pushbutton34_Callback(~, ~, handles)
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p

if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
elseif d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
elseif d.pre==0
    msgbox('Please do preprocessing & Delta F/F calculation before proceeding!','ATTENTION');
    return;
elseif d.dF==0
    msgbox('Please perform Delta F/F calculation before selection ROIs!','ATTENTION');
    return;
elseif d.pushed==4
    choice = questdlg('Your current ROIs will be overwritten, is that okay?', ...
        'Attention', ...
        'YES','NO','YES');
        % Handle response
        if isempty(choice)==1
            return;
        end
        switch choice
            case 'YES'
                d.decon=0;
                d.ROIv=0;
                d.ROIs=[];
                d.neuropil=[];
            case 'NO'
                return;
        end
end

d.bcount=0;

%using function for calculating PCA & ICA
F=d.imd;
mip=d.mip;
pn=d.pn;
name=d.name;
[ROIsbw] = pcaica(F,mip,pn,name,handles);
%if cancel was pressed
if isempty(ROIsbw)==1 || sum(sum(sum(ROIsbw)))==0
    return;
end

%plotting ROIs
colors=repmat(d.colors,1,ceil(size(ROIsbw,3)/8));
for k=1:size(ROIsbw,3)
    B=bwboundaries(ROIsbw(:,:,k)); %boundaries of ROIs
    stat = regionprops(ROIsbw(:,:,k),'Centroid');
    %drawing ROIs
    plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
    text(stat.Centroid(1),stat.Centroid(2),num2str(k));
end
hold off;

d.ROIsbw=ROIsbw;
mask=sum(ROIsbw,3);
mask(mask>1)=1;
d.mask=mask;

d.pushed=4; %signals that ROIs were selected
d.roisdefined=1; %signals that ROIs were defined
d.auto=1; %signlas that automated ROI detection was used
d.decon=0; %calcium signal was not deconvoluted

%saving ROI mask
if p.roisave==0
    % Construct a questdlg with two options
    choice = questdlg('Would you like to save this ROI mask?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    if isempty(choice)==1
        return;
    end
    switch choice
        case 'YES'
            %saving ROI mask
            filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
            ROImask=d.mask;
            ROIsingles=d.ROIsbw;
            save(filename, 'ROImask','ROIsingles');
            msgbox('Done!');
        case 'NO'
    end
else
    %saving ROI mask
    filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
    ROImask=d.mask;
    ROIsingles=d.ROIsbw;
    save(filename, 'ROImask','ROIsingles');
    msgbox('Done!');
end



% --- Executes on button press in pushbutton14.             PLOT ROI VALUES
function pushbutton14_Callback(~, ~, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%*********************************
% Title: inputsdlg
% Author: Takeshi Ikuma
% Date: 2015
% Code version: 2.3.2
% Availability: https://de.mathworks.com/matlabcentral/fileexchange/25862-inputsdlg--enhanced-input-dialog-box
%*********************************
% Title: subaxis
% Author: Aslak Grinsted
% Date: 2014
% Code version: 1.1
% Availability: https://de.mathworks.com/matlabcentral/fileexchange/3696-subaxis-subplot
%*********************************

global d
global v
global p
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

%checking whether ROI values had been saved before and no ROI was added or
%removed
if d.ROIv==0 && isempty(d.ROIs)==1 && d.decon==0
    if isempty(p.nscale)==1
        %asking for scale of the video to determine neuropil radius of 20 um, doric model S 700um, model L 350um, nVista 650 um (shorter side), Miniscope 450um (shorter side)
        models=[700 350 650 450]; %predefined sizes of the different microscope models
        prompt = {'Enter the field of view size in um for short side:';'Select microscope model:'};
        name = 'Input for scale';
        formats = struct('type', {}, 'style', {}, 'items', {}, ...
          'format', {}, 'size', {});
        formats(1,1).type   = 'edit';
        formats(1,1).format = 'integer';
        formats(1,1).limits = [50 5000];
        formats(1,1).size = [100 18];

        formats(2,1).type   = 'list';
        formats(2,1).style  = 'popupmenu';
        formats(2,1).items  = {'doric model S', 'doric model L', 'nVista', 'Miniscope'};
        defaultanswer = {350, 2};

        [answer, canceled] = inputsdlg(prompt, name, formats, defaultanswer);
        if canceled==1
            return;
        end
        if answer{1,1}~=700 && answer{1,1}~=350 && answer{1,1}~=650 && answer{1,1}~=450 %if any manual input was made that does not equal the predefined sizes
            um=answer{1,1}; %take the manual input
        else
            um=models(1,answer{2,1}); %otherwise take the list input
        end
        if size(d.imd,1)<size(d.imd,2) %determining the shorter side of the video
            shorterSide=floor(floor(size(d.imd,1)/0.8)/0.4); %recalculating original pixel size by reversing cutting off 80% and downsampling by 40%
        else
            shorterSide=floor(floor(size(d.imd,2)/0.8)/0.4); %recalculating original pixel size by reversing cutting off 80% and downsampling by 40%
        end
        scale=shorterSide/um; %pixel divided by um equals the scale to convert from um to pixel
        neuropilRadius=round(20*scale); %the needed neuropil radius of 20 um equals 20 times the scale to obtain the radius in pixel
        p.nscale=neuropilRadius;
        %saving scale
        filename=[d.pn '\nscale'];
        nscale=p.nscale;
        save(filename, 'nscale');
        %saving preference
        filename=[cd '\preferences'];
        preferences.nscale=p.nscale;
        save(filename, 'preferences');
        else
            if p.help==1
                uiwait(msgbox('Please remember to change the microscope scale in preferences in case that your microscope has changed!','Attention'));
            end
    end
    
    %labeling ROIs for every frame of the video
    n=size(d.imd,3);
    numROIs=size(d.ROIsbw,3); %number of ROIs
    d.ROIs=cell(size(d.imd,3),numROIs);
    d.neuropil=cell(size(d.imd,3),numROIs);
    ROIcenter=cell(1,numROIs);
    se=strel('disk',p.nscale,8);
    h=waitbar(0,'Labeling ROIs');
    for j=1:numROIs
        % You can only multiply integers if they are of the same type.
        ROIsc = cast(d.ROIsbw(:,:,j), class(d.imd(:,:,1)));
        ROIc=regionprops(d.ROIsbw(:,:,j),'Centroid');
        ROIcenter{1,j}=ROIc.Centroid;
        for i=1:n
            imdrem= ROIsc .* d.imd(:,:,i);
            d.ROIs{i,j}=imdrem(imdrem~=0);
        end
        %neuropil around the ROI
        neurop=imdilate(ROIsc,se);
        neurop2=neurop-ROIsc;
        for i=1:n
            imdneu= neurop2 .* d.imd(:,:,i);
            d.neuropil{i,j}=imdneu(imdneu~=0);
        end
        try
            waitbar(j/numROIs,h);
        catch
            d.ROIs=[];
            d.neuropil=[];
            return;
        end
    end
    close(h);
    
    nframes=size(d.imd,3);

    % calculate mean grey value of ROIs in percent
    d.ROImeans=zeros(size(d.ROIs,1),size(d.ROIs,2));
    numROIs=size(d.ROIs,2);
    h=waitbar(0,'Calculating ROI values');
    for k=1:numROIs
        for i=1:nframes
            ROIm=mean(d.ROIs{i,k});
            neuropilm=mean(d.neuropil{i,k});
            d.ROImeans(i,k)=(ROIm-neuropilm*p.options.neuF)*100; %in percent
        end
        d.ROImeans(:,k)=detrend(d.ROImeans(:,k)); %removing global trends
        try
            waitbar(k/numROIs,h);
        catch
            d.ROImeans=[];
            return;
        end
    end
    close(h);

    %identifying cells that have been segmented into multiple ROIs by
    %cross-correlation
    change=0;
    for m=1:size(d.ROImeans,2)
        if max(d.ROImeans(:,m))<p.options.chg %deleting ROIs which maximum fluorescence change is smaller than 0.8%
            change=1;
            d.ROIsbw(:,:,m)=zeros(size(d.ROIsbw,1),size(d.ROIsbw,2),1);
        end
        for n=1:size(d.ROImeans,2)
            if m~=n
                ROIdist=pdist([ROIcenter{1,m};ROIcenter{1,n}]);
                if ROIdist<p.options.ROIdist %ROIs in close vicinity to eachother have to be checked for similar Ca signal
                    ROIcorr=corrcoef(d.ROImeans(:,m),d.ROImeans(:,n));
                    ROIboth=d.ROIsbw(:,:,m)+d.ROIsbw(:,:,n);
                    if ROIcorr(1,2)>p.options.sigcorr
                        change=1;
                        ROIboth(ROIboth>1)=1;
                        d.ROIsbw(:,:,m)=ROIboth;
                        d.ROIsbw(:,:,n)=zeros(size(d.ROIsbw,1),size(d.ROIsbw,2),1);
                    end
                end
            end
        end
    end
    %determining indices where there are ROIs
    c=0;
    ROIindices=[];
    for j=1:size(d.ROIsbw,3)
        if sum(sum(d.ROIsbw(:,:,j)))>0
            c=c+1;
            ROIindices(c,1)=j;
        end
    end
    d.ROIsbw=d.ROIsbw(:,:,ROIindices);
    %merging multiple cell detections
    for j=1:size(d.ROIsbw,3)
        [~,ROInum]=bwlabel(d.ROIsbw(:,:,j));
        c=0;
        while ROInum>1
            SE=strel('disk',1+c);
            d.ROIsbw(:,:,j) = imdilate(d.ROIsbw(:,:,j),SE);
            [~,ROInum]=bwlabel(d.ROIsbw(:,:,j));
            c=c+1;
        end
    end

    if change==1
        %plotting ROIs
        singleFrame=d.mip;
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
        for k=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,k)))>0
                B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                text(stat.Centroid(1),stat.Centroid(2),num2str(k));
            end
        end
        hold off;
        %saving ROI mask
        % Construct a questdlg with two options
        choice = questdlg('Would you like to save this ROI mask?', ...
            'Attention', ...
            'YES','NO','YES');
        % Handle response
        if isempty(choice)==1
            fn=[cell2mat(d.name) 'ROIs.mat'];
            load([d.pn '\' fn]);
            d.mask=ROImask;
            d.ROIsbw=ROIsingles;
            %plotting ROIs
            singleFrame=d.mip;
            if d.dF==1 || d.pre==1
                imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
            else
                axes(handles.axes1); imshow(singleFrame); hold on;
            end
            colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
            for k=1:size(d.ROIsbw,3)
                if sum(sum(d.ROIsbw(:,:,k)))>0
                    B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                    stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                    %drawing ROIs
                    plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                    text(stat.Centroid(1),stat.Centroid(2),num2str(k));
                end
            end
            hold off;
            return;
        end
        switch choice
            case 'YES'
                filename=[d.pn '\' cell2mat(d.name) 'ROIs'];
                ROImask=d.mask;
                ROIsingles=d.ROIsbw;
                save(filename, 'ROImask','ROIsingles');
            case 'NO'
                fn=[cell2mat(d.name) 'ROIs.mat'];
                load([d.pn '\' fn]);
                d.mask=ROImask;
                d.ROIsbw=ROIsingles;
                %plotting ROIs
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
                for k=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,k)))>0
                        B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                        stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                        %drawing ROIs
                        plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                        text(stat.Centroid(1),stat.Centroid(2),num2str(k));
                    end
                end
                hold off;
                % Construct a questdlg with two options
                choice = questdlg('Would you like to proceed plotting the ROI values?', ...
                    'Attention', ...
                    'YES','NO','YES');
                % Handle response
                if isempty(choice)==1
                    return;
                end
                switch choice
                    case 'YES'
                    case'NO'
                        return;
                end
        end
        %if a change was made to the ROI mask labeling ROIs for every first frame of the video
        numROIs=size(d.ROIsbw,3); %number of ROIs
        ROIs=cell(1,numROIs);
        h=waitbar(0,'Labeling ROIs');
        for j=1:numROIs
            % You can only multiply integers if they are of the same type.
            ROIsc = cast(d.ROIsbw(:,:,j), class(d.imd(:,:,1)));
            imdrem= ROIsc .* d.imd(:,:,1);
            ROIs{1,j}=imdrem(imdrem~=0);
            try
                waitbar(j/numROIs,h);
            catch
                d.ROIs=[];
                return;
            end
        end
        close(h);
        %comparing the sum of values for all ROIs for the first frame to
        %identify changes in the ROI mask
        c=0;
        changedROIs=[];
        for i=1:numROIs
            if isequal(ROIs{1,i},d.ROIs{1,i})==0 %if the matrices for old ROI and new ROI are different, recalculation!
                c=c+1;
                changedROIs(1,c)=i; %varable saves all the indexes of changed ROIs;
            end
        end
        %labeling ROIs for every frame of the video
        n=size(d.imd,3);
        numROIs=size(d.ROIsbw,3); %number of ROIs
        ROIcenter=cell(1,numROIs);
        d.ROIs=d.ROIs(:,1:numROIs);
        d.neuropil=d.neuropil(:,1:numROIs);
        se=strel('disk',p.nscale,8);
        h=waitbar(0,'Labeling ROIs');
        for j=1:length(changedROIs)
            % You can only multiply integers if they are of the same type.
            ROIsc = cast(d.ROIsbw(:,:,changedROIs(j)), class(d.imd(:,:,1)));
            ROIc=regionprops(d.ROIsbw(:,:,changedROIs(j)),'Centroid');
            ROIcenter{1,changedROIs(j)}=ROIc.Centroid;
            for i=1:n
                imdrem= ROIsc .* d.imd(:,:,i);
                d.ROIs{i,changedROIs(j)}=imdrem(imdrem~=0);
            end
            %neuropil around the ROI
            neurop=imdilate(ROIsc,se);
            neurop2=neurop-ROIsc;
            for i=1:n
                imdneu= neurop2 .* d.imd(:,:,i);
                d.neuropil{i,changedROIs(j)}=imdneu(imdneu~=0);
            end
            try
                waitbar(j/numROIs,h);
            catch
                d.ROIs=[];
                d.neuropil=[];
                return;
            end
        end
        close(h);

        nframes=size(d.imd,3);

        % calculate mean grey value of ROIs in percent
        numROIs=size(d.ROIs,2);
        d.ROImeans=d.ROImeans(:,1:numROIs);
        h=waitbar(0,'Calculating ROI values');
        for k=1:length(changedROIs)
            for i=1:nframes
                ROIm=mean(d.ROIs{i,changedROIs(k)});
                neuropilm=mean(d.neuropil{i,changedROIs(k)});
                d.ROImeans(i,changedROIs(k))=(ROIm-neuropilm*p.options.neuF)*100; %in percent
            end
            d.ROImeans(:,changedROIs(k))=detrend(d.ROImeans(:,changedROIs(k))); %removing global trends
            try
                waitbar(k/numROIs,h);
            catch
                d.ROImeans=[];
                return;
            end
        end
        close(h);
    end
    %saving ROI values
    filename=[d.pn '\' cell2mat(d.name) '_ROIvalues'];
    ROImeans=d.ROImeans;
    save(filename, 'ROImeans');
    d.ROIv=1;
    d.decon=0;
elseif isempty(d.ROIs)==0 && d.ROIv==0 && d.decon==1
    %if a change was made to the ROI mask labeling ROIs for every first frame of the video
    numROIs=size(d.ROIsbw,3); %number of ROIs
    oldnumROIs=size(d.cCaSignal,2);
    ROIs=cell(1,numROIs);
    h=waitbar(0,'Labeling ROIs');
    for j=1:numROIs
        % You can only multiply integers if they are of the same type.
        ROIsc = cast(d.ROIsbw(:,:,j), class(d.imd(:,:,1)));
        imdrem= ROIsc .* d.imd(:,:,1);
        ROIs{1,j}=imdrem(imdrem~=0);
        try
            waitbar(j/numROIs,h);
        catch
            d.ROIs=[];
            d.neuropil=[];
            return;
        end
    end
    close(h);
    %comparing the sum of values for all ROIs for the first frame to
    %identify changes in the ROI mask
    c=0;
    changedROIs=[];
    if numROIs>oldnumROIs
        for i=1:oldnumROIs
            if isequal(ROIs{1,i},d.ROIs{1,i})==0 %if the matrices for old ROI and new ROI are different, recalculation!
                c=c+1;
                changedROIs(1,c)=i; %varable saves all the indexes of changed ROIs;
            end
        end
        cc=0;
        chindx=length(changedROIs);
        for k=oldnumROIs+1:numROIs
            cc=cc+1;
            changedROIs(1,chindx+cc)=k;
        end
    else
        for i=1:numROIs
            if isequal(ROIs{1,i},d.ROIs{1,i})==0 %if the matrices for old ROI and new ROI are different, recalculation!
                c=c+1;
                changedROIs(1,c)=i; %varable saves all the indexes of changed ROIs;
            end
        end
        
    end
    if isempty(changedROIs)==1 && numROIs<oldnumROIs
        d.bcount=numROIs;
        d.ROIs=d.ROIs(:,1:numROIs);
        d.ROImeans=d.ROImeans(:,1:numROIs);
        d.neuropil=d.neuropil(:,1:numROIs);
        d.cCaSignal=d.cCaSignal(:,1:numROIs);
        d.spikes=d.spikes(:,1:numROIs);
        d.ts=d.ts(1,1:numROIs);
        d.amp=d.amp(1,1:numROIs);
        d.NoofSpikes=d.NoofSpikes(1:numROIs,1);
        d.Frequency=d.Frequency(1:numROIs,1);
        d.Amplitude=d.Amplitude(1:numROIs,1);
        %saving calcium signal
        ROImeans=d.ROImeans;
        cCaSignal=d.cCaSignal;
        spikes=d.spikes;
        d.decon=1; %signal was deconvoluted;
        decon=d.decon;
        filename=[d.pn '\' cell2mat(d.name) 'CaSignal'];
        save(filename, 'ROImeans','cCaSignal','spikes','decon');
    else
        %labeling ROIs for every frame of the video
        n=size(d.imd,3);
        numROIs=size(d.ROIsbw,3); %number of ROIs
        ROIcenter=cell(1,numROIs);
        if numROIs<oldnumROIs
            d.ROIs=d.ROIs(:,1:numROIs);
            d.neuropil=d.neuropil(:,1:numROIs);
        end
        se=strel('disk',p.nscale,8);
        h=waitbar(0,'Labeling ROIs');
        for j=1:length(changedROIs)
            % You can only multiply integers if they are of the same type.
            ROIsc = cast(d.ROIsbw(:,:,changedROIs(j)), class(d.imd(:,:,1)));
            ROIc=regionprops(d.ROIsbw(:,:,changedROIs(j)),'Centroid');
            ROIcenter{1,changedROIs(j)}=ROIc.Centroid;
            for i=1:n
                imdrem= ROIsc .* d.imd(:,:,i);
                d.ROIs{i,changedROIs(j)}=imdrem(imdrem~=0);
            end
            %neuropil around the ROI
            neurop=imdilate(ROIsc,se);
            neurop2=neurop-ROIsc;
            for i=1:n
                imdneu= neurop2 .* d.imd(:,:,i);
                d.neuropil{i,changedROIs(j)}=imdneu(imdneu~=0);
            end
            try
                waitbar(j/numROIs,h);
            catch
                d.ROIs=[];
                d.neuropil=[];
                return;
            end
        end
        close(h);

        nframes=size(d.imd,3);

        % calculate mean grey value of ROIs in percent
        numROIs=size(d.ROIs,2);
        if numROIs<oldnumROIs
            d.ROImeans=d.ROImeans(:,1:numROIs);
        end
        h=waitbar(0,'Calculating ROI values');
        for k=1:length(changedROIs)
            for i=1:nframes
                ROIm=mean(d.ROIs{i,changedROIs(k)});
                neuropilm=mean(d.neuropil{i,changedROIs(k)});
                d.ROImeans(i,changedROIs(k))=(ROIm-neuropilm*p.options.neuF)*100; %in percent
            end
            d.ROImeans(:,changedROIs(k))=detrend(d.ROImeans(:,changedROIs(k))); %removing global trends
            try
                waitbar(k/numROIs,h);
            catch
                d.ROImeans=[];
                return;
            end
        end
        close(h);
        
        %identifying cells that have been segmented into multiple ROIs by
        %cross-correlation
        change=0;
        for m=1:size(d.ROImeans,2)
            if max(d.ROImeans(:,m))<p.options.chg %deleting ROIs which maximum fluorescence change is smaller than 0.8%
                change=1;
                d.ROIsbw(:,:,m)=zeros(size(d.ROIsbw,1),size(d.ROIsbw,2),1);
            end
            for n=1:size(d.ROImeans,2)
                if m~=n
                    ROIdist=pdist([ROIcenter{1,m};ROIcenter{1,n}]);
                    if ROIdist<p.options.ROIdist %ROIs in close vicinity to eachother have to be checked for similar Ca signal
                        ROIcorr=corrcoef(d.ROImeans(:,m),d.ROImeans(:,n));
                        ROIboth=d.ROIsbw(:,:,m)+d.ROIsbw(:,:,n);
                        if ROIcorr(1,2)>p.options.sigcorr
                            change=1;
                            ROIboth(ROIboth>1)=1;
                            d.ROIsbw(:,:,m)=ROIboth;
                            d.ROIsbw(:,:,n)=zeros(size(d.ROIsbw,1),size(d.ROIsbw,2),1);
                        end
                    end
                end
            end
        end
        %determining indices where there are ROIs
        c=0;
        ROIindices=[];
        for j=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,j)))>0
                c=c+1;
                ROIindices(c,1)=j;
            end
        end
        d.ROIsbw=d.ROIsbw(:,:,ROIindices);

        %saving ROI values
        filename=[d.pn '\' cell2mat(d.name) '_ROIvalues'];
        ROImeans=d.ROImeans;
        save(filename, 'ROImeans');
        d.ROIv=1;
        d.decon=0;
    end
end

colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8)); %colors for traces

%function for calculating ROI fluorescence values
if d.decon==0;
    ROImeans=d.ROImeans;
    framerate=d.framerate;
    [ROImeans,cCaSignal,spikes,ts,amp,NoofSpikes,Frequency,Amplitude] = ROIFvalues(ROImeans,framerate);
    if isempty(ROImeans)==1
        return;
    end
    d.ROImeans=ROImeans;
    d.cCaSignal=cCaSignal;
    d.spikes=spikes;
    d.ts=ts;
    d.amp=amp;
    d.NoofSpikes=NoofSpikes;
    d.Frequency=Frequency;
    d.Amplitude=Amplitude;
    %saving calcium signal
    d.decon=1; %signal was deconvoluted;
    decon=d.decon;
    filename=[d.pn '\' cell2mat(d.name) 'CaSignal'];
    save(filename, 'ROImeans','cCaSignal','spikes','decon');
end

%plotting ROI values
%initializing that only 8 subplots will be in one figure
onesub=(1:8);
anysub=repmat(onesub,1,ceil(size(d.ROImeans,2)/8));
check=(9:8:200);
check2=(8:8:200);

figure('color','w');
for j=1:size(d.ROImeans,2)
    if ismember(j,check)==1 %if ROI number is 9, 18, 27... new figure is initialized, this way there are only 8 ROIs per figure
        figure('color','w');
    end
    subaxis(8,1,anysub(j),'SpacingVert',.01,'ML',.1,'MR',.1); %using subaxis for tight layout of traces
    plot(d.cCaSignal(:,j),'Color',colors{1,j}),hold on;
    axlim=get(gca,'YLim');
    ylim([min(d.cCaSignal(:,j)) 2*round((axlim(2)+1)/2)]); %y-axis limits: from minimum value of the current ROI to round to next even number of current axis maximum value
    if v.behav==1 %drawing bars signalling the various defined behaviors, if behaviors have been defined
        axlim=get(gca,'YLim'); %limits of y-axis
        for l=1:v.amount
            for m=1:length(v.barstart.(char(v.name{1,l})))
                if isempty(v.barstart.(char(v.name{1,l})))==0
                    rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),axlim(1),v.barwidth.(char(v.name{1,l}))(m),axlim(2)*2],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
                end
            end
        end
        plot(d.cCaSignal(:,j),'Color',colors{1,j}),hold on;
    end
    strings=sprintf('ROI No.%d',j);
    %title('ROI values in percent');
    if ismember(j,check2)==1 || j==size(d.ROImeans,2) %writing x-axis label only for last plot in the figure
        xlabel('time [s]');
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
    if sum(d.spikes(:,j))>0
        plot(find(d.spikes(:,j)),max(d.cCaSignal(:,j))+0.5,'k.');
    end
end
hold off;

%plotting raster plot
fig=figure;
subplot(2,1,1);
if v.behav==1 %drawing bars signalling the various defined behaviors, if behaviors have been defined
    for l=1:v.amount
        for m=1:length(v.barstart.(char(v.name{1,l})))
            if isempty(v.barstart.(char(v.name{1,l})))==0
                rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),0,v.barwidth.(char(v.name{1,l}))(m),size(d.ROImeans,2)],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
            end
        end
    end
end
for j=1:size(d.ROImeans,2)
    if sum(d.spikes(:,j))>0
        plot(find(d.spikes(:,j)),j,'k.');
    end
    hold on;
    title('Cell activity raster plot');
    xlabel('time [s]');
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
if v.behav==1 %drawing bars signalling the various defined behaviors, if behaviors have been defined
    plot(sum(d.spikes,2));
    axlim=get(gca,'YLim');
    for l=1:v.amount
        for m=1:length(v.barstart.(char(v.name{1,l})))
            if isempty(v.barstart.(char(v.name{1,l})))==0
                rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),0,v.barwidth.(char(v.name{1,l}))(m),axlim(1,2)],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
            end
        end
    end
    plot(sum(d.spikes,2),'k');
else
    plot(sum(d.spikes,2));
end
xlabel('time [s]');
ylabel('Calcium transients [1/s]');
xlim([0 round(size(d.imd,3))]);
%changing tick labels from frames to seconds by dividing by framerate
ticlabel=get(gca,'XTickLabel');
for k=1:length(ticlabel)
    ticlabel{k,1}=str2num(ticlabel{k,1});
end
ticlabel=cell2mat(ticlabel);
ticlabel=ticlabel./d.framerate;
set(gca,'XTickLabel',ticlabel);

%calculating statistics if behavior is avaiable
if v.behav==1
    names=fieldnames(v.barstart); %names of defined behaviors
    spkfreq=[];
    spkno=sum(d.spikes,2);
    spkasize=size(d.spikes,1);
    for j=1:v.amount
        %creating array with framenumbers where certain behavior was
        %detected
        behavior=[];
        for k=1:length(v.barstart.(names{j,1}))
            behavior=[behavior,v.barstart.(names{j,1})(k):v.barstart.(names{j,1})(k)+v.barwidth.(names{j,1})(k)];
        end
        behaviors=behavior';
        spkbehav=spkno(behaviors,1);
        spkbsum=sum(spkbehav);
        spkfreq.(names{j,1})=spkbsum/(spkasize/d.framerate);
    end
end

%saving traces
% Construct a questdlg with two options
choice = questdlg('Would you like to save these traces?', ...
    'Attention', ...
    'YES','NO','YES');
% Handle response
if isempty(choice)==1
    return;
end
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
                fname=sprintf('traces_%d',j);
                ffname=[cell2mat(d.name) '_' fname];
                path=[d.pn '/traces/',ffname,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
            end
            %saving rasterplot
            figurenum=sprintf('-f%d',hfnum);
            fname=[cell2mat(d.name) '_rasterplot'];
            path=[d.pn '/traces/',fname,'.png'];
            path=regexprep(path,'\','/');
            print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
            
            %saving ROImask as figure
            colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8)); %selecting colors for ROIs
            singleFrame=d.mip./max(max(d.mip)); %getting picture into the value range from 0 to 1 for roipoly
            h=figure; imshow(singleFrame);hold on;
            for k=1:size(d.ROIsbw,3)
                if sum(sum(d.ROIsbw(:,:,k)))>0
                    B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                    stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                    %drawing ROIs
                    plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                    text(stat.Centroid(1),stat.Centroid(2),num2str(k));
                end
            end
            hold off;
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            fname=[cell2mat(d.name) '_ROImask'];
            path=[d.pn '/traces/',fname,'.png'];
            path=regexprep(path,'\','/');
            print(h,'-dpng','-r200',path); %-depsc for vector graphic
            close(h);
            
            %saving fluorescence traces over time
            h=figure;imagesc(d.ROImeans',[round(min(min(d.ROImeans))) round(max(max(d.ROImeans)))]),c=colorbar;
%             set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            title('Fluorescence traces');
            xlabel('time [s]');
            ylabel('ROI number');
            c.Label.String='dF/F in %';
            xlim([0 round(size(d.imd,3))]);
            ticlabel=get(gca,'XTickLabel');
            for k=1:length(ticlabel)
                ticlabel{k,1}=str2num(ticlabel{k,1});
            end
            ticlabel=cell2mat(ticlabel);
            ticlabel=ticlabel./d.framerate;
            set(gca,'XTickLabel',ticlabel);
%             set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            fname=[cell2mat(d.name) '_Fluo'];
            path=[d.pn '/traces/',fname,'.png'];
            path=regexprep(path,'\','/');
            print(h,'-dpng','-r200',path); %-depsc for vector graphic
            close(h);
            
            %calculating event behavior if trigger file was loaded
            if isempty(d.triggerts)==0 && d.decon==1
                %plotting mean fluorescence
                mVal=mean(d.cCaSignal,2);
                rep=zeros(size(d.triggerts,1),sum(p.win)+1);
                for i=1:size(d.triggerts,1)
                    rep(i,:)=mVal(d.triggerts(i,1)-p.win(1):d.triggerts(i,1)+p.win(2));
                end
                meantrig=mean(rep,1);
                e = std(rep,[],1);
                eup=meantrig+e;
                edown=meantrig-e;
                h=figure;
                area(eup,'FaceColor',[0.8 0.8 0.8],'EdgeColor',[1 1 1]),hold on,area(edown,'FaceColor',[1 1 1],'EdgeColor',[1 1 1]),plot(meantrig,'k','LineWidth',2);
                %plotting vertical line to indicate time of trigger
                aylim=get(gca,'YLim');
                a=p.win(1);
                plot([a a],aylim,'LineWidth',2);hold off;
                title('Mean fluorescence trace with trigger');
                xlabel('time [s]');
                ylabel('dF/F in %');
                axlim=get(gca,'XLim');
                ticlabel=get(gca,'XTickLabel');
                for k=1:length(ticlabel)
                    ticlabel{k,1}=str2num(ticlabel{k,1});
                end
                ticlabel=cell2mat(ticlabel);
                ticlabel=ticlabel./d.framerate;
                set(gca,'XTickLabel',ticlabel);
                fname=[cell2mat(d.name) '_Fluotrig'];
                path=[d.pn '/traces/',fname,'.png'];
                path=regexprep(path,'\','/');
                print(h,'-dpng','-r200',path); %-depsc for vector graphic
                close(h);

                %plotting mean fluorescence with trigger as heat map image
                h=figure;imagesc(rep),c=colorbar;hold on;
                %plotting vertical line to indicate time of trigger
                a=p.win(1);
                plot([a a],[0 size(rep,1)+0.5],'w','LineWidth',2);
                title('Fluorescence traces with trigger');
                xlabel('time [s]');
                ylabel('Trial number');
                c.Label.String='dF/F in %';
                ticlabel=get(gca,'XTickLabel');
                for k=1:length(ticlabel)
                    ticlabel{k,1}=str2num(ticlabel{k,1});
                end
                ticlabel=cell2mat(ticlabel);
                ticlabel=ticlabel./d.framerate;
                set(gca,'XTickLabel',ticlabel);
                fname=[cell2mat(d.name) '_Fluotrigheat'];
                path=[d.pn '/traces/',fname,'.png'];
                path=regexprep(path,'\','/');
                print(h,'-dpng','-r200',path); %-depsc for vector graphic
                close(h);
            end

            %saving table
            filename=[d.pn '\traces\ROIs_' cell2mat(d.name) '.xls'];
            ROInumber=cell(size(d.cCaSignal,2),1);
            for k=1:size(d.cCaSignal,2)
                ROInumber{k,1}=sprintf('ROI No.%d',k);
            end
            NoofSpikes=d.NoofSpikes;
            Frequency=d.Frequency;
            Amplitude=d.Amplitude;
            T=table(NoofSpikes,Frequency,Amplitude,...
                'RowNames',ROInumber);
            writetable(T,filename,'WriteRowNames',true);
            
            %saving data
            field1='framerate';
            field2='rawwave';
            field3='wave';
            field4='spikes';
            field5='amp';
            field6='ts';
            value1=d.framerate;
            value2=d.ROImeans;
            value3=d.cCaSignal;
            value5=d.amp;
            value6=d.ts;
            value4=struct(field5,value5,field6,value6);
            traces=struct(field1,value1,field2,value2,field3,value3,field4,value4);
            filename=[d.pn '\traces\traces_' cell2mat(d.name)];
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
                    fname=sprintf('traces_behav_%d',j);
                    ffname=[cell2mat(d.name) '_' fname];
                    figurenum=sprintf('-f%d',numseries(j));
                    path=[d.pn '/traces/',ffname,'.png'];
                    path=regexprep(path,'\','/');
                    print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
                end
                %saving rasterplot
                fname=[cell2mat(d.name) '_rasterplot_behav'];
                figurenum=sprintf('-f%d',hfnum);
                path=[d.pn '/traces/',fname,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
                %saving table
                filename=[d.pn '\traces\freqbehav_' cell2mat(d.name) '.xls'];
                T=struct2table(spkfreq);
                writetable(T,filename);

                %saving mean values of ROIs over time with behavior
                mVal=mean(d.cCaSignal,2);
                h=figure;
%                 set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                for l=1:v.amount
                    for m=1:length(v.barstart.(char(v.name{1,l})))
                        if isempty(v.barstart.(char(v.name{1,l})))==0
                            rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),round(min(mVal),1),v.barwidth.(char(v.name{1,l}))(m),abs(round(min(mVal),1))+ceil(max(mVal))],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
                        end
                    end
                end
                plot(mVal,'k');
                title('Mean fluorescence trace with behavior');
                xlabel('time [s]');
                ylabel('dF/F in %');
                xlim([0 round(size(d.imd,3))]);
                ticlabel=get(gca,'XTickLabel');
                for k=1:length(ticlabel)
                    ticlabel{k,1}=str2num(ticlabel{k,1});
                end
                ticlabel=cell2mat(ticlabel);
                ticlabel=ticlabel./d.framerate;
                set(gca,'XTickLabel',ticlabel);
%                 set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                fname=[cell2mat(d.name) '_meanFluobehav'];
                path=[d.pn '/traces/',fname,'.png'];
                path=regexprep(path,'\','/');
                print(h,'-dpng','-r200',path); %-depsc for vector graphic
                close(h);
                %saving mean event rate with behavior
                meanspks=mean(d.spikes,2)*d.framerate;
                h=figure;
%                 set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                plot(1:size(meanspks,1),meanspks,'k'); hold on;
                axlim=get(gca,'YLim');
                for l=1:v.amount
                    for m=1:length(v.barstart.(char(v.name{1,l})))
                        if isempty(v.barstart.(char(v.name{1,l})))==0
                            rectangle('Position',[v.barstart.(char(v.name{1,l}))(m),0,v.barwidth.(char(v.name{1,l}))(m),axlim(2)],'edgecolor',colorsb{1,l},'facecolor',colorsb{1,l}),hold on;
                        end
                    end
                end
                plot(1:size(meanspks,1),meanspks,'k');
                title('Mean event rate with behavior');
                xlabel('time [s]');
                ylabel('Calcium transients [1/s]');
                xlim([0 round(size(d.imd,3))]);
                ticlabel=get(gca,'XTickLabel');
                for k=1:length(ticlabel)
                    ticlabel{k,1}=str2num(ticlabel{k,1});
                end
                ticlabel=cell2mat(ticlabel);
                ticlabel=ticlabel./d.framerate;
                set(gca,'XTickLabel',ticlabel);
%                 set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                fname=[cell2mat(d.name) '_meanspksbehav'];
                path=[d.pn '/traces/',fname,'.png'];
                path=regexprep(path,'\','/');
                print(h,'-dpng','-r200',path); %-depsc for vector graphic
                close(h);
                try
                    close(f);
                catch
                end
                
                %heat map triggered to behaviors
                % Construct a questdlg with two options
                choice = questdlg('Would you like to save dF/F heat maps triggered to your behaviors?', ...
                    'Attention', ...
                    'YES','NO','YES');
                % Handle response
                if isempty(choice)==1
                    return;
                end
                switch choice
                    case 'YES'
                        %define display window
                        if isempty(p.win)==1
                            prompt = {'Enter window size in s ["time before trigger" "time after trigger"] e.g.: 1 3'};
                            dlg_title = 'Window';
                            num_lines = 1;
                            answer = inputdlg(prompt,dlg_title,num_lines);
                            if isempty(answer)==1
                                return;
                            end
                            win=str2num(cell2mat(answer));
                            test1=0;
                            test2=[0 0];
                            if size(win)==size(test1)
                                uiwait(msgbox('Please enter more than 1 number!','Attention'));
                                return;
                            elseif sum(size(win)~=size(test2))>0
                                uiwait(msgbox('Please do not enter more than 2 numbers!','Attention'));
                                return;
                            end
                            %converting seconds to frames
                            win=win*d.framerate;
                            p.win=win;
                            %saving scale
                            filename=[d.pn '\win'];
                            save(filename, 'win');
                            %saving preference
                            filename=[cd '\preferences'];
                            preferences.win=p.win;
                            save(filename, 'preferences');
                        end

                        
                        mVal=mean(d.cCaSignal,2);
                        for k=1:v.amount
                            if v.barstart.(char(v.name{1,k}))(1,1)<=p.win(1)
                                rep=zeros(size(v.barstart.(char(v.name{1,k})),1)-1,sum(p.win)+1);
                                for i=2:size(v.barstart.(char(v.name{1,k})),1)
                                    rep(i,:)=mVal(v.barstart.(char(v.name{1,k}))(i,1)-p.win(1):v.barstart.(char(v.name{1,k}))(i,1)+p.win(2));
                                end
                            elseif v.barstart.(char(v.name{1,k}))(end)>=size(mVal,1)-p.win(2)
                                rep=zeros(size(v.barstart.(char(v.name{1,k})),1)-1,sum(p.win)+1);
                                for i=1:size(v.barstart.(char(v.name{1,k})),1)-1
                                    rep(i,:)=mVal(v.barstart.(char(v.name{1,k}))(i,1)-p.win(1):v.barstart.(char(v.name{1,k}))(i,1)+p.win(2));
                                end
                            else
                                rep=zeros(size(v.barstart.(char(v.name{1,k})),1),sum(p.win)+1);
                                for i=1:size(v.barstart.(char(v.name{1,k})),1)
                                    rep(i,:)=mVal(v.barstart.(char(v.name{1,k}))(i,1)-p.win(1):v.barstart.(char(v.name{1,k}))(i,1)+p.win(2));
                                end
                            end
                            h=figure;subplot(3,1,[1,2]);
                            imagesc(rep),c=colorbar;hold on;
                            xlimit=get(gca,'XLim');
                            %plotting vertical line to indicate time of trigger
                            a=p.win(1);
                            plot([a a],[0 size(rep,1)+0.5],'w','LineWidth',2);
                            title(['Fluorescence traces of ',char(v.name{1,k})]);
                            ylabel('Trial number');
                            c.Label.String='dF/F in %';
                            ticlabel=get(gca,'XTickLabel');
                            for j=1:length(ticlabel)
                                ticlabel{j,1}=str2num(ticlabel{j,1});
                            end
                            ticlabel=cell2mat(ticlabel);
                            ticlabel=ticlabel./d.framerate;
                            set(gca,'XTickLabel',ticlabel);
                            hold off;
                            stderr=std(rep);
                            errorp=mean(rep)+stderr;
                            errorn=mean(rep)-stderr;
                            basevalue=round(min(errorn),2)+round(min(errorn),2)*0.1;
                            subplot(3,1,3),area(errorp,basevalue,'FaceColor',[0 0.8 0.9],'EdgeColor','none','ShowBaseLine','off'),hold on;
                            area(errorn,basevalue,'FaceColor',[1 1 1],'EdgeColor','none','ShowBaseLine','off'),plot(mean(rep),'Color',[0 0.4 0.7],'LineWidth',2);
                            xlim(xlimit);
                            ylim([basevalue ceil(max(errorp))]);
                            ylimit=get(gca,'YLim');
                            plot([a a],ylimit,'Color',[0.08,0.17,0.55],'LineWidth',2);
                            xlabel('time [s]');
                            ticlabel=get(gca,'XTickLabel');
                            for j=1:length(ticlabel)
                                ticlabel{j,1}=str2num(ticlabel{j,1});
                            end
                            ticlabel=cell2mat(ticlabel);
                            ticlabel=ticlabel./d.framerate;
                            set(gca,'XTickLabel',ticlabel);
                            hold off;
                            stringname=sprintf('_Fluotrigbehav_%d',k);
                            fname=[cell2mat(d.name) stringname];
                            path=[d.pn '/traces/',fname,'.png'];
                            path=regexprep(path,'\','/');
                            print(h,'-dpng','-r200',path); %-depsc for vector graphic
                            close(h);
                        end
                        %statistics
                        for i=1:v.amount
                            for k=1:length(v.barstart.(char(v.name{1,i})))
                                spikes=sum(spkno(v.barstart.(char(v.name{1,i}))(k,1):v.barstart.(char(v.name{1,i}))(k,1)+v.barwidth.(char(v.name{1,i}))(k,1),1));
                                blength=v.barwidth.(char(v.name{1,i}))(k,1)+1;
                                stat.(char(v.name{1,i}))(k,1)=spikes/(blength/d.framerate);
                            end
                        end
                        %saving data
                        filename=[d.pn '\traces\freqbehavrep_' cell2mat(d.name)];
                        save(filename, 'stat');

                        msgbox('Done!','Attention');
                    case 'NO'
                end
                
            else %if behaviors were not defined
                files=dir([d.pn '\traces']);
                tff=zeros(1,length(dir([d.pn '\traces'])));
                for k=1:length(dir([d.pn '\traces']))
                    tff(k)=strcmp([cell2mat(d.name) '_rasterplot.png'],files(k).name);
                end
                if sum(tff)>0
                    rmdir([d.pn '\traces'],'s'); %delete existing folder
                    mkdir([d.pn '\traces']); %create same folder new, so that results are overwritten
                end
                tnum=ceil(size(d.ROImeans,2)/8); %total number of figures with ROI traces
                hfnum=get(fig,'Number'); %highest figure number
                numseries=(hfnum-tnum:1:hfnum-1); %figure numbers with ROI values
                %saving traces
                for j=1:tnum
                    fname=sprintf('traces_%d',j);
                    ffname=[cell2mat(d.name) '_' fname];
                    figurenum=sprintf('-f%d',numseries(j));
                    path=[d.pn '/traces/',ffname,'.png'];
                    path=regexprep(path,'\','/');
                    print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic
                end
                %saving rasterplot
                fname=[cell2mat(d.name) '_rasterplot'];
                figurenum=sprintf('-f%d',hfnum);
                path=[d.pn '/traces/',fname,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r200',path); %-depsc for vector graphic

                %saving ROImask as figure
                colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8)); %selecting colors for ROIs
                singleFrame=d.mip./max(max(d.mip)); %getting picture into the value range from 0 to 1 for roipoly
                h=figure; imshow(singleFrame);hold on;
                for k=1:size(d.ROIsbw,3)
                    if sum(sum(d.ROIsbw(:,:,k)))>0
                        B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
                        stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
                        %drawing ROIs
                        plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
                        text(stat.Centroid(1),stat.Centroid(2),num2str(k));
                    end
                end
                hold off;
                set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                fname=[cell2mat(d.name) '_ROImask'];
                path=[d.pn '/traces/',fname,'.png'];
                path=regexprep(path,'\','/');
                print(h,'-dpng',path); %-depsc for vector graphic
                close(h);
                
                %saving raw ROI values over time
                h=figure;imagesc(d.ROImeans',[round(min(min(d.ROImeans))) round(max(max(d.ROImeans)))]),c=colorbar;
%                 set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                title('Fluorescence traces');
                xlabel('time [s]');
                ylabel('ROI number');
                c.Label.String='dF/F in %';
                xlim([0 round(size(d.imd,3))]);
                ticlabel=get(gca,'XTickLabel');
                for k=1:length(ticlabel)
                    ticlabel{k,1}=str2num(ticlabel{k,1});
                end
                ticlabel=cell2mat(ticlabel);
                ticlabel=ticlabel./d.framerate;
                set(gca,'XTickLabel',ticlabel);
%                 set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                fname=[cell2mat(d.name) '_Fluo'];
                path=[d.pn '/traces/',fname,'.png'];
                path=regexprep(path,'\','/');
                print(h,'-dpng','-r200',path); %-depsc for vector graphic
                close(h);
                
                %calculating event behavior if trigger file was loaded
                if isempty(d.triggerts)==0 && d.decon==1
                    %plotting mean fluorescence
                    mVal=mean(d.cCaSignal,2);
                    rep=zeros(size(d.triggerts,1),sum(p.win)+1);
                    for i=1:size(d.triggerts,1)
                        rep(i,:)=mVal(d.triggerts(i,1)-p.win(1):d.triggerts(i,1)+p.win(2));
                    end
                    meantrig=mean(rep,1);
                    e = std(rep,[],1);
                    eup=meantrig+e;
                    edown=meantrig-e;
                    h=figure;
                    area(eup,'FaceColor',[0.8 0.8 0.8],'EdgeColor',[1 1 1]),hold on,area(edown,'FaceColor',[1 1 1],'EdgeColor',[1 1 1]),plot(meantrig,'k','LineWidth',2);
                    %plotting vertical line to indicate time of trigger
                    aylim=get(gca,'YLim');
                    a=p.win(1);
                    plot([a a],aylim,'LineWidth',2);hold off;
                    title('Mean fluorescence trace with trigger');
                    xlabel('time [s]');
                    ylabel('dF/F in %');
                    axlim=get(gca,'XLim');
                    ticlabel=get(gca,'XTickLabel');
                    for k=1:length(ticlabel)
                        ticlabel{k,1}=str2num(ticlabel{k,1});
                    end
                    ticlabel=cell2mat(ticlabel);
                    ticlabel=ticlabel./d.framerate;
                    set(gca,'XTickLabel',ticlabel);
                    fname=[cell2mat(d.name) '_Fluotrig'];
                    path=[d.pn '/traces/',fname,'.png'];
                    path=regexprep(path,'\','/');
                    print(h,'-dpng','-r200',path); %-depsc for vector graphic
                    close(h);
                    
                    %plotting mean fluorescence with trigger as heat map image
                    h=figure;imagesc(rep),c=colorbar;hold on;
                    %plotting vertical line to indicate time of trigger
                    a=p.win(1);
                    plot([a a],[0 size(rep,1)+0.5],'w','LineWidth',2);
                    title('Fluorescence traces with trigger');
                    xlabel('time [s]');
                    ylabel('Trial number');
                    c.Label.String='dF/F in %';
                    ticlabel=get(gca,'XTickLabel');
                    for k=1:length(ticlabel)
                        ticlabel{k,1}=str2num(ticlabel{k,1});
                    end
                    ticlabel=cell2mat(ticlabel);
                    ticlabel=ticlabel./d.framerate;
                    set(gca,'XTickLabel',ticlabel);
                    fname=[cell2mat(d.name) '_Fluotrigheat'];
                    path=[d.pn '/traces/',fname,'.png'];
                    path=regexprep(path,'\','/');
                    print(h,'-dpng','-r200',path); %-depsc for vector graphic
                    close(h);
                end

                %saving table
                filename=[d.pn '\traces\ROIs_' cell2mat(d.name) '.xls'];
                ROInumber=cell(size(d.cCaSignal,2),1);
                for k=1:size(d.cCaSignal,2)
                    ROInumber{k,1}=sprintf('ROI No.%d',k);
                    NoofSpikes(k,1)=sum(d.spikes(:,k));
                    d.ts{:,k}=find(d.spikes(:,k)); %timestamps of spikes
                    d.amp{:,k}=d.spikes(d.spikes(:,k)>0,k); %amplitude of spike
                end
                Frequency=round(NoofSpikes./(size(d.ROImeans,1)/d.framerate),3);;
                Amplitude=round(reshape(max(d.cCaSignal),size(d.cCaSignal,2),1),2);;
                T=table(NoofSpikes,Frequency,Amplitude,...
                    'RowNames',ROInumber);
                writetable(T,filename,'WriteRowNames',true);

                %saving data
                field1='framerate';
                field2='rawwave';
                field3='wave';
                field4='spikes';
                field5='amp';
                field6='ts';
                value1=d.framerate;
                value2=d.ROImeans;
                value3=d.cCaSignal;
                value5=d.amp;
                value6=d.ts;
                value4=struct(field5,value5,field6,value6);
                traces=struct(field1,value1,field2,value2,field3,value3,field4,value4);
                filename=[d.pn '\traces\traces_' cell2mat(d.name)];
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



% ------------------------------------------------------------ Trigger file
function trigger_Callback(hObject, eventdata, handles)
% hObject    handle to trigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global p

if p.help==1
    uiwait(msgbox('Select a trigger event file!'));
end

d.triggerts=[];

%extracts filename
filepath=[d.pn '\'];
[fn,pn,~]=uigetfile([filepath '*.mat']);
%if cancel was pressed
if fn==0
    return;
end

%load the trigger event file
triggerfile=cell2mat(struct2cell(load([pn fn])));

d.triggerts=triggerfile;
d.triggerts(:,1)=triggerfile(:,1)/1000*d.framerate; %converting ms to frames for this file

%define display window
if isempty(p.win)==1
    prompt = {'Enter window size in s ["time before trigger" "time after trigger"] e.g.: 1 3'};
    dlg_title = 'Window';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);
    if isempty(answer)==1
        return;
    end
    win=str2num(cell2mat(answer));
    test1=0;
    test2=[0 0];
    if size(win)==size(test1)
        uiwait(msgbox('Please enter more than 1 number!','Attention'));
        return;
    elseif sum(size(win)~=size(test2))>0
        uiwait(msgbox('Please do not enter more than 2 numbers!','Attention'));
        return;
    end
    %converting seconds to frames
    win=win*d.framerate;
    p.win=win;
    %saving scale
    filename=[d.pn '\win'];
    save(filename, 'win');
    %saving preference
    filename=[cd '\preferences'];
    preferences.win=p.win;
    save(filename, 'preferences');
end
        
msgbox('Done!');





%%---------------------------Saving calcium imaging video

% SAVE CI VIDEO
% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d

if isempty(d.origCI)==1&&d.pushed==1
    d.origCI=d.imd;
elseif isempty(d.origCI)==1&&d.pushed==4
    d.origCI=[];
end

%asking for animal name/session/date if not defined
if isempty(d.name)==1
    prompt = {'Enter your preferred name for this video (e.g. animalNo.-date):'};
    dlg_title = 'Name';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);
    %if cancel was pressed
    if isempty(answer)==1
        return;
    end
    %check whether another version already exists
    files=dir(d.pn);
    tf=zeros(1,length(dir(d.pn)));
    for k=1:length(dir(d.pn))
        tf(k)=strcmp('name.mat',files(k).name);
    end
    
    if sum(tf)>0 %if a file is found
        load([d.pn '\name.mat']);
        for k=1:size(name,2)
            tff(k)=strcmp(name{1,k},answer);
        end
        if sum(tff)>0
            %when name already exist as previous version
            % Construct a questdlg with two options
            choice = questdlg('This name already exists, do you wish to overwrite it?', ...
                'Attention', ...
                'YES','NO','YES');
            % Handle response
            if isempty(choice)==1 %window was closed
                return;
            end
            switch choice
                case 'YES'

                case 'NO'
                    return;
            end
        else
            d.name=answer;
            name{1,size(name,2)+1}=cell2mat(answer);
            filename=[d.pn '\name'];
            save(filename, 'name');
        end
    else    
        d.name=answer;
        filename=[d.pn '\name'];
        name=d.name;
        save(filename, 'name');
    end
end

if d.dF==0 %saving video if it was not processed further
    %converting original CI video to double precision and to values between 1 and 0
    h=waitbar(0,'Saving calcium imaging video');
    origCIdou=double(d.origCI);
    origCIconv=origCIdou./max(max(max(origCIdou)));

    filename=[d.pn '\' cell2mat(d.name)];
    vid = VideoWriter(filename,'Grayscale AVI');
    vid.FrameRate=d.framerate;
    nframes=size(d.imd,3);
    open(vid);
    for k=1:nframes
        singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        writeVideo(vid,singleFrame);
        try
            waitbar(k/nframes,h);
        catch
            return;
        end
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
    if isempty(choice)==1
        return;
    end
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
            choice = questdlg('Would you like to save the dF/F video or the original one?', ...
                'Attention', ...
                'dF/F','Original');
            % Handle response
            if isempty(choice)==1
                return;
            end
            switch choice
                case 'dF/F'
                    %function for saving dF/F video
                    pn=d.pn; name=cell2mat(d.name); framerate=d.framerate; imd=d.imd;
                    savedFF(pn,name,framerate,imd);
                case 'Original'
                    %converting original CI video to double precision and to values between 1 and 0
                    h=waitbar(0,'Saving calcium imaging video');
                    origCIdou=double(d.origCI);
                    origCIconv=origCIdou./max(max(max(origCIdou)));

                    filename=[d.pn '\' cell2mat(d.name)];
                    vid = VideoWriter(filename,'Grayscale AVI');
                    vid.FrameRate=d.framerate;
                    nframes=size(d.imd,3);
                    open(vid);
                    for k=1:nframes
                        singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
                        writeVideo(vid,singleFrame);
                        try
                            waitbar(k/nframes,h);
                        catch
                            return;
                        end
                    end
                    close(vid);
                    close(h);
                    msgbox('Saving video completed.');
            end
            
        case 'NO'
            %function for saving dF/F video
            pn=d.pn; name=cell2mat(d.name); framerate=d.framerate; imd=d.imd;
            savedFF(pn,name,framerate,imd);
    end
else
    % Construct a questdlg with two options
    choice = questdlg('Would you like to save only the dF/F video or the original one?', ...
        'Attention', ...
        'dF/F','Original','dF/F');
    % Handle response
    if isempty(choice)==1
        return;
    end
    switch choice
        case 'dF/F'
            %function for saving dF/F video
            pn=d.pn; name=cell2mat(d.name); framerate=d.framerate; imd=d.imd;
            savedFF(pn,name,framerate,imd);
        case 'Original'
            %converting original CI video to double precision and to values between 1 and 0
            h=waitbar(0,'Saving calcium imaging video');
            origCIdou=double(d.origCI);
            origCIconv=origCIdou./max(max(max(origCIdou)));

            filename=[d.pn '\' cell2mat(d.name)];
            vid = VideoWriter(filename,'Grayscale AVI');
            vid.FrameRate=d.framerate;
            nframes=size(d.imd,3);
            open(vid);
            for k=1:nframes
                singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
                writeVideo(vid,singleFrame);
                try
                    waitbar(k/nframes,h);
                catch
                    return;
                end
            end
            close(vid);
            close(h);
            msgbox('Saving video completed.');
    end
end






%%---------------------------Browsing through calcium imaging video/s

% --- Executes on slider movement.                            CHANGES FRAME
function slider7_Callback(hObject, ~, handles)
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
maxframes=size(d.imd,3);
handles.slider7.Max=maxframes;

handles = guidata(hObject);

if v.pushed>1 %if color spot mask was defined, select the corresponding color
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

if d.pushed==4 %if ROIs were defined, load colors for ROI boundaries
    colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
end

if d.pre==1 && d.pushed==1 %if CI video was too big and is already preprocessed
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    axes(handles.axes1);
    cla(handles.axes1);
    if d.dF==1 || d.pre==1
        imagesc(singleFrame, 'Parent',handles.axes1,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame, 'Parent',handles.axes1);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif d.pushed==1 %if CI video was loaded
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);
    cla(handles.axes1);
    if d.dF==1 || d.pre==1
        imagesc(singleFrame, 'Parent',handles.axes1,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame, 'Parent',handles.axes1);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif d.pushed==4 %if ROIs were defined
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    axes(handles.axes1);
    cla(handles.axes1);
    if d.dF==1 || d.pre==1
        imagesc(singleFrame,'Parent',handles.axes1,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame,'Parent',handles.axes1);hold on;
    end
    for k=1:size(d.ROIsbw,3)
        if sum(sum(d.ROIsbw(:,:,k)))>0
            B=bwboundaries(d.ROIsbw(:,:,k)); %boundaries of ROIs
            stat = regionprops(d.ROIsbw(:,:,k),'Centroid');
            %drawing ROIs
            plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,k});
            text(stat.Centroid(1),stat.Centroid(2),num2str(k),'Parent',handles.axes1);
        end
    end %drawing ROIs
    hold off;
    f=getframe(handles.axes1); %getting the MIP with ROI mask as one picture
    singleFramef=f.cdata;
    imshow(singleFramef,'Parent',handles.axes1);
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
end
if v.pushed==1 && d.pushed>=1 %if both CI and BV video was loaded
    axes(handles.axes2);cla(handles.axes2); image(v.imd(round(round(handles.slider7.Value))).cdata, 'Parent',handles.axes2); %original video
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed==1 %if only BV video was loaded
    axes(handles.axes2);cla(handles.axes2); image(v.imd(round(round(handles.slider7.Value))).cdata, 'Parent',handles.axes2); %original video
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed>1 %if color spot is being defined
    %function for masking the colored spot of the animal
    [maskedRGBImage] = spotmask(handles);
    %showing masked image in GUI
    if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
        axes(handles.axes2); 
        cla(handles.axes2);
        grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata,'Parent',handles.axes2);hold on;
        set(gcf,'renderer','OpenGL');
        alpha(grid,0.1);
        str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
        text(20,20,str,'Color','r','Parent',handles.axes2);
        hold off;
        f=getframe(handles.axes2);
        singleFramef=f.cdata;
        imshow(singleFramef,'Parent',handles.axes2);
    else
        axes(handles.axes2);
        cla(handles.axes2);
        grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata,'Parent',handles.axes2);hold on;
        set(gcf,'renderer','OpenGL');
        alpha(grid,0.1);
        hh=imshow(color);
        set(hh, 'AlphaData', maskedRGBImage(:,:,1),'Parent',handles.axes2);
        hold off;
        f=getframe(handles.axes2);
        singleFramef=f.cdata;
        imshow(singleFramef,'Parent',handles.axes2);
    end
    hold off;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
end


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, ~, ~)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in pushbutton18.                  PLAY VIDEO
function pushbutton18_Callback(~, ~, handles)
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
end
maxframes=size(d.imd,3);

cla(handles.axes1);
cla(handles.axes2);

if v.pushed>1  %if color spot mask was defined, select the corresponding color
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

if d.pushed==4 %if ROIs were defined, load colors for ROI boundaries
    colors=repmat(d.colors,1,ceil(size(d.ROIsbw,3)/8));
end

%if both videos were loaded
if v.pushed==1 && d.pre==1 && d.pushed==1 %if BV was loaded and CI video was too big
    d.play=1;
    v.play=1;
    axes(handles.axes2);
    hb=v.imd(round(round(handles.slider7.Value))).cdata; %original video
    axes(handles.axes1); %thresholded video
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    if d.dF==1 || d.pre==1
        hc=imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        hc=imshow(singleFrame);
    end
    for k=round(handles.slider7.Value):size(d.imd,3)
        singlebv=image(v.imd(round(k)).cdata);
        set(hb, 'CData', singlebv);
        singleFrame=d.imd(:,:,k);
        set(hc, 'CData', singleFrame);
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==1 && d.pushed==1 %if both videos were loaded
    d.play=1;
    v.play=1;
    axes(handles.axes2); %
    hb=v.imd(round(round(handles.slider7.Value))).cdata; %original video
    axes(handles.axes1); %original video
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    if d.dF==1 || d.pre==1
        hc=imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        hc=imshow(singleFrame);
    end
    for k=round(handles.slider7.Value):size(d.imd,3)
        singlebv=image(v.imd(round(k)).cdata);
        set(hb, 'CData', singlebv);
        singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        set(hc, 'CData', singleFrame);
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==1 && d.pushed==4 %if BV video was loaded and ROIs were defined in CI video
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        axes(handles.axes2);
        cla(handles.axes2);
        image(v.imd(round(k)).cdata); %original video
        axes(handles.axes1); %ROIs with video
        cla(handles.axes1);
        singleFrame=d.imd(:,:,k);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
        else
            imshow(singleFrame);hold on;
        end
        for j=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,j)))>0
                B=bwboundaries(d.ROIsbw(:,:,j)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,j),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,j});
                text(stat.Centroid(1),stat.Centroid(2),num2str(j));
            end
        end %drawing ROIs
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==2 && d.pre==1 && d.pushed==1 %if one color spot was defined and CI video was too big
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        cla(handles.axes2);
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %thresholded video
        singleFrame=d.imd(:,:,k);
        cla(handles.axes1);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            axes(handles.axes1); imshow(singleFrame);
        end
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif  v.pushed==2 && d.pushed==1 %if one color spot was defined and CI video was loaded
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        cla(handles.axes2);
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %original video
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        cla(handles.axes1);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==2 && d.pushed==4 %if one color spot was defined and ROIs were defined in CI video
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        cla(handles.axes2);
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %ROIs with video
        singleFrame=d.imd(:,:,k);
        cla(handles.axes1);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
        else
            imshow(singleFrame);hold on;
        end
        for j=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,j)))>0
                B=bwboundaries(d.ROIsbw(:,:,j)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,j),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,j});
                text(stat.Centroid(1),stat.Centroid(2),num2str(j));
            end
        end %drawing ROIs
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==3 && d.pre==1 && d.pushed==1 %if other color spot was defined and CI video was too big
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        cla(handles.axes2);
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %thresholded video
        singleFrame=d.imd(:,:,k);
        cla(handles.axes1);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            axes(handles.axes1); imshow(singleFrame);
        end
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==3 && d.pushed==1 %if other color spot was defined and CI video was loaded
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        cla(handles.axes2);
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('Animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %original video
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        cla(handles.axes1);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        else
            imshow(singleFrame);
        end
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
        if k==size(d.imd,3)
            d.play=0;
            v.play=0;
            d.stop=1;
        end
        if d.stop==1
            return;
        end
    end
elseif v.pushed==3 && d.pushed==4 %if other color spot was defined and ROIs were defined in CI video
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3)
        cla(handles.axes2);
        %function for masking the colored spot of the animal
        [maskedRGBImage] = spotmask(handles);
        %showing masked image in GUI
        if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
            axes(handles.axes2); 
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            str=sprintf('animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
            text(20,20,str,'Color','r');
            hold off;
        else
            axes(handles.axes2);
            grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
            set(gcf,'renderer','OpenGL');
            alpha(grid,0.1);
            hh=imshow(color);
            set(hh, 'AlphaData', maskedRGBImage(:,:,1));
        end
        hold off;
        axes(handles.axes1); %ROIs with video
        singleFrame=d.imd(:,:,k);
        cla(handles.axes1);
        if d.dF==1 || d.pre==1
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
        else
            imshow(singleFrame);hold on;
        end
        for j=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,j)))>0
                B=bwboundaries(d.ROIsbw(:,:,j)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,j),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,j});
                text(stat.Centroid(1),stat.Centroid(2),num2str(j));
            end
        end %drawing ROIs
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
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
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    if d.dF==1 || d.pre==1
        hh=imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        hh=axes(handles.axes1); imshow(singleFrame);
    end
    for k=round(handles.slider7.Value):size(d.imd,3)
        singleFrame=d.imd(:,:,round(handles.slider7.Value));
        set(hh, 'CData', singleFrame);
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
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
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    if d.dF==1 || d.pre==1
        hh=imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        hh=imshow(singleFrame);
    end
    for k=round(handles.slider7.Value):size(d.imd,3)
        singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        set(hh, 'CData', singleFrame);
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
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
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    if d.dF==1 || d.pre==1
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame);hold on;
    end
    for k=round(handles.slider7.Value):size(d.imd,3)
%         singleFrame=d.imd(:,:,k);
%         set(hh, 'CData', singleFrame);
        for j=1:size(d.ROIsbw,3)
            if sum(sum(d.ROIsbw(:,:,j)))>0
                B=bwboundaries(d.ROIsbw(:,:,j)); %boundaries of ROIs
                stat = regionprops(d.ROIsbw(:,:,j),'Centroid');
                %drawing ROIs
                plot(B{1,1}(:,2),B{1,1}(:,1),'linewidth',2,'Color',colors{1,j});
                text(stat.Centroid(1),stat.Centroid(2),num2str(j));
            end
        end
        hold off;
        handles.slider7.Value=k;
        textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
        set(handles.text36, 'String', textLabel);
        pause(1/d.framerate);
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
function pushbutton21_Callback(~, ~, ~)
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

%%---------------------------Loading behavioral video

% LOADS BEHAVIORAL VIDEO
% --------------------------------------------------------------------
function BV_Callback(hObject, eventdata, handles)
% hObject    handle to BV (see GCBO)
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
v.pushed=0; %video was not loaded yet
v.play=0; %video is not being played
v.pn=[]; %pathname is empty
v.fn=[]; %filename is empty
v.amount=[]; %amount of behaviors defined is 0
v.name=[]; %no names for behaviors
v.events=[]; %no behavior events
v.skdefined=0; %behaviors were not specified yet
v.behav=0; %behaviors are not defined
p.options.bsaa=25; %threshold for color spot mask to exclude small objects
v.preset=0; %no color preset was selected
p.import=0; %no ROIs were imported
%clears axes
cla(handles.axes2,'reset');
%resets frame slider
handles.slider7.Value=1;

if d.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end

%checks whether calcium imaging video was loaded
if d.pushed==0
    msgbox('Please select calcium imaging video first!','ATTENTION');
    return;
end        

v.hsvA=[]; %anterior spot mask is empty
v.hsvP=[]; %posterior spot mask is empty
v.crop=0; %signals video is not cropped
v.hsv=0; %signals video is not converted to hsv color space
v.Pspot=0; %signals green spot is not saved
v.Aspot=0; %signals pink spot is not saved

%open directory
[v.pn]=uigetdir(d.pn);
if v.pn==0
    return;
end

%check whether converted video has been saved before
filePattern = fullfile(v.pn, '*.mp4');
Files = dir(filePattern);
if size(Files,1)==0
    msgbox('This folder does not contain a MP4 file!','ATTENTION');
    return;
end
for j=1:length(Files)
    v.fn{j} = Files(j).name;
end
files=dir(v.pn);
tf=zeros(1,length(dir(v.pn)));
for k=1:length(dir(v.pn))
    tf(k)=strcmp([v.fn{1}(1:end-4) '_converted.mat'],files(k).name);
end
tf2=zeros(1,length(dir(v.pn)));
for k=1:length(dir(v.pn))
    tf2(k)=strcmp(['Behavior_' cell2mat(d.name) '.mat'],files(k).name);
end

if sum(tf)>0 && sum(tf2)==0
    % Construct a questdlg with two options
    choice = questdlg('Would you like to load your last processed version?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    if isempty(choice)==1
        return;
    end
    switch choice
        case 'YES'
            %function for loading last processed version
            tfb = loadlastBV;
            %looking at first original picture
            axes(handles.axes2); image(v.imd(1).cdata);
            titleLabel = ['Behavioral video: ' v.fn];
            set(handles.text28, 'String', titleLabel);
            handles.text28.TooltipString=v.pn;
            if sum(tfb)>0
                msgbox(cat(2, {'Loading Completed. Your behaviors are:'}, v.name),'Success');
            else
                msgbox(sprintf('Loading Completed.'),'Success');
            end
        case 'NO'
            %function for loading behavioral video
            dframerate=d.framerate; dsize=size(d.imd,3); pn=v.pn; fn=v.fn; dimd=d.imd; decon=d.decon;
            [sframe,imd,dimd,dROIv] = loadBV(dframerate,dsize,pn,fn,dimd,handles,decon);
            if isempty(imd)==1
                return;
            end
            d.imd=dimd;
            if isempty(dROIv)==0
                d.ROIv=dROIv;
            end
            v.imd=imd;
            v.pushed=1; %signals video is loaded
            %looking at first original picture
            axes(handles.axes2); image(v.imd(1).cdata);
            titleLabel = ['Behavioral video: ' v.fn];
            set(handles.text28, 'String', titleLabel);
            handles.text28.TooltipString=v.pn;
            if sframe>=0
                msgbox(sprintf('Loading Completed. Frames cut off: %d',sframe),'Success');
            elseif sframe <0 && d.decon ==1
                string=sprintf('Loading Completed. Frames cut off: %d',sframe)
                msgbox(cat(2, string,{'Please re-plot calcium traces!'}),'Success');
            else
                msgbox(sprintf('Loading Completed. Frames cut off: %d',sframe),'Success');
            end
    end
elseif (sum(tf)==0 && sum(tf2)>0) || (sum(tf)>0 && sum(tf2)>0)
    % Construct a questdlg with two options
    choice = questdlg('Would you like to load your last processed version?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    if isempty(choice)==1
        return;
    end
    switch choice
        case 'YES'
            %function for loading behavioral video
            dframerate=d.framerate; dsize=size(d.imd,3); pn=v.pn; fn=v.fn; dimd=d.imd; decon=d.decon;
            [sframe,imd,dimd,dROIv] = loadBV(dframerate,dsize,pn,fn,dimd,handles,decon);
            if isempty(imd)==1
                return;
            end
            d.imd=dimd;
            if isempty(dROIv)==0
                d.ROIv=dROIv;
            end
            v.imd=imd;
            v.pushed=1; %signals video is loaded
            
            %function for loading last processed version
            load([v.pn '\Behavior_' cell2mat(d.name)]);
            v.amount=Amount;
            v.events=Events;
            v.name=BehavNames;
            v.bars=bars;
            v.barstart=barstart;
            v.barwidth=barwidth;
            v.skdefined=Amount;
            v.behav=1;
            %showing plot
            figure;
            str={};
            for j=1:v.amount
                if isempty(v.bars.(char(v.name{1,j})))==0
                    area(1:size(v.imd,2),v.bars.(char(v.name{1,j})),'edgecolor',d.colors{1,j},'facecolor',d.colors{1,j}),hold on;
                    str(end+1)={char(v.name{1,j})}; %#ok<*AGROW>
                end
            end
            %relabeling X-ticks in time in seconds
            xlabel('Time in seconds');
            tlabel=get(gca,'XTickLabel');
            for k=1:length(tlabel)
                tlabel{k,1}=str2num(tlabel{k,1});
            end
            tlabel=cell2mat(tlabel);
            tlabel=tlabel./d.framerate;
            set(gca,'XTickLabel',tlabel);
            legend(str);
            title('Behavior');
            hold off;
            
            %looking at first original picture
            axes(handles.axes2); image(v.imd(1).cdata);
            titleLabel = ['Behavioral video: ' v.fn];
            set(handles.text28, 'String', titleLabel);
            handles.text28.TooltipString=v.pn;
            msgbox(cat(2, {'Loading Completed. Your behaviors are:'}, v.name),'Success');
        case 'NO'
            %function for loading behavioral video
            dframerate=d.framerate; dsize=size(d.imd,3); pn=v.pn; fn=v.fn; dimd=d.imd; decon=d.decon;
            [sframe,imd,dimd,dROIv] = loadBV(dframerate,dsize,pn,fn,dimd,handles,decon);
            if isempty(imd)==1
                return;
            end
            d.imd=dimd;
            if isempty(dROIv)==0
                d.ROIv=dROIv;
            end
            v.imd=imd;
            v.pushed=1; %signals video is loaded
            %looking at first original picture
            axes(handles.axes2); image(v.imd(1).cdata);
            titleLabel = ['Behavioral video: ' v.fn];
            set(handles.text28, 'String', titleLabel);
            handles.text28.TooltipString=v.pn;
            if sframe>=0
                msgbox(sprintf('Loading Completed. Frames cut off: %d',sframe),'Success');
            elseif sframe <0 && d.decon ==1
                string=sprintf('Loading Completed. Frames cut off: %d',sframe)
                msgbox(cat(2, string,{'Please re-plot calcium traces!'}),'Success');
            else
                msgbox(sprintf('Loading Completed. Frames cut off: %d',sframe),'Success');
            end
    end
else
    %function for loading behavioral video
    dframerate=d.framerate; dsize=size(d.imd,3); pn=v.pn; fn=v.fn; dimd=d.imd; decon=d.decon;
    [sframe,imd,dimd,dROIv] = loadBV(dframerate,dsize,pn,fn,dimd,handles,decon);
    if isempty(imd)==1
        return;
    end
    d.imd=dimd;
    d.ROIv=dROIv;
    v.imd=imd;
    v.pushed=1; %signals video is loaded
    %looking at first original picture
    axes(handles.axes2); image(v.imd(1).cdata);
    titleLabel = ['Behavioral video: ' v.fn];
    set(handles.text28, 'String', titleLabel);
    handles.text28.TooltipString=v.pn;
    if sframe>=0
        msgbox(sprintf('Loading Completed. Frames cut off: %d',sframe),'Success');
    elseif sframe <0 && d.decon ==1
        string=sprintf('Loading Completed. Frames cut off: %d',sframe)
        msgbox(cat(2, string,{'Please re-plot calcium traces!'}),'Success');
    else
        msgbox(sprintf('Loading Completed. Frames cut off: %d',sframe),'Success');
    end
end




%%---------------------------Processing of behavioral video

% --- Executes on button press in pushbutton15. CROPPING & DOWNSAMPLING
function pushbutton15_Callback(~, ~, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
global p
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
axes(handles.axes2); image(v.imd(1).cdata); %displays first image
if p.help==1
    uiwait(msgbox('Please define the area where the animal is running by left-click and dragging the cursor over the area! Then right click and select Copy Position, finish by double-clicking!','Attention','modal'));
end
%initializes interactive cropping
h=imcrop;
cropped=clipboard('pastespecial');
%if cancel was pressed
if isempty(cropped)==1
    return;
end

cropCoordinates=str2num(cell2mat(cropped.A_pastespecial));
%checks if cropping coordinates are valid
if isempty(cropCoordinates)==1 || cropCoordinates(1,3)==0 || cropCoordinates(1,4)==0
    msgbox('Please select valid cropping area! Check the instructions again.','ERROR');
    return;
end
for i=1:4
    if cropCoordinates(1,i)<1
        cc(1,i)=ceil(cropCoordinates(1,i));
    else
        cc(1,i)=floor(cropCoordinates(1,i));
    end
end
%function for cropping video
imd=v.imd;
[imdc] = cropBV(imd,cc);
if isempty(imd)==1
    return;
end
v.crop=1; %signals that video was cropped
%function for downsampling video
[imdcd] = donwsampleBV(imdc);
if isempty(imdcd)==1
    return;
end
v.imd=imdcd;
axes(handles.axes2); image(v.imd(1).cdata);

%saving cropped video
h=msgbox('Saving progress... Program might seem unresponsive, please wait!');
filename=[v.pn '\' v.fn{1}(1:end-4) '_converted.mat'];
convVimd=v.imd;
save(filename, 'convVimd','-v7.3');
close(h);

if p.help==1
    msgbox('Cropping and downsampling completed. Please select a color preset to view only the colored spot. If needed adjust thresholds manually! If satisfied save the two colored spots by clicking PREVIEW ANTERIOR SPOT and PREVIEW POSTERIOR SPOT. If you have only one spot select only ANTERIOR SPOT','Success');
else
    msgbox('Cropping and downsampling completed.','Success');
end



%%---------------------------Creating mask for color spots on mouse

% --- Executes on slider movement.                                SPOT SIZE
function slider22_Callback(~, ~, handles)
% hObject    handle to slider22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
global p

%slider value for smallest acceptable area for spot size in the color mask
p.options.bsaa=round(handles.slider22.Value);

if v.pushed==0
    msgbox('Please select behavioral video first!','ATTENTION');
    return;
end
maxframes=size(d.imd,3);
handles.slider7.Max=maxframes;

if v.preset==0
    msgbox('Please select color preset first!','ATTENTION');
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

%function for spot mask
[maskedRGBImage] = spotmask(handles);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0 %check if color spot is in image, if not animal out of bounds or spot not detected!
    axes(handles.axes2); 
    grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    str=sprintf('animal out of bounds, please select a frame where the animal is visible! Otherwise lower saturation threshold manually!');
    text(20,20,str,'Color','r');
    hold off;
else
    axes(handles.axes2);
    grid=imshow(v.imd(round(round(handles.slider7.Value))).cdata);hold on;
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.1);
    hh=imshow(color);
    set(hh, 'AlphaData', maskedRGBImage(:,:,1));
end
hold off;
textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
set(handles.text36, 'String', textLabel);

% --- Executes during object creation, after setting all properties.
function slider22_CreateFcn(hObject, ~, ~)
% hObject    handle to slider22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on slider movement.                      VALUE THRESHOLD LOW
function slider9_Callback(~, ~, handles)
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

if v.preset==0
    msgbox('Please select color preset first!','ATTENTION');
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
[maskedRGBImage] = spotmask(handles);

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
v.pushed=4;

% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, ~, ~)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                     VALUE THRESHOLD HIGH
function slider10_Callback(~, ~, handles)
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

if v.preset==0
    msgbox('Please select color preset first!','ATTENTION');
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
[maskedRGBImage] = spotmask(handles);

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
v.pushed=4;

% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject, ~, ~)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                SATURATION THRESHOLD HIGH
function slider11_Callback(~, ~, handles)
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

if v.preset==0
    msgbox('Please select color preset first!','ATTENTION');
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
[maskedRGBImage] = spotmask(handles);

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
v.pushed=4;

% --- Executes during object creation, after setting all properties.
function slider11_CreateFcn(hObject, ~, ~)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                 SATURATION THRESHOLD LOW
function slider12_Callback(~, ~, handles)
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

if v.preset==0
    msgbox('Please select color preset first!','ATTENTION');
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
[maskedRGBImage] = spotmask(handles);

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
v.pushed=4;

% --- Executes during object creation, after setting all properties.
function slider12_CreateFcn(hObject, ~, ~)
% hObject    handle to slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                        HUE THRESHOLD LOW
function slider13_Callback(~, ~, handles)
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

if v.preset==0
    msgbox('Please select color preset first!','ATTENTION');
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
[maskedRGBImage] = spotmask(handles);

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
v.pushed=4;

% --- Executes during object creation, after setting all properties.
function slider13_CreateFcn(hObject, ~, ~)
% hObject    handle to slider13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                       HUE THRESHOLD HIGH
function slider14_Callback(~, ~, handles)
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

if v.preset==0
    msgbox('Please select color preset first!','ATTENTION');
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
[maskedRGBImage] = spotmask(handles);

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
v.pushed=4;

% --- Executes during object creation, after setting all properties.
function slider14_CreateFcn(hObject, ~, ~)
% hObject    handle to slider14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on selection change in popupmenu1.              SELECT COLOR
function popupmenu1_Callback(~, ~, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

global d
global v
global p
if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0
    msgbox('Please crop & convert video first!','ERROR');
    return;
end

%determining popup choice
v.preset=handles.popupmenu1.Value;
if v.preset==1
    % Green preset values
    hueThresholdLow = p.options.hTLg;
    hueThresholdHigh = p.options.hTHg;
    saturationThresholdLow = p.options.sTLg;
    saturationThresholdHigh = p.options.sTHg;
    valueThresholdLow = p.options.vTLg;
    valueThresholdHigh = p.options.vTHg;
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==2
    % Pink preset values
    hueThresholdLow = p.options.hTLp;
    hueThresholdHigh = p.options.hTHp;
    saturationThresholdLow = p.options.sTLp;
    saturationThresholdHigh = p.options.sTHp;
    valueThresholdLow = p.options.vTLp;
    valueThresholdHigh = p.options.vTHp;
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.75,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), repmat(0.8,size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==3
    % Yellow preset values
    hueThresholdLow = p.options.hTLy;
    hueThresholdHigh = p.options.hTHy;
    saturationThresholdLow = p.options.sTLy;
    saturationThresholdHigh = p.options.sTHy;
    valueThresholdLow = p.options.vTLy;
    valueThresholdHigh = p.options.vTHy;
    color = cat(3, ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
elseif v.preset==4
    % Blue preset values
    hueThresholdLow = p.options.hTLb;
    hueThresholdHigh = p.options.hTHb;
    saturationThresholdLow = p.options.sTLb;
    saturationThresholdHigh = p.options.sTHb;
    valueThresholdLow = p.options.vTLb;
    valueThresholdHigh = p.options.vTHb;
    color = cat(3, zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)), ones(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2)));
end
%setting sliders according to preset
handles.slider14.Value = hueThresholdHigh;
handles.slider13.Value = hueThresholdLow;
handles.slider12.Value = saturationThresholdLow;
handles.slider11.Value = saturationThresholdHigh;
handles.slider9.Value = valueThresholdLow;
handles.slider10.Value = valueThresholdHigh;

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

%function for spot mask
[maskedRGBImage] = spotmask(handles);

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
v.pushed=4;


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, ~, ~)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------- Colour preset
function preset_Callback(hObject, eventdata, handles)
% hObject    handle to preset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
global p

if p.help==1
    uiwait(msgbox('Select a preset*.mat file!'));
end

%extracts filename
filepath=[d.pn '\'];
[fn,pn,~]=uigetfile([filepath '*.mat']);
%if cancel was pressed
if fn==0
    return;
end
%checking if a behavior file was selected
TF = strncmpi('preset',fn,6);
if TF==0
    msgbox('Please select a preset*.mat file!','ERROR');
    return;
end

%loading preset
% Construct a questdlg with two options
choice = questdlg('Which preset would you like to import?', ...
    'Attention', ...
    'anterior','posterior','anterior');
% Handle response
if isempty(choice)==1
    return;
end
switch choice
    case 'anterior'
        load([pn '\presetA']);
        v.hueThresholdHigh=hueHigh;
        v.hueThresholdLow=hueLow;
        v.saturationThresholdLow=satLow;
        v.saturationThresholdHigh=satHigh;
        v.valueThresholdLow=valueLow;
        v.valueThresholdHigh=valueHigh;
        v.preset=vcolor;
    case 'posterior'
        load([pn '\presetP']);
        v.hueThresholdHigh=hueHigh;
        v.hueThresholdLow=hueLow;
        v.saturationThresholdLow=satLow;
        v.saturationThresholdHigh=satHigh;
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
%setting sliders according to preset
handles.slider14.Value = v.hueThresholdHigh;
handles.slider13.Value = v.hueThresholdLow;
handles.slider12.Value = v.saturationThresholdLow;
handles.slider11.Value = v.saturationThresholdHigh;
handles.slider9.Value = v.valueThresholdLow;
handles.slider10.Value = v.valueThresholdHigh;

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

%function for spot mask
[maskedRGBImage] = spotmask(handles);

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
v.pushed=4;





% --- Executes on button press in pushbutton10.      SAVE AS POSTERIOR SPOT
function pushbutton10_Callback(~, ~, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
global p
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

if v.preset==0
    msgbox('Please select color preset first!','ATTENTION');
    return;
end
%reading settings from sliders
v.hueThresholdHigh = handles.slider14.Value;
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;
%saving settings into variable for easier acces of function savespot
thresh.hueThresholdHigh=v.hueThresholdHigh;
thresh.hueThresholdLow=v.hueThresholdLow;
thresh.saturationThresholdLow=v.saturationThresholdLow;
thresh.saturationThresholdHigh=v.saturationThresholdHigh;
thresh.valueThresholdLow=v.valueThresholdLow;
thresh.valueThresholdHigh=v.valueThresholdHigh;
thresh.smallestArea=p.options.bsaa;

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
    try
        waitbar(k/nframes,h);
    catch
        return;
    end
end
v.traceP(:,1)=x; %coordinates of the animal center
v.traceP(:,2)=y;
v.pushed=2; %signals posterior spot was saved
v.Pspot=1; %signals posterior spot was saved
close(h);

%plotting posterior trace
v.tracePplot=v.traceP(v.traceP>0);
v.tracePplot=reshape(v.tracePplot,[size(v.tracePplot,1)/2,2]);
OutofBounds=100-round(length(v.tracePplot)/length(v.traceP)*100); %in percent
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
function pushbutton11_Callback(~, ~, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
global p
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

if v.preset==0
    msgbox('Please select color preset first!','ATTENTION');
    return;
end
%reading settings from sliders         
v.hueThresholdHigh = handles.slider14.Value;
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;
%saving settings into variable for easier acces of function savespot
thresh.hueThresholdHigh=v.hueThresholdHigh;
thresh.hueThresholdLow=v.hueThresholdLow;
thresh.saturationThresholdLow=v.saturationThresholdLow;
thresh.saturationThresholdHigh=v.saturationThresholdHigh;
thresh.valueThresholdLow=v.valueThresholdLow;
thresh.valueThresholdHigh=v.valueThresholdHigh;
thresh.smallestArea=p.options.bsaa;

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
    try
        waitbar(k/nframes,h);
    catch
        return;
    end
end
v.traceA(:,1)=x; %coordinates of the animal center
v.traceA(:,2)=y;
v.pushed=3; %signals anterior spot was saved
v.Aspot=1; %signals anterior spot was saved
close(h);

%plotting anterior trace
v.traceAplot=v.traceA(v.traceA>0);
v.traceAplot=reshape(v.traceAplot,[size(v.traceAplot,1)/2,2]);
OutofBounds=100-round(length(v.traceAplot)/length(v.traceA)*100); %in percent
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




%%---------------------------Tracing color spots on mouse

% --- Executes on button press in pushbutton12.                TRACE ANIMAL
function pushbutton12_Callback(~, ~, ~)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p
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
    if isempty(choice)==1
        return;
    end
    switch choice
        case 'Yes'
            v.tracePplot=[];
            v.traceP=[];
        case 'No'
            msgbox('Then please select posterior colored spot!','Attention');
            return;
    end
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
    files=dir([d.pn '\location']);
    tff=zeros(1,length(dir([d.pn '\location'])));
    for k=1:length(dir([d.pn '\location']))
        tff(k)=strcmp([cell2mat(d.name) '_mouse_trace.png'],files(k).name);
    end
    if sum(tff)>0
        rmdir([d.pn '\location'],'s');
        mkdir([d.pn '\location']);
    end
end
fname=sprintf('mouse_trace');
ffname=[cell2mat(d.name) '_' fname];
path=[d.pn '/location/',ffname,'.png'];
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
totalDistInPx=sum(dist(dist>p.options.bdistmin & dist<p.options.bdistmax)); %movement is consider at least 1 pixel and at most 40 pixels at once

%Converting pixel to cm
if isempty(p.ascale)==1
    %asking for scale of the animal arena to determine conversion value
    %from pixel to cm
    h=figure;image(v.imd(1).cdata);hold on;
    if p.help==1
        uiwait(msgbox('Please define the length of one side of the testing area by dragging a line, right-clicking, select "Copy Position" and close the figure. Then press "Next", "Finish"!','Attention'));
    end
    a=imline;
    uiwait(h);
    cropped=clipboard('pastespecial');
    if isempty(cropped)==1
        return;
    end
    testsizepixel=round(str2num(cell2mat(cropped.A_pastespecial)));
    testsizepixel=round(sqrt((abs(testsizepixel(2,1)-testsizepixel(1,1)))^2+(abs(testsizepixel(2,2)-testsizepixel(1,2)))^2)); %length of defined line in pixel
    prompt = {'Enter real length in cm:'};
    dlg_title = 'Input';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);
    if isempty(answer)==1
        return;
    end

    testsizecm=str2num(cell2mat(answer)); %real size in cm
    factor=testsizecm/testsizepixel; %multiplication factor for converting pixel to cm
    p.ascale=factor;
    %saving scale
    filename=[d.pn '\ascale'];
    ascale=p.ascale;
    save(filename, 'ascale');
    %saving preference
    filename=[cd '\preferences'];
    preferences.ascale=p.ascale;
    save(filename, 'preferences');
else
    if p.help==1
        uiwait(msgbox('Please remember to change the arena scale in preferences in case that your setup has changed!','Attention'));
    end
end

totalDistIncm=round(totalDistInPx*p.ascale,1);

%calculating percent pause
pause=sum(dist(:) <= p.options.bdistmin);
percPause=round(pause/length(v.traceA)*100,1); %percent in regards to the whole time

%velocity in cm/s
VelocityIncms=round(totalDistIncm/(length(v.traceAplot)/d.framerate),1); %mean velocity while it was visible


%saving table
T=table(totalDistIncm,VelocityIncms,percPause,percOutside);
filename=[d.pn '\location\' cell2mat(d.name) '_behavior.xls'];
writetable(T,filename);


%function for defining compartments
[cood] = defineComp;


%function for plotting location of animal while specified cells are active
% Construct a questdlg with two options
choice = questdlg('Would you like to correlate location and orientation of the mouse with the cell activity?', ...
    'Attention', ...
    'Yes','No','No');
% Handle response
if isempty(choice)==1
    return;
end
switch choice
    case 'Yes'
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
        %plotting cell activity
        %checking whether animal is out of bounds at times
        if length(v.tracePplot)~=length(v.traceP) || length(v.traceAplot)~=length(v.traceA)
            % Construct a questdlg with two options
            choice = questdlg('Does the animal ever leave the testing area?', ...
                'Attention', ...
                'Yes','No','No');
            % Handle response
            if isempty(choice)==1
                return;
            end
            switch choice
                case 'Yes'
                    mleft=0;
                case 'No' %if the animal did not leave the testing area, then every postiion that equals zero will be replaced by the last detectable position of the animal to have a continuous trace of the animal throughout the video
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
                            row=find(v.traceA>0,1,'first');
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

        activityLocation(mleft);
        v.pushed=1; %signals to show original video again
        msgbox('Tracing Completed. ROI traces saved in folder "location"!','Success');
    case 'No'
        return;
end



% --------------------------------------------------------- ROIs of arena
function locrois_Callback(hObject, eventdata, handles)
% hObject    handle to locrois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global p

if p.help==1
    uiwait(msgbox('Select a tracingROIs.mat file!'));
end

%extracts filename
filepath=[d.pn '\'];
[fn,pn,~]=uigetfile([filepath '*.mat']);
%if cancel was pressed
if fn==0
    return;
end
%checking if a behavior file was selected
TF = strncmpi('tracingROIs',fn,11);
if TF==0
    msgbox('Please select a tracingROIs.mat file!','ERROR');
    return;
end

%loading preset
load([pn fn]);
p.amount=amount; %amount of defined ROIs
p.name=name; %names of ROIs
p.ROImask=ROImask; %ROI mask containing the compartments vs background
p.import=1; %ROIs were imported
msgbox('Loading Complete.','Success');




%% BEHAVIORAL DETECTION


% --- Executes on button press in pushbutton29.         behavior DETECTION
function pushbutton29_Callback(~, ~, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p
d.stop=0;
%checks if a video file was selected
if v.pushed==0 && d.pushed==0
    msgbox('Please select folder first!','ERROR');
    return;
elseif v.pushed==0
    msgbox('Please select behavioral video first!','ERROR');
    return;
end
if v.skdefined==0
    msgbox('Please add a behavior you wish to track first!','ERROR');
    return;
elseif v.skdefined<2
    msgbox('You have to track at least two behaviors!','ERROR');
    return;
end

if p.help==1
    uiwait(msgbox('Track behavior by pushing this button in the frame you see the behavior! Please start from the first frame!','Attention'));
end

%tracking of one behavior
[Selection,~] = listdlg('PromptString','Which behavior:',...
                'SelectionMode','single',...
                'ListSize',[160 100],...
                'ListString',v.name);
if isempty(Selection)==1
    return;
end

v.events.(char(v.name{1,Selection}))(round(handles.slider7.Value))=1; %in case event was registered multiple times at the same frame




% --- Executes on button press in pushbutton35.       RESET BEHAV DETECTION
function pushbutton35_Callback(~, ~, ~)
% hObject    handle to pushbutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
v.amount=[]; %amount of behaviors is zero
v.name=[]; %no names defined
v.events=[]; %no events
v.barstart=[];
v.barwidth=[];
v.skdefined=0; %signals that not shortkeys were defined
v.behav=0; %signals that behavior was not tracked
msgbox('Behavioral detection was reset!');



% --- Executes on button press in pushbutton46.               ADD behavior
function pushbutton46_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p
d.stop=0;
%checks if a video file was selected
if v.pushed==0 && d.pushed==0
    msgbox('Please select folder first!','ERROR');
    return;
elseif v.pushed==0
    msgbox('Please select behavioral video first!','ERROR');
    return;
end

v.skdefined=v.skdefined+1;

if v.skdefined>8
    msgbox('You can only track 8 behaviors!','ERROR');
    return;
end

%name of behavior
prompt = {'What do you want to call this behavior? (No spaces)'};
dlg_title = 'Name';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
if isempty(answer)==1
    return;
end
v.name{1,v.skdefined}=cell2mat(answer);
%initializing event counter
v.events.(char(v.name{1,v.skdefined})) = zeros(size(v.imd,2),1);


% --- Executes on button press in pushbutton47.            REMOVE behavior
function pushbutton47_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p
d.stop=0;
%checks if a video file was selected
if v.pushed==0 && d.pushed==0
    msgbox('Please select folder first!','ERROR');
    return;
elseif v.pushed==0
    msgbox('Please select behavioral video first!','ERROR');
    return;
end
if v.skdefined==0
    msgbox('You are not tracking any behaviors, thus you cannot remove any!','ERROR');
    return;
end

%removing of one behavior
[Selection,~] = listdlg('PromptString','Which behavior:',...
                'SelectionMode','single',...
                'ListSize',[160 100],...
                'ListString',v.name)
if isempty(Selection)==1
    return;
end
%deleting events corresponding to selected behavior
v.events.(char(v.name{1,Selection})) = [];
field=v.name{1,Selection};
v.events=rmfield(v.events,field);
%deleting name of selected behavior
v.name{1,Selection}=[];
namenum=find(~cellfun(@isempty,v.name));
v.name=v.name(~cellfun('isempty',v.name));

v.skdefined=v.skdefined-1;


% --- Executes on button press in pushbutton48.              PLOT behavior
function pushbutton48_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
global p

%finding start and end of behaviors
v.amount=length(v.name);
allbehav=zeros(size(v.events.(char(v.name{1,1}))));
for m=1:v.amount
    allbehav=allbehav+v.events.(char(v.name{1,m}));
end
str={};
h=figure;
v.barstart=[];
v.barwidth=[];
for i=1:v.amount
    v.bars.(char(v.name{1,i}))=zeros(size(v.events.(char(v.name{1,1}))));
    behav=v.events.(char(v.name{1,i}));
    if sum(behav)>0
        otherbehav=allbehav-v.events.(char(v.name{1,i}));
        otherbehav(otherbehav>0)=2;
        indxother=find(otherbehav==2);
        behavstart=find(behav==1);
        behavend=[];
        for k=1:length(behavstart)
            a=indxother(indxother>behavstart(k),1);
            if isempty(a)==0
                behavend(k,1)=a(1,1)-1;
            else
                behavend(k,1)=size(d.imd,3);
            end
            v.bars.(char(v.name{1,i}))(behavstart(k):behavend(k))=1;
        end
        v.barstart.(char(v.name{1,i}))=behavstart;
        v.barwidth.(char(v.name{1,i}))=behavend-behavstart;
        %plotting timebars
        area(1:size(v.imd,2),v.bars.(char(v.name{1,i})),'edgecolor',d.colors{1,i},'facecolor',d.colors{1,i}),hold on;
        str(end+1)={char(v.name{1,i})}; %#ok<AGROW>
    else
        v.bars.(char(v.name{1,i}))=[];
        v.barstart.(char(v.name{1,i}))=[];
        v.barwidth.(char(v.name{1,i}))=[];
    end
end
xlabel('Time in seconds');
tlabel=get(gca,'XTickLabel');
for n=1:length(tlabel)
    tlabel{n,1}=str2num(tlabel{n,1});
end
tlabel=cell2mat(tlabel);
tlabel=tlabel./d.framerate;
set(gca,'XTickLabel',tlabel);
legend(str);
title('behavior')
hold off;
    
%saving plot
fname=sprintf('mouse_behavior');
ffname=[cell2mat(d.name) '_' fname];
path=[d.pn '/',ffname,'.png'];
path=regexprep(path,'\','/');
print(h,'-dpng','-r100',path); %-depsc for vector graphic
%saving positions at ROIs
filename=[d.pn '\Behavior_' cell2mat(d.name)];
Amount=v.amount;
Events=v.events;
BehavNames=v.name;
bars=v.bars;
barstart=v.barstart;
barwidth=v.barwidth;
save(filename, 'Amount','Events','BehavNames','bars','barstart','barwidth');
v.behav=1;
uiwait(msgbox('Plot and settings saved! You can now plot the behavior with the ROI traces together!'));


% --------------------------------------------------------- behavior names
function behav_Callback(hObject, eventdata, handles)
% hObject    handle to behav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
global p
%resets all varibles needed for behavioral tracking
v.amount=[]; %amount of behaviors is zero
v.name=[]; %no names defined
v.events=[]; %no events
v.barstart=[];
v.barwidth=[];
v.skdefined=0; %signals that not shortkeys were defined
v.behav=0; %signals that behavior was not tracked

if p.help==1
    uiwait(msgbox('Select a Behavior_"filename".mat file!'));
end

%extracts filename
filepath=[d.pn '\'];
[fn,pn,~]=uigetfile([filepath '*.mat']);
%if cancel was pressed
if fn==0
    return;
end
%checking if a behavior file was selected
TF = strncmpi('Behavior',fn,8);
if TF==0
    msgbox('Please select a Behavior_"filename".mat file!','ERROR');
    return;
end

%load the saved behavior names and amount
load([pn fn]);
v.name=BehavNames;
v.skdefined=Amount;
v.amount=Amount;

%re-initializing event counter
for k=1:v.amount
    v.events.(char(v.name{1,k})) = zeros(size(v.imd,2),1);
end

msgbox('Loading complete!');


%% MISC

% -----------------------------------------------------FILE
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------Loading
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------Import
function import_Callback(hObject, eventdata, handles)
% hObject    handle to import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------Preferences
function Preferences_Callback(hObject, eventdata, handles)
% hObject    handle to Preferences (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% -----------------------------------------------------------------savemask
function savemask_Callback(hObject, eventdata, handles)
% hObject    handle to savemask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global d
checkoff='off';
state=handles.savemask.Checked;

if strcmp(state,checkoff)==1
    handles.savemask.Checked='on';
    p.roisave=1; %ROImasks will be saved automatically
else
    handles.savemask.Checked='off';
    p.roisave=0; %ROI masks will not be saved automatically
end


% -----------------------------------------------------------------disphelp
function disphelp_Callback(hObject, eventdata, handles)
% hObject    handle to disphelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global p
checkoff='off';
state=handles.disphelp.Checked;

if strcmp(state,checkoff)==1
    handles.disphelp.Checked='on';
    p.help=1;
else
    handles.disphelp.Checked='off';
    p.help=0;
end


% -----------------------------------------------------------------nscale
function nscale_Callback(hObject, eventdata, handles)
% hObject    handle to nscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global p

if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
%check whether dF/F was calculated
if d.dF==0
    msgbox('Please calculate Delta F/F first!','ERROR');
    return;
end

path=cd;
pcd=strfind(path,'CAVE');
if isempty(pcd)==1
    msgbox('Please change the current directory to ./CAVE!');
       return;
end

%asking for scale of the video to determine neuropil radius of 20 um, doric model S 700um, model L 350um, nVista 650 um (shorter side), Miniscope 450um (shorter side)
models=[700 350 650 450]; %predefined sizes of the different microscope models
prompt = {'Enter the field of view size in um for short side:';'Select microscope model:'};
name = 'Input for scale';
formats = struct('type', {}, 'style', {}, 'items', {}, ...
  'format', {}, 'size', {});
formats(1,1).type   = 'edit';
formats(1,1).format = 'integer';
formats(1,1).limits = [50 5000];
formats(1,1).size = [100 18];

formats(2,1).type   = 'list';
formats(2,1).style  = 'popupmenu';
formats(2,1).items  = {'doric model S', 'doric model L', 'nVista', 'Miniscope'};
defaultanswer = {350, 2};

[answer, canceled] = inputsdlg(prompt, name, formats, defaultanswer);
if canceled==1
    return;
end
if answer{1,1}~=700 && answer{1,1}~=350 && answer{1,1}~=650 && answer{1,1}~=450 %if any manual input was made that does not equal the predefined sizes
    um=answer{1,1}; %take the manual input
else
    um=models(1,answer{2,1}); %otherwise take the list input
end
if size(d.imd,1)<size(d.imd,2) %determining the shorter side of the video
    shorterSide=floor(floor(size(d.imd,1)/0.8)/0.4); %recalculating original pixel size by reversing cutting off 80% and downsampling by 40%
else
    shorterSide=floor(floor(size(d.imd,2)/0.8)/0.4); %recalculating original pixel size by reversing cutting off 80% and downsampling by 40%
end
scale=shorterSide/um; %pixel divided by um equals the scale to convert from um to pixel
neuropilRadius=round(20*scale); %the needed neuropil radius of 20 um equals 20 times the scale to obtain the radius in pixel
p.nscale=neuropilRadius;
%saving scale
filename=[d.pn '\nscale'];
nscale=p.nscale;
save(filename, 'nscale');
%saving preference
filename=[cd '\preferences'];
preferences.nscale=p.nscale;
save(filename, 'preferences');


% -----------------------------------------------------------------ascale
function ascale_Callback(hObject, eventdata, handles)
% hObject    handle to ascale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p

if v.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end

path=cd;
pcd=strfind(path,'CAVE');
if isempty(pcd)==1
    msgbox('Please change the current directory to ./CAVE!');
       return;
end

%asking for scale of the animal arena to determine conversion value
%from pixel to cm
h=figure;image(v.imd(1).cdata);hold on;
if p.help==1
    uiwait(msgbox('Please define the length of one side of the testing area by dragging a line, right-clicking, select "Copy Position" and close the figure. Then press "Next", "Finish"!','Attention'));
end
a=imline;
uiwait(h);
cropped=clipboard('pastespecial');
if isempty(cropped)==1
    return;
end
testsizepixel=round(str2num(cell2mat(cropped.A_pastespecial)));
testsizepixel=round(sqrt((abs(testsizepixel(2,1)-testsizepixel(1,1)))^2+(abs(testsizepixel(2,2)-testsizepixel(1,2)))^2)); %length of defined line in pixel
prompt = {'Enter real length in cm:'};
dlg_title = 'Input';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
if isempty(answer)==1
    return;
end

testsizecm=str2num(cell2mat(answer)); %real size in cm
factor=testsizecm/testsizepixel; %multiplication factor for converting pixel to cm
p.ascale=factor;
%saving scale
filename=[d.pn '\ascale'];
ascale=p.ascale;
save(filename, 'ascale');
%saving preference
filename=[cd '\preferences'];
preferences.ascale=p.ascale;
save(filename, 'preferences');


% -----------------------------------------------------------------win
function win_Callback(hObject, eventdata, handles)
% hObject    handle to win (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global d
global p

if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end

%define display window
prompt = {'Enter window size in s ["time before trigger" "time after trigger"] e.g.: 1 3'};
dlg_title = 'Window';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
if isempty(answer)==1
    return;
end
win=str2num(cell2mat(answer));
test1=0;
test2=[0 0];
if size(win)==size(test1)
    uiwait(msgbox('Please enter more than 1 number!','Attention'));
    return;
elseif sum(size(win)~=size(test2))>0
    uiwait(msgbox('Please do not enter more than 2 numbers!','Attention'));
    return;
end
%converting seconds to frames
win=win*d.framerate;
p.win=win;
%saving scale
filename=[d.pn '\win'];
save(filename, 'win');
%saving preference
filename=[cd '\preferences'];
preferences.win=p.win;
save(filename, 'preferences');


% -----------------------------------------------------------------advanced
function advanced_Callback(hObject, eventdata, handles)
% hObject    handle to advanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p

if d.pushed==0
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end

path=cd;
pcd=strfind(path,'CAVE');
if isempty(pcd)==1
    msgbox('Please change the current directory to ./CAVE!');
       return;
end

defaultanswer = {'0.4', '100', '2', '5', '30', '300', '30', '2', '8', '0.8', '0.8', '0.6'};

files=dir(path);
tf=zeros(1,length(dir(path)));
for k=1:length(dir(path))
    tf(k)=strcmp('preferences.mat',files(k).name);
end
if sum(tf)>0 %if a file is found
    load([path '\preferences.mat']);
    try
        p.options=preferences.options;
        defaultanswer = {mat2str(p.options.dsr), mat2str(p.options.usfac), mat2str(p.options.LClevels), mat2str(p.options.LCiter), mat2str(p.options.pisaa), mat2str(p.options.picsize), mat2str(p.options.piolO), mat2str(p.options.spkthrs), mat2str(p.options.ROIdist), mat2str(p.options.sigcorr), mat2str(p.options.chg), mat2str(p.options.bdsr)};
    catch
    end
end

%advanced settings window
prompt = {'Down sample rate CI (0.4):';'Upsampling factor (100):';'LClevels (2):';'LCiteration (5):';'Smallest cell (30):';'Largest cell (300):';'Overlap (30):';'Spike threshold (2):';'Center distance (8):';'Correlation (0.8):';'Minimum amplitude (0.8):';'Down sample rate BV (0.6):'};
name = 'Advanced Settings';

[answer] = inputdlg(prompt, name, 1, defaultanswer);
if isempty(answer)==1
    return;
end
if str2num(cell2mat(answer(1,1)))~=str2num(defaultanswer{1,1}) || str2num(cell2mat(answer(12,1)))~=str2num(defaultanswer{1,12}) %if down sampling rates were changed
    msgbox('You have to re-load the video for your settings to have effect!','Attention');
elseif str2num(cell2mat(answer(2,1)))~=str2num(defaultanswer{1,2}) || str2num(cell2mat(answer(3,1)))~=str2num(defaultanswer{1,3}) || str2num(cell2mat(answer(4,1)))~=str2num(defaultanswer{1,4}) %if alignment parameters were changed
    if isempty(d.alignCI)==1
    else
        d.imd=d.alignCI;
        d.align=0; %signals that image alignment was reset
        d.dF=0; %deltaF/F claculation is reset as well
        %showing resulting frame
        singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
        axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
        msgbox('Alignment reset, you can now align with your new settings!','Attention');
    end
elseif str2num(cell2mat(answer(5,1)))~=str2num(defaultanswer{1,5}) || str2num(cell2mat(answer(6,1)))~=str2num(defaultanswer{1,6}) || str2num(cell2mat(answer(7,1)))~=str2num(defaultanswer{1,7}) % if PCA/ICA values were changed
    d.ROIv=0; %ROI values are reset
    p.F2=[];  %PCA is reset
    msgbox('You can now repeat "Auto ROIs"!','Attention');
elseif  str2num(cell2mat(answer(9,1)))~=str2num(defaultanswer{1,9}) || str2num(cell2mat(answer(10,1)))~=str2num(defaultanswer{1,10}) || str2num(cell2mat(answer(11,1)))~=str2num(defaultanswer{1,11}) % if ROI plotting values were changed
    d.ROIv=0; %ROI value indicator are reset
    d.ROIs=[]; %ROI values are deleted
    d.decon=0; %deconvolution is reset
    msgbox('You can now repeat "Plot ROIs"!','Attention');
elseif str2num(cell2mat(answer(8,1)))~=str2num(defaultanswer{1,8}) %if spiking threshold was changed
    d.decon=0; %deconvolution is reset
    msgbox('You can now repeat the deconvolution!','Attention');
end

p.options.dsr=str2num(cell2mat(answer(1,1)));
p.options.usfac=str2num(cell2mat(answer(2,1)));
p.options.LClevels=str2num(cell2mat(answer(3,1)));
p.options.LCiter=str2num(cell2mat(answer(4,1)));
p.options.pisaa=str2num(cell2mat(answer(5,1)));
p.options.picsize=str2num(cell2mat(answer(6,1)));
p.options.piolO=str2num(cell2mat(answer(7,1)));
p.options.spkthrs=str2num(cell2mat(answer(8,1)));
p.options.ROIdist=str2num(cell2mat(answer(9,1)));
p.options.sigcorr=str2num(cell2mat(answer(10,1)));
p.options.chg=str2num(cell2mat(answer(11,1)));
p.options.bdsr=str2num(cell2mat(answer(12,1)));

%saving preference
filename=[cd '\preferences'];
preferences.options=p.options;
save(filename, 'preferences');




% -----------------------------------------------------EDIT
function Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------Expand ROI
function Add_Callback(hObject, eventdata, handles)
% hObject    handle to Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global p
checkoff='off';
state=handles.Add.Checked;

if strcmp(state,checkoff)==1
    handles.Add.Checked='on';
    handles.Remove.Checked='off';
    handles.new.Checked='off';
    p.roistate=1; %ROIs are expanded, no overlay
else
    handles.Add.Checked='off';
    p.roistate=0; %no method of manipulating ROIs was selected
end


% --------------------------------------------------------------Remove ROI
function Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global p
checkoff='off';
state=handles.Remove.Checked;

if strcmp(state,checkoff)==1
    handles.Remove.Checked='on';
    handles.Add.Checked='off';
    handles.new.Checked='off';
    p.roistate=2; %ROIs or parts can be removed
else
    handles.Remove.Checked='off';
    p.roistate=0; %no method of manipulating ROIs was selected
end


% --------------------------------------------------------------New ROI
function new_Callback(hObject, eventdata, handles)
% hObject    handle to new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global p
checkoff='off';
state=handles.new.Checked;

if strcmp(state,checkoff)==1
    handles.new.Checked='on';
    handles.Remove.Checked='off';
    handles.Add.Checked='off';
    p.roistate=3; %ROIs can be overlayed
else
    handles.new.Checked='off';
    p.roistate=0; %no method of manipulating ROIs was selected
end






% -----------------------------------------------------HELP & DOCUMENTATION

function Help_Callback(~, ~, ~)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Documentation_Callback(~, ~, ~)
% hObject    handle to Documentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

path=cd;
filePattern = fullfile(path, '*.docx');
Files = dir(filePattern);
if isempty(Files)==1
   msgbox('Please change the current directory to ./CAVE!');
   return;
end
fn = Files(1).name;
winopen(fn);



%%---------------------------Radio buttons

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(~, ~, ~)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(~, ~, ~)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --------------------------------------------------------------------
function Untitled_9_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
