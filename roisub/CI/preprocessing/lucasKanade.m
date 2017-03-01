function [imdC] = lucasKanade(ROI,imd)

%Lucas Kanade algorithm to align images
transform = 'translation';
% parameters for ECC and Lucas-Kanade 
par = [];
par.levels =    2;
par.iterations = 5;
par.transform = transform;
tmp= ROI(:,:,1);
imdC = cast(zeros(size(imd,1),size(imd,2),size(imd,3)),class(imd));
imdC(:,:,1) =  imd(:,:,1);
nframes=size(imd,3);
width=size(imd,1);
height=size(imd,2);
h=waitbar(0,'Aligning images');
for k=1:nframes-1;
    img=ROI(:,:,k+1);
    imdd=imd(:,:,k+1);
    [LKWarp]=iat_LucasKanade(img,tmp,par);
    % Compute the warped image and visualize the error
    [wimageLK] = iat_inverse_warping(imdd, LKWarp, par.transform, 1:height,1:width);
    wimageLK(wimageLK<1)=mean(mean(imdd));
    imdC(:,:,k+1)=wimageLK;
    waitbar(k/(nframes-1),h);
end
close(h);