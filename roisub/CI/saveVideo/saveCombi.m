function [] = saveCombi(handles,imd,mask,fn,pn,origCI,framerate)

%FUNCTION saves the original video with your contrast settings and overlays
%cell activity from your defined ROIs in red. The video is saved as AVI.

%INPUT      handles: values of different sliders of the GUI
%           imd: delta F/F processed calcium imaging video with the
%           dimensions pixel width, pixel height, number of frames.
%           mask: ROI mask containing which pixels belong to ROIs and which
%           do not.
%           pn: pathname
%           fn: filename
%           origCI: original calcium imaging video, unprocessed but with
%           your contrast settings.
%           framerate: framerate of the original calcium imaging video

%no OUTPUT, since video is saved within this function.

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
    singleFrame=imadjust(origCIscaled(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]); %frame of the original calcium imaging video, contrast adjusted
    figure(100),imshow(singleFrame); %showing the frame always in the same figure, in this case figure number 100
    red = cat(3, ones(size(origCIscaled(:,:,1))), zeros(size(origCIscaled(:,:,1))), zeros(size(origCIscaled(:,:,1)))); %red picture with same dimensions as calcium imaging video
    hold on 
    hh = imshow(red); 
    hold off
    set(hh, 'AlphaData', imdscaled(:,:,k)); %show only ROI areas in red
    f=getframe(gcf); %whole frame of original video and overlay
    newframe=f.cdata;
    writeVideo(vid,newframe);
    waitbar(k/nframes,h);
end
close(vid);
close(h);
close(gcf);
msgbox('Saving video completed.');