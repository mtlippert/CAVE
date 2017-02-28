function [] = saveCombi(handles)
global d
%converting original CI video to double precision and to values between 1 and 0
h=waitbar(0,'Saving calcium imaging video');
origCIdou=double(d.origCI);
origpos=origCIdou+abs(min(min(min(origCIdou))));
origCIscaled=origpos./max(max(max(origpos)));
%converting dF/F video such that all pixels below 66% of absolute maximum
%intensity are zero
absmaximum=max(max(max(d.imd)))*0.66;
nframes=size(d.imd,3);
imdconv=zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3));
hh=waitbar(0,'Converting dF/F calcium imaging video');
for k=1:nframes;
    mask=d.imd(:,:,k).*d.mask;
    mask(mask<absmaximum)=0;
    imdconv(:,:,k)=mask;
    waitbar(k/nframes,hh);
end
close(hh);
%converting video such that values are between 1 and 0
imdpos=imdconv+abs(min(min(min(imdconv))));
imdscaled=imdpos./max(max(max(imdpos)));

filename=[d.pn '\' d.fn(1:end-4) 'combo'];
vid = VideoWriter(filename,'Uncompressed AVI');
vid.FrameRate=d.framerate;
open(vid);
for k=1:nframes;
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