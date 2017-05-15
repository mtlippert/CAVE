function [ROImeans,cCaSignal,spikes,ts,amp,NoofSpikes,Frequency,Amplitude] = ROIFvalues(a,b,imd,mask,ROIs,framerate)

%FUNCTION for calculating fluorescence signal of the defined ROIs. The
%fluorescence is calculated as the mean value of a ROI substracted by the
%mean value of the background. The background consists of all pixels that
%are not contained in the ROI mask. The result is then multiplicated by 100
%to convert the values to percent. Finally, the result is filtered with a
%high-band pass filter (butterworth).
%The second part is the deconvolution of the signal. This part is adapted
%from the ca extraction master suite from Pnevmatikakis.

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
%           cCaSignal: corrected calcium signal after deconvolution
%           spikes: approximate true spikes deconvoulted from the data

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

%deconvolution of the calcium signal adapted from ca extraction master GUI from 2015 Pnevmatikakis
spikes=zeros(size(ROImeans));
cCaSignal=zeros(size(ROImeans));

NoofSpikes=zeros(size(ROImeans,2),1);
ts=cell(1,size(ROImeans,2));
amp=cell(1,size(ROImeans,2));

h=waitbar(0,'Deconvoluting...');
for k=1:size(ROImeans,2)
    y=ROImeans(:,k);

    [c_oasis, s_oasis] = deconvolveCa(y, 'ar2', 'constrained','optimize_b'); 
    s_oasis(s_oasis<1)=0;
    spikes(:,k)=round(s_oasis);
    cCaSignal(:,k)=c_oasis;
    
    %calcium signal statistics
    ts{:,k}=find(spikes(:,k)); %timestamps of spikes
    amp{:,k}=spikes(spikes(:,k)>0,k); %amplitude of spike
    %calculating total number of spikes per ROI
    NoofSpikes(k,1)=sum(spikes(:,k));
    
    waitbar(k/size(ROImeans,2),h);
end
%calculating firing frequency
Frequency=round(NoofSpikes./(size(ROImeans,1)/framerate),3);
%calculating highest amplitude change
Amplitude=round(reshape(max(cCaSignal),size(cCaSignal,2),1),2);
close(h);