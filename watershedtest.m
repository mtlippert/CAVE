global d
MIP=d.mip/max(max(d.mip));
v=0:0.01:1;
maxROI=zeros(size(v));
for k=1:length(v);
    th_MIP=im2bw(MIP, v(k));
    smallestAcceptableArea = 25;
    structuringElement = strel('disk', 2);
    th_clean_MIP = imclose(bwareaopen(th_MIP,smallestAcceptableArea),structuringElement);
    D = bwdist(~th_clean_MIP);
%     figure
%     imshow(D,[],'InitialMagnification','fit')
%     title('Distance transform of ~bw')
    D = -D;
    D(~th_clean_MIP) = -Inf;
    L = watershed(D);
%     rgb = label2rgb(L,'jet',[.5 .5 .5]);
%     figure
%     imshow(rgb,'InitialMagnification','fit')
%     title('Watershed transform of D')
    maxROI(k)=max(max(L));
end
vk=find(maxROI==round(mean(maxROI)));
th_value=v(vk)

th_MIP=im2bw(MIP, th_value);
smallestAcceptableArea = 25;
structuringElement = strel('disk', 2);
th_clean_MIP = imclose(bwareaopen(th_MIP,smallestAcceptableArea),structuringElement);
D = bwdist(~th_clean_MIP);
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