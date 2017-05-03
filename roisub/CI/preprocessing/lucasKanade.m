function [imdC,Bvector] = lucasKanade(ROI,imd)

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
Bvector=zeros(2,1);
h=waitbar(0,'Aligning images');
for k=1:nframes-1
    img=ROI(:,:,k+1);
    imdd=imd(:,:,k+1);
    [LKWarp]=iat_LucasKanade(img,tmp,par);
    %biggest transform vector for cutting out middle part of the image
    if sum(abs(LKWarp))>sum(abs(Bvector))
        Bvector=LKWarp;
    end
    % Compute the warped image and visualize the error
    [wimageLK] = iat_inverse_warping(imdd, LKWarp, par.transform, 1:height,1:width);
    wimageLK(wimageLK<1)=mean(mean(imdd));
    imdC(:,:,k+1)=wimageLK;
    waitbar(k/(nframes-1),h);
end
imdC=imdC(round(abs(Bvector(1,1))):round(size(wimageLK,1)-abs(Bvector(1,1))),round(abs(Bvector(2,1))):round(size(wimageLK,2)-abs(Bvector(2,1))),:);  %cut middle of image
close(h);