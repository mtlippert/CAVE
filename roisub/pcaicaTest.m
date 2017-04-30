%loading sample of fluorescence signal
uiwait(msgbox('Please select sampleF.mat!'));
[fn,pn]=uigetfile('*.mat');
load([pn fn]);
%reshaping to two dimensional array: pixel x time
F1=reshape(F,size(F,1)*size(F,2),size(F,3));

%PCA
F2=pca(F1');    %alternative with different results: [Zpca, U, mu, eigVecs] = PCA(F2,150); F2 = U * Zpca + repmat(mu,1,size(Zpca,2));
%visualizing result from PCA
F2r=reshape(F2,size(F,1),size(F,2),size(F,3)-1); %reshaping into pictures over time: width x heigth x time
figure,imagesc(F2r(:,:,1));
figure,imagesc(F2r(:,:,10));

%ICA
% [Zica, W, T, mu] = fastICA(F2,150); %does not work, error: out of memory

%selecting only firt 150 dimensions, since roughly until 150 you can
%identify cells, afterwards only noise
F2s=F2(:,1:150);
[Zica, W, T, mu] = fastICA(F2s',140); %alternative: [Zica, W, T, mu] = kICA(F2s,150);
a=reshape(Zica',203,203,140);
figure;
for k=1:140,imagesc(a(:,:,k),[0 20]);title(k),pause(.2);end
% Zr = T \ W' * Zica + repmat(mu,1,size(Zica,2));


%Ghosh 2011
%we smoothed each spatial filter with a circularly symmetric gaussian filter
% (Matlab function conv2; standard deviation of 5 pixels) and then de-blurred
% the resultant with an ellipsoidal gaussian filter, with the long axis aligned
% along the medial-lateral dimension (Matlab function deconvlucy; standard
% deviations of 1 pixel and 6 pixels along the short and long axes, respectively).
% To delineate the cells' perimeters, we then thresholded the individual
% spatial filters at 20% of their maximum values.

%Mukamel 2009
% the original filter was
% smoothed by a convolution with a Gaussian kernel of 1.5 pixels (2.9 ?m) standard deviation.
% We next transformed the filter into a binary mask by applying a threshold 1.5 standard
% deviations above the mean intensity of all pixels. We used the MATLAB function bwlabel,
% which gives distinct labels to all spatially connected components within the binary mask
% To avoid excessively noisy signals, we excluded any image
% segments covering an area < 50 pixels.
% Finally, for each image segment we
% created a spatial filter filled by setting to zero the weights of all pixels outside of the connected
% region.Finally, for each image segment we
% created a spatial filter filled by setting to zero the weights of all pixels outside of the connected
% region.