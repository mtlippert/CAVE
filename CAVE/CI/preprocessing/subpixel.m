function [imdC,Bvector] = subpixel(ROI,imgA)

%FUNCTION for aligning images with the subpixel registration algorithm.

%INPUT      ROI: in case the user selceted 'area' this is the video
%           containing only the user defined area, else it contains the
%           whole calcium imaging video
%           imd: clacium imaging video as 8bit/16-bit with dimensions pixel
%           width, pixel height, number of frames.
%           imgA: template to which the images are supposed to be aligned to.
%           In case of the user selecting 'area' this is the current frame
%           with the user defined region, otherwise each previous frame is
%           used as template

%OUTPUT     imdC: resulting video after alignment
%           Bvector: largest values that have been used for transforming
%           for each direction, these are 4 values
%
%*********************************
% Title: efficient_subpixel_registration
% Author: Manuel Guizar Sicairos, James R. Fienup
% Date: 2016
% Code version: 1.1
% Availability: https://de.mathworks.com/matlabcentral/fileexchange/18401-efficient-subpixel-image-registration-by-cross-correlation
%*********************************

global d
global p

%subpixel registration to align images
imdC = cast(zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3)),class(d.imd));
imdC(:,:,1) = d.imd(:,:,1);
Bvector=zeros(2,2);
%aligning images to first image
h=waitbar(0,'Aligning images');
for k=1:size(d.imd,3)-1
    imgB=ROI(:,:,k+1);
    imdB=d.imd(:,:,k+1);
    if isequal(imgA,d.imd(:,:,1))==1 %if previous frame was selected imgA equals the first frame of d.imd
        [output] = dftregistration(fft2(imdC(:,:,k)),fft2(imgB),p.options.usfac); %the video is aligned to the previous aligned frame imdC
    else
        [output] = dftregistration(fft2(imgA),fft2(imgB),p.options.usfac);
    end
    if isempty(output)==1
        imdC(:,:,k+1)=imdB;
    else
        [wimage] = imtranslate(imdB, [output(4) output(3)],'nearest','FillValues',mean(mean(imdB)));
        imdC(:,:,k+1)=wimage;

        %biggest transform vector for cutting out middle part of the image
        if output(4)>Bvector(1,1)
            Bvector(1,1)=output(4);
        end
        if output(3)>Bvector(2,1)
            Bvector(2,1)=output(3);
        end
        if output(4)<Bvector(1,2)
            Bvector(1,2)=output(4);
        end
        if output(3)<Bvector(2,2)
            Bvector(2,2)=output(3);
        end
    end
    try
        waitbar(k/(size(ROI,3)-1),h);
    catch
        imdC=[];
        return;
    end
end
Bvector(Bvector==0)=1;
imdC=imdC(ceil(abs(Bvector(2,2))):round(size(wimage,1)-floor(abs(Bvector(2,1)))),ceil(abs(Bvector(1,2))):round(size(wimage,2)-floor(abs(Bvector(1,1)))),:);  %cut middle of image
close(h);