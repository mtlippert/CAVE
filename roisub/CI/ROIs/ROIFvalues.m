function [ROImeans] = ROIFvalues(a,b,imd,mask,ROIs)

%FUNCTION for calculating fluorescence signal of the defined ROIs. The
%fluorescence is calculated as the mean value of a ROI substracted by the
%mean value of the background. The background consists of all pixels that
%are not contained in the ROI mask. The result is then multiplicated by 100
%to convert the values to percent. Finally, the result is filtered with a
%high-band pass filter (butterworth).

%INPUT      a: value for butterworth filtering
%           b: value for butterworth filtering
%           imd: clacium imaging video as 8bit/16-bit with dimensions pixel
%           width, pixel height, number of frames.
%           mask: ROI mask containing borders of all ROIs and defining
%           which pixels are in the mask and which are not.
%           ROIs: raw pixel values within the defined ROIs

%OUTPUT     ROImeans: resulting values for ROIs after background
%           substraction, conversion to percentage, and butterworth
%           filtering, conveying real fluorescence signal

%background
bg=cell(size(imd,3),1);
background=mask;
background(background==1)=2;
background(background==0)=1;
background(background==2)=0;
backgroundc = cast(background, class(imd(:,:,1)));

nframes=size(imd,3);
h=waitbar(0,'Labeling background');
for k = 1:nframes
    % You can only multiply integers if they are of the same type.
    bgmask = backgroundc .* imd(:,:,k);
    bg{k,1}=bgmask(backgroundc==1);
    waitbar(k/nframes,h);
end
close(h);
% calculate mean grey value of ROIs in percent
ROImeans=zeros(size(ROIs,1),size(ROIs,2));
numROIs=size(ROIs,2);
h=waitbar(0,'Calculating ROI values');
for k=1:numROIs
    for i=1:nframes
        ROIm=mean(ROIs{i,k});
        bgmean=mean(bg{i,1});
        ROImeans(i,k)=(ROIm-bgmean)*100;
    end
    ROImeans(:,k)=filtfilt(b,a,ROImeans(:,k)); %high band pass filter
    waitbar(k/numROIs,h);
end
close(h);