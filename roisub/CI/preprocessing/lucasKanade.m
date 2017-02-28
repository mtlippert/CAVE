function [imdC] = lucasKanade(ROI)
global d

%Lucas Kanade algorithm to align images
transform = 'translation';
% parameters for ECC and Lucas-Kanade 
par = [];
par.levels =    2;
par.iterations = 5;
par.transform = transform;
tmp= ROI(:,:,1);
imdC = cast(zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3)),class(d.imd));
imdC(:,:,1) =  d.imd(:,:,1);
h=waitbar(0,'Aligning images');
for k=1:size(d.imd,3)-1;
    img=ROI(:,:,k+1);
    imd=d.imd(:,:,k+1);
    [LKWarp]=iat_LucasKanade(img,tmp,par);
    % Compute the warped image and visualize the error
    [wimageLK] = iat_inverse_warping(imd, LKWarp, par.transform, 1:size(d.imd,2),1:size(d.imd,1));
%         % draw mosaic
%         LKMosaic = iat_mosaic(tmp,img,[LKWarp; 0 0 1]);
    wimageLK(wimageLK<1)=mean(mean(imd));
    imdC(:,:,k+1)=wimageLK;
    waitbar(k/(size(ROI,3)-1),h);
end
close(h);