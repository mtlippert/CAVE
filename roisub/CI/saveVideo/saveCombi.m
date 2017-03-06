function [] = saveCombi(handles,imd,mask,fn,pn,origCI,framerate)

%converting original CI video to double precision and to values between 1 and 0
h=waitbar(0,'Saving calcium imaging video');
origCIscaled=double(origCI)./double(max(max(max(origCI))));
%converting dF/F video such that all pixels below 66% of absolute maximum
%intensity are zero
absmaximum=max(max(max(imd)))*0.66;
nframes=size(imd,3);
imdconv=zeros(size(imd,1),size(imd,2),size(imd,3));
hh=waitbar(0,'Converting dF/F calcium imaging video');
for k=1:nframes
    maske=imd(:,:,k).*mask;
    maske(maske<absmaximum)=0;
    imdconv(:,:,k)=maske;
    waitbar(k/nframes,hh);
end
close(hh);
%converting video such that values are stretched between 1 and 0
imdscaled=imdconv./max(max(max(imdconv)));

filename=[pn '\' fn(1:end-4) 'combo'];
vid = VideoWriter(filename,'Uncompressed AVI');
vid.FrameRate=framerate;
open(vid);
for k=1:nframes
    singleFrame=imadjust(origCIscaled(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    figure(100),imshow(singleFrame);
    red = cat(3, ones(size(origCIscaled(:,:,1))), zeros(size(origCIscaled(:,:,1))), zeros(size(origCIscaled(:,:,1))));
    hold on 
    hh = imshow(red); 
    hold off
    set(hh, 'AlphaData', imdscaled(:,:,k));
    f=getframe(gcf);
    newframe=f.cdata;
    writeVideo(vid,newframe);
    waitbar(k/nframes,h);
end
close(vid);
close(h);
close(gcf);
msgbox('Saving video completed.');