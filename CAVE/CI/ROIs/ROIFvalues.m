function [ROImeans,cCaSignal,spikes,ts,amp,NoofSpikes,Frequency,Amplitude] = ROIFvalues(ROImeans,framerate)

%FUNCTION for calculating fluorescence signal of the defined ROIs. The
%fluorescence is calculated as the mean value of a ROI substracted by the
%mean value of the background. The background consists of all pixels that
%are not contained in the ROI mask. The result is then multiplicated by 100
%to convert the values to percent. Finally, the result is filtered with a
%high-band pass filter (butterworth).
%The second part is the deconvolution of the signal. This part is adapted
%from the ca extraction master suite from Pnevmatikakis.

%INPUT      ROImeans: mean values within the defined ROIs subtracted by
%           surrounding neuropil mean values resulting in raw fluorescence
%           traces
%           framerate: framerate of the CI video

%OUTPUT     ROImeans: resulting values for ROIs after background
%           substraction, conversion to percentage, and butterworth
%           filtering, conveying real fluorescence signal
%           cCaSignal: corrected calcium signal after deconvolution
%           spikes: spike approximation deconvoulted from the data with
%           scale matching the data (does not represent real number of spikes)
%           ts: timestamps of spikes
%           amp: amplitude of the spikes (matches the data, does not
%           represent real number of spikes)
%           NoofSpikes: number of spikes per ROI
%           Frequency: firing rate per ROI
%           Amplitude: highest amplitude change per ROI

global p

%deconvolution of the calcium signal adapted from ca extraction master GUI from 2015 Pnevmatikakis
spikes=zeros(size(ROImeans));
cCaSignal=zeros(size(ROImeans));

NoofSpikes=zeros(size(ROImeans,2),1);
ts=cell(1,size(ROImeans,2));
amp=cell(1,size(ROImeans,2));

h=waitbar(0,'Deconvoluting...');
for k=1:size(ROImeans,2)
    y=ROImeans(:,k);
    [c_oasis, s_oasis] = oasisAR2(y); %slower: [c_oasis, s_oasis] = deconvolveCa(y, 'ar1', 'constrained','optimize_b');
    s_oasis(s_oasis<p.options.spkthrs*std(c_oasis))=0; %1
    s_oasis(s_oasis~=0)=1;
    spikes(:,k)=ceil(s_oasis);
    cCaSignal(:,k)=c_oasis;
    
    %calcium signal statistics
    ts{:,k}=find(spikes(:,k)); %timestamps of spikes
    amp{:,k}=spikes(spikes(:,k)>0,k); %amplitude of spike
    %calculating total number of spikes per ROI
    NoofSpikes(k,1)=sum(spikes(:,k));
    try
        waitbar(k/size(ROImeans,2),h);
    catch
        ROImeans=[];
        cCaSignal=[];
        spikes=[];
        ts=[];
        amp=[];
        NoofSpikes=[];
        Frequency=[];
        Amplitude=[];
        return;
    end
end
%calculating firing frequency
Frequency=round(NoofSpikes./(size(ROImeans,1)/framerate),3);
%calculating highest amplitude change
Amplitude=round(reshape(max(cCaSignal),size(cCaSignal,2),1),2);
close(h);