function [imdd] = flatFieldCorrection(imd)

%FUNCTION that performs flat filed correction on the calcium imaging video.

%INPUT      imd: calcium imaging video in the format pixel width, pixel
%           height, number of frames; 8-bit or 16-bit

%OUTPUT     imdd: flat field corrected video in the format pixel width,
%           pixel height, number of frames; 8-bit or 16-bit

H = fspecial('average',round(.08*size(imd,1))); %8 % blur
a=(imfilter(imd(:,:,1),H,'replicate')); %blur frame totally
imd16=uint16(single(mean(mean(mean(imd))))*bsxfun(@rdivide,single(imd),single(a))); %max(max(imd(:,:,1)))
s=size(imd16); %cut middle 80 % of image
imdd=imd16(round(.1*s(1)):round(.9*s(1)),round(.1*s(2)):round(.9*s(2)),:);