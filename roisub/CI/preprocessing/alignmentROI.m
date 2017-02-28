function [ROI] = alignmentROI(cc)
global d

%cropping frames
ROI=double(zeros(cc(4)+1,cc(3)+1,size(d.imd,3)));
im=double(d.imd(cc(2):cc(2)+cc(4),cc(1):cc(1)+cc(3),:));
h=waitbar(0,'Extracting ROI');
for k=1:size(d.imd,3);
    ROI(:,:,k)=wiener2(imgaussfilt(imadjust(imsharpen(imadjust(im(:,:,k)./max(max(im(:,:,k))))))),[6 6]);
    waitbar(k/size(d.imd,3),h);
end
close(h);