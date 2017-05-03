function [] = savedFF(pn,fn,framerate,imd)

%FUNCTION saves the delta F/F processed video as an AVI file.

%INPUT      pn: pathname
%           fn: filename
%           framerate: framerate of the original calcium imaging video
%           imd: delta F/F processed calcium imaging video with the
%           dimensions pixel width, pixel height, number of frames.

%no OUTPUT, since video is saved within this function.

h=waitbar(0,'Saving calcium imaging video');
filename=[pn '\' fn(1:end-4) 'dF'];
vid = VideoWriter(filename,'Grayscale AVI');
vid.FrameRate=framerate;

open(vid);
for k = 1:size(imd,3)
    %scaling images between values of 0 and 1
    imdpos=imd(:,:,k)+abs(min(min(imd(:,:,k))));
    imdscale=imdpos./max(max(imdpos));
    imdscale(imdscale<0)=0;
    writeVideo(vid,imdscale);
    waitbar(k/size(imd,3),h);
end
close(vid);
close(h);
msgbox('Saving video completed.');