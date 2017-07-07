function [sframe,imd,dimd,dROIv] = loadBV(dframerate,dsize,pn,fn,dimd,handles)

% FUNCTION for loading behavioral video.
%
% INPUT     dframerate: framerate of calcium imaging video.
%           dsize: length of calcium imaging video in number of frames.
%           pn: pathname
%           fn: filename
%           dimd: clacium imaging video
%           handles: hanldes of the GUI for calling properties of the GUI.
%
% OUTPUT    sframe: number of frames that were cut.
%           imd: behavioral video
%           dimd: calcium imaging video
%           dROIv: whether or not ROIs need to be re-plotted.

for j=1:length(fn) %loading behavioral video parts
    %loading raw video
    vid = VideoReader([pn '\' fn{j}]);

    %defining dimensions of video
    nframes=get(vid,'NumberOfFrames');
    vidObj = VideoReader([pn '\' fn{j}]);
    vidHeight = vidObj.Height;
    vidWidth = vidObj.Width;
    vframerate=vidObj.FrameRate;
    imd = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'));

    %putting each frame into variable 'imd'
    str=sprintf('Loading part %d / %d',j,length(fn));
    h=waitbar(0,str);
    c=1;
    rate=ceil(vframerate/dframerate);
    %adapting framerate of the behavioral video to the calcium imaging
    %video
    if vframerate>dframerate %cutting frames and taking only every nth frame (rate)
        for k=1:rate:nframes
            imd(c).cdata = read(vidObj,k); %#ok<*VIDREAD>
            c=c+1;
            try
                waitbar(k/nframes,h);
            catch
                sframe=[];
                imd=[];
                dimd=[];
                dROIv=[];
                return;
            end
        end
    else %or taking all availbale frames if CI video has higher framerate
        for k=1:nframes
            imd(c).cdata = read(vidObj,k);
            c=c+1;
            try
                waitbar(k/nframes,h);
            catch
                sframe=[];
                imd=[];
                dimd=[];
                dROIv=[];
                return;
            end
        end
    end
    final{j,:}=imd; %putting each part of the video into a cell
    close(h);
end
%combining video parts into one matrix
if length(fn)>1
    for j=1:length(fn)-1
        imd=[final{j,:},final{j+1,:}]; 
    end
else
    imd=final{1,1};
end
%calculating number of frames dropped from either the calcium imaging or
%behavioral video (positive = dropped from BV video, negative = dropped
%from CI video
sframe=size(imd,2)-dsize;
if sframe>=0
    imd=imd(1:dsize); %cutting of BV video
    dROIv=[];
else
    dimd=dimd(:,:,1:length(imd)); %cutting of CI video
    %re-initialization for ROI plotting
    dROIv=0;
    %printing frames
    textLabel = sprintf('%d / %d', 1,size(dimd,3));
    set(handles.text36, 'String', textLabel);
    uiwait(msgbox('Please re-plot ROI values!'));
end