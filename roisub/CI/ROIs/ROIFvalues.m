function [ROImeans,sp] = ROIFvalues(a,b,imd,mask,ROIs,framerate)

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

% %deconvolution of the calcium signal from suite2P Copyright (c) 2016 Marius
% %Pachitariu
% 
% % takes as input the calcium and (optionally) neuropil traces,  
% % both NT by NN (number of neurons).
% % outputs a cell array dcell containing spike times (dcell.st) and amplitudes
% % (dcell.c). dcell.B(3) is the neuropil contamination coefficient. 
% % dcell.B(2) is an estimate of the baseline. 
% 
% % specify in ops the following options, or leave empty for defaults
% %       fs = sampling rate
% %       recomputeKernel = whether to estimate kernel from data
% %       sensorTau  = timescale of sensor, if recomputeKernel = 0
% % additional options can be specified (mostly for linking with Suite2p, see below).
% 
% % the kernel should depend on timescale of sensor and imaging rate
% ops.fs = framerate;
% ops.sensorTau = 6;
% ops.recomputeKernel = 1;
% mtau = ops.fs * ops.sensorTau; 
% 
% neu = zeros(size(ROImeans));
% 
% Params = [1 1 1 2e4]; %parameters of deconvolution
% 
% % f0 = (mtau/2); % resample the initialization of the kernel to the right number of samples
% kernel = exp(-[1:ceil(5*mtau)]'/mtau);
% %
% npad        = 250;
% [NT, NN]    = size(ROImeans);
% coefNeu = .8 * ones(1,NN); % initialize neuropil subtraction coef with 0.8
% 
% caCorrected = ROImeans - bsxfun(@times, neu, coefNeu);
% 
% % if ops.recomputeKernel
% %     tlag                     = 1;
% %     [kernel, mtau]           = estimateKernel(ops, caCorrected, tlag);
% %     
% % %     [kernel, mtau, coefNeu]  = estimateKernel(ops, ca - coefNeu * neu, tlag);
% %     
% %     fprintf('Timescale determined is %4.4f samples \n', mtau);
% % end
% kernel = normc(kernel(:));
% %%
% kernelS     = repmat(kernel, 1, NN);
% dcell       = cell(NN,1);
% 
% tic
% Fsort       = my_conv2(caCorrected, ceil(ops.fs), 1);
% Fsort       = sort(Fsort, 1, 'ascend');
% baselines   = Fsort(ceil(NT/20), :);
% 
% % determine and subtract the neuropil
% F1 = caCorrected - bsxfun(@times, ones(NT,1), baselines);
% 
% % normalize signal
% sd   = 1/2 * std(F1 - my_conv2(F1, max(2, ops.fs/4), 1), [], 1);
% F1   = bsxfun(@rdivide, F1 , 1e-12 + sd);
% 
% sp = zeros(size(F1));
% 
% % run the deconvolution to get fs etc\
% parfor icell = 1:size(ROImeans,2)
%     [sp(:,icell),dcell{icell}] = ...
%         single_step_single_cell(F1(:,icell), Params, kernelS(:,icell), NT, npad,dcell{icell});
% end
% 
% % rescale baseline contribution
% for icell = 1:size(ROImeans,2)
%     dcell{icell}.c                      = dcell{icell}.c * sd(icell);
%     dcell{icell}.baseline               = baselines(icell);
%     dcell{icell}.neuropil_coefficient   = coefNeu(icell);
% end

%% alternative deconvolution of the calcium signal from ca extraction master 2015 Pnevmatikakis
col = {[0 114 178],[0 158 115], [213 94 0],[230 159 0],...
    [86 180 233], [204 121 167], [64 224 208], [240 228 66]}; % colors

y=ROImeans(:,2);

[c_oasis, s_oasis] = deconvolveCa(y, 'ar2', 'constrained','optimize_b'); 
s_oasis(s_oasis<1)=0;
s_oasis=round(s_oasis);

figure;
subplot(2,1,1);
plot(y, 'color', col{8}/255);hold on;
alpha(.7);
plot(c_oasis, '-.', 'color', col{5}/255);
axis tight;
legend('Data','OASIS');
title('True calcium signal');
ylabel('Fluor.');
subplot(2,1,2);
hold on;
plot(s_oasis, 'color', col{3}/255);
axis tight;
xlabel('Time [s]');
ylabel('Activity.');
stop;