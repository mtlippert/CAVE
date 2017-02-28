function [] = flatFieldCorrection
global d

H = fspecial('average',round(.08*size(d.imd,1))); %8 % blur
a=(imfilter(d.imd(:,:,1),H,'replicate')); %blur frame totally
d.imd=uint16(single(max(max(d.imd(:,:,1))))*bsxfun(@rdivide,single(d.imd),single(a)));
s=size(d.imd); %cut middle 80 % of image
d.imd=d.imd(round(.1*s(1)):round(.9*s(1)),round(.1*s(2)):round(.9*s(2)),:);