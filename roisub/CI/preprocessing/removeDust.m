function [] = removeDust(singleFrame)
global d

%manual dust selection
Dust = roipoly(singleFrame);    %uint8 for CI_win_S1HL_02/20151118 & DORIC; int16 for CI_S1Hl_02

%check if ROI was selected correctly
if numel(find(Dust))==0;
    msgbox('Please select valid dust ROI!','ERROR');
    return;
end

%count times button is pressed
d.bcountd=d.bcountd+1;
%defining surrounding neighbourhood to approximate ROI mean values
se=strel('disk',8,8);
Dust2=imdilate(Dust,se);
Dust3=Dust2-Dust;
%invert mask in order to multiplicate it with images
Dust=~Dust;

Dust=cast(Dust,class(d.imd(:,:,1)));
Dust3=cast(Dust3,class(d.imd(:,:,1)));
h=waitbar(0,'Removing dust specs');
for k=1:size(d.imd,3)
    singleframe=d.imd(:,:,k);
    singleframe=Dust.*singleframe;
    meanApprox=Dust3.*singleframe;
    meanApprox=meanApprox(meanApprox>0);
    singleframe(singleframe<1)=round(mean(meanApprox));
    d.imd(:,:,k)=singleframe;
    waitbar(k/size(d.imd,3),h);
end
close(h);