function [] = savedFF(pn,name,framerate,imd)

%FUNCTION saves the delta F/F processed video as an AVI file.

%INPUT      pn: pathname
%           fn: filename
%           framerate: framerate of the original calcium imaging video
%           imd: delta F/F processed calcium imaging video with the
%           dimensions pixel width, pixel height, number of frames.

%no OUTPUT, since video is saved within this function.

h=waitbar(0,'Saving calcium imaging video');
filename=[pn '\' name '_dF'];
vid = VideoWriter(filename,'Grayscale AVI');
vid.FrameRate=framerate;
%smoothing
imdf=imgaussfilt(imd,1);

open(vid);
for k = 1:size(imd,3)
    %scaling images between values of 0 and 1
    imdpos=imdf(:,:,k)+abs(min(min(imdf(:,:,k))));
    imdscale=imdpos./max(max(imdpos));
    imdscale(imdscale<0)=0;
    writeVideo(vid,imdscale);
    try
        waitbar(k/size(imd,3),h);
    catch
        return;
    end
end
close(vid);
close(h);
msgbox('Saving video completed.');