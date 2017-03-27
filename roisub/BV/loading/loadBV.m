function [sframe,imd,pushed,dimd,dROIv] = loadBV(dframerate,dsize,pn,fn,dimd,handles)

for j=1:length(fn)
    %loading raw video
    vid = VideoReader([pn '\' fn{j}]);

    %defining dimensions of video
    nframes=get(vid,'NumberOfFrames');
    vidObj = VideoReader([pn '\' fn{j}]);
    vidHeight = vidObj.Height;
    vidWidth = vidObj.Width;
    vframerate=vidObj.FrameRate;
    imd = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'));

    %putting each frame into variable 'v.imd'
    str=sprintf('Loading part %d / %d',j,length(fn));
    h=waitbar(0,str);
    c=1;
    rate=ceil(vframerate/dframerate);
    if vframerate>dframerate
        for k=1:rate:nframes
            imd(c).cdata = read(vidObj,k); %#ok<*VIDREAD>
            c=c+1;
            waitbar(k/nframes,h);
        end
    else
        for k=1:nframes
            imd(c).cdata = read(vidObj,k);
            c=c+1;
            waitbar(k/nframes,h);
        end
    end
    final{j,:}=imd;
    close(h);
end
if length(fn)>1
    for j=1:length(fn)-1
        imd=[final{j,:},final{j+1,:}];
    end
else
    imd=final{1,1};
end
sframe=size(imd,2)-dsize;
if sframe>=0
    imd=imd(1:dsize);
    dROIv=[];
else
    dimd=dimd(:,:,1:length(imd));
    %re-initialization for ROI plotting
    dROIv=0;
    %printing frames
    textLabel = sprintf('%d / %d', 1,size(dimd,3));
    set(handles.text36, 'String', textLabel);
    uiwait(msgbox('Please re-plot ROI values!'));
end
pushed=1; %signals video is loaded