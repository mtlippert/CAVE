function [imd,bcountd] = removeDust(singleFrame,bcountd,imd)

%FUNCTION for removing static unwanted objects wihtin view from whole video,
%like dust.

%INPUT      singleFrame: current image from calcium imaging video that is
%           currently displayed in the viewer.
%           bcountd: keeps track of how many times the button REMOVE DUST
%           has been pressed.
%           imd: original calcium imaging video as 8-bit/16-bit format with
%           dimensions pixel widht, pixel height, number of frames

%OUTPUT     imd: calcium imaging video as 8-bit/16-bit format without the
%           ROI. Dimensions: pixel widht, pixel height, number of frames
%           bcountd: adds one to the number of times REMOVE DUST was
%           pressed

%manual dust selection
Dust = roipoly(singleFrame);    %uint8 for CI_win_S1HL_02/20151118 & DORIC; int16 for CI_S1Hl_02

%check if ROI was selected correctly
if numel(find(Dust))==0
    msgbox('Please select valid dust ROI!','ERROR');
    return;
end

%count times button is pressed
bcountd=bcountd+1;
%defining surrounding neighbourhood to approximate ROI mean values
se=strel('disk',8,8);
Dust2=imdilate(Dust,se);
Dust3=Dust2-Dust;
%invert mask in order to multiplicate it with images
Dust=~Dust;

Dustc=cast(Dust,class(imd(:,:,1)));
Dust3c=cast(Dust3,class(imd(:,:,1)));
h=waitbar(0,'Removing dust specs');
nframes=size(imd,3);
for k=1:nframes
    singleframe=imd(:,:,k);
    singleframe=Dustc.*singleframe;%mask selecting only ROI pixels
    meanApprox=Dust3c.*singleframe; %mean value of border area around ROI
    meanApprox=meanApprox(meanApprox>0);
    singleframe(singleframe<1)=round(mean(meanApprox)); %setting all values of ROI to the mean value of the border
    imd(:,:,k)=singleframe;
    waitbar(k/nframes,h);
end
close(h);