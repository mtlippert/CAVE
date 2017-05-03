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


% uiwait(msgbox('Please select darkframedeep or darkframesurface respectivly to where you are recording from: deep brain or surface!'));
% [fn,pn]=uigetfile('*.tif');
% 
% %defining dimensions of video
% frames=size(imfinfo([pn '\' fn]),1);
% x=imfinfo([pn '\' fn]);
% Width=x(1).Width;
% Height=x(1).Height;
% 
% fullFileName = fullfile([pn '\' fn]);
% darkframe=uint16(zeros(Width,Height,frames));
% for k = 1:frames
%     % Read in image into an array.
%     imdp = imread(fullFileName,k);
%     imddou=double(imdp);
%     darkframe(:,:,k)=uint16(imddou./max(max(imddou,[],2))*65535);
% end
% darkframe=mean(darkframe,3); %scaling?
% darkframe=imresize(darkframe,0.4);
% % darkframe=cast(darkframe, class(imd(:,:,1)));
% 
% uiwait(msgbox('Please select flatffielddeep or flatfieldsurface respectivly to where you are recording from: deep brain or surface!'));
% [fn,pn]=uigetfile('*.tif');
% 
% %defining dimensions of video
% frames=size(imfinfo([pn '\' fn]),1);
% x=imfinfo([pn '\' fn]);
% Width=x(1).Width;
% Height=x(1).Height;
% 
% fullFileName = fullfile([pn '\' fn]);
% flatfield=uint16(zeros(Width,Height,frames));
% for k = 1:frames
%     % Read in image into an array.
%     imdp = imread(fullFileName,k);
%     imddou=double(imdp);
%     flatfield(:,:,k)=uint16(imddou./max(max(imddou,[],2))*65535);
% end
% flatfield=mean(flatfield,3); %scaling?
% flatfield=imresize(flatfield,0.4);
% % flatfield=cast(flatfield, class(imd(:,:,1)));
% 
% %flatfield correction
% imdd=double(zeros(size(imd,1),size(imd,2),size(imd,3)));
% h=waitbar(0,'Correcting...');
% for k = 1:size(imd,3)
%     B=double(imd(:,:,k))-darkframe;
%     m=mean(mean(flatfield))-mean(mean(darkframe));
%     I=flatfield-darkframe;
%     G=m./I;
%     imdd(:,:,k)=B.*G;
%     waitbar(k/size(imd,3),h);
% end
% close(h);