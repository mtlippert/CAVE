function [sframe] = loadBV
global v
global d

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