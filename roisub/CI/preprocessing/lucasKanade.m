function [imdC,Bvector] = lucasKanade(ROI,imd,tmp)

%Lucas Kanade algorithm to align images
transform = 'translation';
% parameters for ECC and Lucas-Kanade 
par = [];
par.levels =    2;
par.iterations = 5;
par.transform = transform;
imdC = cast(zeros(size(imd,1),size(imd,2),size(imd,3)),class(imd));
imdC(:,:,1) =  imd(:,:,1);
nframes=size(imd,3);
width=size(imd,1);
height=size(imd,2);
Bvector=zeros(2,2);
h=waitbar(0,'Aligning images');
for k=1:nframes-1
    img=ROI(:,:,k+1);
    imdd=imd(:,:,k+1);
    [LKWarp]=iat_LucasKanade(img,tmp,par);
    %biggest transform vector for cutting out middle part of the image
    if LKWarp(1,1)>Bvector(1,1)
        Bvector(1,1)=LKWarp(1,1);
    end
    if LKWarp(2,1)>Bvector(2,1)
        Bvector(2,1)=LKWarp(2,1);
    end
    if LKWarp(1,1)<Bvector(1,2)
        Bvector(1,2)=LKWarp(1,1);
    end
    if LKWarp(2,1)<Bvector(2,2)
        Bvector(2,2)=LKWarp(2,1);
    end
    % Compute the warped image and visualize the error
    [wimageLK] = iat_inverse_warping(imdd, LKWarp, par.transform, 1:height,1:width);
    wimageLK(wimageLK<1)=mean(mean(imdd));
    imdC(:,:,k+1)=wimageLK;
    try
        waitbar(k/(nframes-1),h);
    catch
        imdC=[];
        Bvector=[];
        return;
    end
end
imdC=imdC(ceil(abs(Bvector(2,2))):round(size(wimageLK,1)-floor(abs(Bvector(2,1)))),ceil(abs(Bvector(1,2))):round(size(wimageLK,2)-floor(abs(Bvector(1,1)))),:);  %cut middle of image
close(h);