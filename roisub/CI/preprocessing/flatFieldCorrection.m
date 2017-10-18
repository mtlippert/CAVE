function [imdd] = flatFieldCorrection(imd)

%FUNCTION that performs flat filed correction on the calcium imaging video.

%INPUT      imd: calcium imaging video in the format pixel width, pixel
%           height, number of frames; 8-bit or 16-bit

%OUTPUT     imdd: flat field corrected video in the format pixel width,
%           pixel height, number of frames; 8-bit or 16-bit

global p

% %dorics global temporal filter
% imd2d=reshape(imd,size(imd,1)*size(imd,2),size(imd,3));
% spatialavg=mean(imd2d,1);
% globalavg=mean(spatialavg);
% corrmatrix=spatialavg./globalavg;
% imdcorr=zeros(size(imd2d));
% for k=1:size(imd,3)
%     imdcorr(:,k)=double(imd2d(:,k)).*corrmatrix(1,k);
% end
% imdr=reshape(imdcorr,size(imd,1),size(imd,2),size(imd,3));

H = fspecial('average',round(p.options.blur*size(imd,1))); %8 % blur
a=(imfilter(imd(:,:,1),H,'replicate')); %blur frame totally
imd16=uint16(single(mean(mean(mean(imd))))*bsxfun(@rdivide,single(imd),single(a))); %max(max(imd(:,:,1)))

% %moving temporal average of video
% imdt=zeros(size(imd,1),size(imd,2),size(imd,3));
% for k=1:size(imd,3)
%     if k<=p.options.movav
%         imdt(:,:,k)=mean(imd16(:,:,k:k+p.options.movav),3);
%     elseif k>=size(imd,3)-p.options.movav
%         imdt(:,:,k)=mean(imd16(:,:,k-p.options.movav:k),3);
%     else
%         imdt(:,:,k)=mean(imd16(:,:,k-p.options.movav:k+p.options.movav),3);
%     end
% end

s=size(imd16); %cut middle 80 % of image
imdd=imd16(round(.1*s(1)):round(.9*s(1)),round(.1*s(2)):round(.9*s(2)),:);