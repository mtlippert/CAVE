function [imd,bcountd] = removeDust(singleFrame,bcountd,imd)

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
    singleframe=Dustc.*singleframe;
    meanApprox=Dust3c.*singleframe;
    meanApprox=meanApprox(meanApprox>0);
    singleframe(singleframe<1)=round(mean(meanApprox));
    imd(:,:,k)=singleframe;
    waitbar(k/nframes,h);
end
close(h);