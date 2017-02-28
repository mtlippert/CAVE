function [] = ROIFvalues(a,b)
global d

%background
bg=cell(size(d.imd,3),1);
background=d.mask;
background(background==1)=2;
background(background==0)=1;
background(background==2)=0;
background = cast(background, class(d.imd(:,:,1)));

h=waitbar(0,'Labeling background');
for k = 1:size(d.imd,3);
    % You can only multiply integers if they are of the same type.
    bgmask = background .* d.imd(:,:,k);
    bg{k,1}=bgmask(background==1);
    waitbar(k/size(d.imd,3),h);
end
close(h);
% calculate mean grey value of ROIs in percent
d.ROImeans=zeros(size(d.ROIs,1),size(d.ROIs,2));
h=waitbar(0,'Calculating ROI values');
for k=1:size(d.ROIs,2);
    for i=1:size(d.ROIs,1);
        ROImeans=mean(d.ROIs{i,k});
        bgmean=mean(bg{i,1});
        d.ROImeans(i,k)=(ROImeans-bgmean)*100;
    end
    d.ROImeans(:,k)=filtfilt(b,a,d.ROImeans(:,k)); %high band pass filter
    waitbar(k/size(d.ROIs,2),h);
end
close(h);