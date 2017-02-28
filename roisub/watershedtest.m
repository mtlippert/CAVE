global d

images=d.imd;
images=images+abs(min(min(min(images))));
images=images./max(max(max(images)));
% figure(1),imagesc(d.mip);hold on;
h = waitbar(0,'Processing...') 
for j=2:size(images,3);
    image=images(:,:,j);
    if j>1;
        beforeimage=images(:,:,j-1);
        if isequal(image,beforeimage)==0;
            image=image-beforeimage;
            image=image+abs(min(min(image)));
            image=image./max(max(image));
        end
    end
    %making objects more round and connected
%     SE=strel('disk',2);
%     IM=imopen(image,SE);
%     IM=wiener2(imgaussfilt(imadjust(IM),2),[10 10]); %[20 20]
    [Iout,Ivar,Imean]=relnoise(image,21,0.5);
    SE=strel('square',4);
    SImean=imerode(Imean,SE);
    figure(2),imshow(SImean);
    %detecting edges
    [BW,threshOut]=edge(SImean,'Roberts');
    figure(3),imshow(BW);
    % %remove objects smaller than 10 pixels
    % BW=bwareaopen(BW,10);
    % figure,imshow(BW);
    %dilate the edges
    IM2=imdilate(BW,SE);
%     figure,imshow(IM2);
    %remove objects smaller than 20 pixels
    IM2=bwareaopen(IM2,20);
%     figure,imshow(IM2);
    %fill holes
    IM3=imfill(IM2,'holes');
%     figure,imshow(IM3);
    %filling holes at the border
    bw_a = padarray(IM3,[1 1],1,'pre');
    bw_a_filled = imfill(bw_a,'holes');
    bw_a_filled = bw_a_filled(2:end,2:end);
    bw_b = padarray(padarray(IM3,[1 0],1,'pre'),[0 1],1,'post');
    bw_b_filled = imfill(bw_b,'holes');
    bw_b_filled = bw_b_filled(2:end,1:end-1);
    bw_c = padarray(IM3,[1 1],1,'post');
    bw_c_filled = imfill(bw_c,'holes');
    bw_c_filled = bw_c_filled(1:end-1,1:end-1);
    bw_d = padarray(padarray(IM3,[1 0],1,'post'),[0 1],1,'pre');
    bw_d_filled = imfill(bw_d,'holes');
    bw_d_filled = bw_d_filled(1:end-1,2:end);
    bw_filled = bw_a_filled | bw_b_filled | bw_c_filled | bw_d_filled;
%     figure,imshow(bw_filled);
    %remove objects smaller than 40 pixels
    IM4=bwareaopen(bw_filled,40);
%     figure,imshow(IM4);
    %removing fuzzy objects from border
    seD = strel('disk',4);
    IM5 = imerode(IM4,seD);
    IM5 = imerode(IM5,seD);
    IM5 = imdilate(IM5,seD);
    figure(4),imshow(IM5);
    %recognize objects that are round
    [centers,radii,metric] = imfindcircles(IM5,[6 15],'EdgeThreshold',0.27);
%     viscircles(centers, radii,'EdgeColor','b');
    if isempty(centers)==1;
        stats = regionprops(IM5,'Area','Centroid');
        B = bwboundaries(IM5,'noholes');
        threshold = 0.5;
        % loop over the boundaries
        for k = 1:length(B)
              % obtain (X,Y) boundary coordinates corresponding to label 'k'
              boundary = B{k};
              % compute a simple estimate of the object's perimeter
              delta_sq = diff(boundary).^2;
              perimeter = sum(sqrt(sum(delta_sq,2)));
              % obtain the area calculation corresponding to label 'k'
              area = stats(k).Area;
              % compute the roundness metric
              metric(1,k) = 4*pi*area/perimeter^2;
        end
        for k=1:length(stats);
            if find(stats(k).Area>50)==1;
                if find(stats(k).Area<320)==1
                    if metric(1,k)>=threshold;
                        centers=stats(k).Centroid;
                    end
                end
            end
        end
    end
    if isempty(centers)==1;
        figure(1),imshow(image);hold on;
    else
        BW2 = bwselect(IM5,centers(:,1),centers(:,2),4);
        c=0;
        while numel(find(BW2>0))==0;
            c=c+1;
            %dilate the edges
            SE=strel('disk',1+c);
            BW2=imfill(imdilate(IM5,SE),'holes');
        end
        BW3 = bwselect(BW2,centers(:,1),centers(:,2),4);
    %     figure,imshow(BW3);

        figure(1),imshow(image);hold on;
        [B] = bwboundaries(BW3,'noholes');
        for k = 1:length(B)
           boundary = B{k};
           plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2); hold on;
        end
    end
    waitbar(j/size(images,3));
end
hold off;
close(h);

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