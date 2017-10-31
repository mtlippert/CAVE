function [imdC,Bvector] = lucasKanade(ROI,imd,tmp)

%FUNCTION for aligning images with the LucasKanade algorithm.

%INPUT      ROI: in case the user selceted 'area' this is the video
%           containing only the user defined area, else it contains the
%           whole calcium imaging video
%           imd: clacium imaging video as 8bit/16-bit with dimensions pixel
%           width, pixel height, number of frames.
%           tmp: template to which the images are supposed to be aligned to.
%           In case of the user selecting 'area' this is the current frame
%           with the user defined region, otherwise each previous frame is
%           used as template

%OUTPUT     imdC: resulting video after alignment
%           Bvector: largest values that have been used for transforming
%           for each direction, these are 4 values

global p

%Lucas Kanade algorithm to align images
transform = 'translation';
% parameters for ECC and Lucas-Kanade 
par = [];
par.levels =    p.options.LClevels;
par.iterations = p.options.LCiter;
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
    if isequal(tmp,imd(:,:,1))==1 %if previous frame was selected tmp equals the first frame of imd
        [LKWarp]=iat_LucasKanade(img,imdC(:,:,k),par); %the video is aligned to the previous aligned frame imdC
    else
        [LKWarp]=iat_LucasKanade(img,tmp,par);
    end
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