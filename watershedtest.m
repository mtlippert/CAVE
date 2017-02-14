global d
MIP=d.mip/max(max(d.mip));
% th_value=0.58;
% MIP(MIP<th_value)=0;
% figure;
% imshow(MIP);

mask = adapthisteq(MIP);
figure
imshow(mask)
background = imopen(mask,strel('disk',15));
MIP2 = mask - background;
figure,imshow(I2)
MIP3 = imadjust(MIP2);
figure,imshow(I3);
figure,imshow(im2bw(I3,0.65));
I4=im2bw(MIP3,0.65);
smallestAcceptableArea = 15;
structuringElement = strel('disk', 2);
th_clean_MIP = imclose(bwareaopen(I4,smallestAcceptableArea),structuringElement);
figure,imshow(th_clean_MIP);

hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(MIP3), hy, 'replicate');
Ix = imfilter(double(MIP3), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
figure
imshow(gradmag,[]), title('Gradient magnitude (gradmag)')

se = strel('disk', 5);
Io = imopen(MIP3, se);
figure
imshow(Io), title('Opening (Io)')

Ie = imerode(MIP3, se);
Iobr = imreconstruct(Ie, MIP3);
figure
imshow(Iobr), title('Opening-by-reconstruction (Iobr)')

Ioc = imclose(Io, se);
figure
imshow(Ioc), title('Opening-closing (Ioc)')

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
figure
imshow(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)')

fgm = imregionalmax(Iobrcbr);
figure
imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')

I2 = MIP3;
I2(fgm) = 255;
figure
imshow(I2), title('Regional maxima superimposed on original image (I2)')

se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);

fgm4 = bwareaopen(fgm3, 20);
I3 = MIP3;
I3(fgm4) = 255;
figure
imshow(I3)
title('Modified regional maxima superimposed on original image (fgm4)')

bw = imbinarize(Iobrcbr);
figure
imshow(bw), title('Thresholded opening-closing by reconstruction (bw)')

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
figure
imshow(bgm), title('Watershed ridge lines (bgm)')

gradmag2 = imimposemin(gradmag, bgm | fgm4);
L = watershed(gradmag2);

I4 = MIP3;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
figure
imshow(I4)
title('Markers and object boundaries superimposed on original image (I4)')

Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
figure
imshow(Lrgb)
title('Colored watershed label matrix (Lrgb)')

% v=0:0.01:1;
% maxROI=zeros(size(v));
% for k=1:length(v);
%     th_MIP=im2bw(MIP, v(k));
%     smallestAcceptableArea = 25;
%     structuringElement = strel('disk', 2);
%     th_clean_MIP = imclose(bwareaopen(th_MIP,smallestAcceptableArea),structuringElement);
%     D = bwdist(~th_clean_MIP);
% %     figure
% %     imshow(D,[],'InitialMagnification','fit')
% %     title('Distance transform of ~bw')
%     D = -D;
%     D(~th_clean_MIP) = -Inf;
%     L = watershed(D);
% %     rgb = label2rgb(L,'jet',[.5 .5 .5]);
% %     figure
% %     imshow(rgb,'InitialMagnification','fit')
% %     title('Watershed transform of D')
%     maxROI(k)=max(max(L));
% end
% vk=find(maxROI==round(mean(maxROI)));
% th_value=v(vk)

th_MIP=im2bw(MIP, 0.55); %th_value
smallestAcceptableArea = 15;
structuringElement = strel('disk', 2);
th_clean_MIP = imclose(bwareaopen(th_MIP,smallestAcceptableArea),structuringElement);
D = bwdist(~th_clean_MIP,'euclidean');
figure;
imshow(D,[],'InitialMagnification','fit');
title('Distance transform of ~bw');
D = -D;
D(~th_clean_MIP) = -Inf;
L = watershed(D);
rgb = label2rgb(L,'jet',[.5 .5 .5]);
figure;
imshow(rgb,'InitialMagnification','fit');
title('Watershed transform of D');