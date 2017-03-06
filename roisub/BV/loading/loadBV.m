function [sframe,imd,pushed] = loadBV(dframerate,dsize,pn,fn)

%loading raw video
vid = VideoReader([pn '\' fn]);

%defining dimensions of video
nframes=get(vid,'NumberOfFrames');
vidObj = VideoReader([pn '\' fn]);
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;
vframerate=vidObj.FrameRate;
imd = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'));

%putting each frame into variable 'v.imd'
h=waitbar(0,'Loading');
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
sframe=size(imd,2)-dsize;
imd=imd(1:dsize);
pushed=1; %signals video is loaded
close(h);