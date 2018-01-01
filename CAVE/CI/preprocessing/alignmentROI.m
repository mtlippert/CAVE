function [ROI] = alignmentROI(cc,imd)

%FUNCTION that extracts and enhances the defined ROI for alignment from the
%calcium imaging video. The ROI should contain static background with high
%contrast differences, like blood vessels.

%INPUT      cc: coordinates of the defined ROI used for cropping
%           imd: calcium imaging video as 8-bit/16-bit with the dimensions
%           pixel widht, pixel height, number of frames

%OUTPUT     ROI: defined ROI extracted from video with several contrast
%           enhancements

global p

%cropping frames
ROI=double(zeros(cc(4)+1,cc(3)+1,size(imd,3)));
im=double(imd(cc(2):cc(2)+cc(4),cc(1):cc(1)+cc(3),:)); %cropped video containing only the defined ROI
nframes=size(imd,3);
h=waitbar(0,'Extracting ROI');
for k=1:nframes
    ROI(:,:,k)=wiener2(imgaussfilt(imadjust(imsharpen(imadjust(im(:,:,k)./max(max(im(:,:,k))))))),p.options.wienerp); %enhancing contrast of ROI and removing noise
    try
        waitbar(k/nframes,h);
    catch
        ROI=[];
        return;
    end
end
close(h);