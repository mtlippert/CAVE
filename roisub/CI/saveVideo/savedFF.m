function [] = savedFF(pn,fn,framerate,imd)

h=waitbar(0,'Saving calcium imaging video');
filename=[pn '\' fn(1:end-4) 'dF'];
vid = VideoWriter(filename,'Grayscale AVI');
vid.FrameRate=framerate;
%scaling images between values of 0 and 1
imdpos=imd+abs(min(min(min(imd))));
imdscale=imdpos./max(max(max(imdpos)));

open(vid);
for k = 1:size(imd,3);
    frame = imdscale(:,:,k);
    frame(frame<0)=0;

    writeVideo(vid,frame);
    waitbar(k/size(imd,3),h);
end
close(vid);
close(h);
msgbox('Saving video completed.');