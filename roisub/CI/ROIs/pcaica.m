function [ROIsbw] = pcaica(F)

%FUNCTION for calculating PCA and ICA in order to automatically find ROIs
%in the calcium imaging video. First the deimencions are reduced by PCA and
%then independent components are identified by ICA. Finally those
%components are thresholded and processed to only include round objects and
%objects smaller than 1000 pixels. The resulting spatial filters are the ROIs. 

%INPUT      F: delta F/F filtered calcium imaging video.

%OUTPUT     ROIsbw: resulting spatial filters each representing an
%           individual ROI.

h=msgbox('Please wait...');
%reshaping to two dimensional array: pixel x time
F1=reshape(F,size(F,1)*size(F,2),size(F,3));

%PCA
F2=pca(F1');
try
    close(h);
catch
end

%ICA
%selecting only first 150 dimensions
prompt = {'Enter approximate number of desired cells:'};
dlg_title = 'Cell number';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
dim=str2num(cell2mat(answer));
h=msgbox('Please wait...');
F2s=F2(:,1:dim);
[Zica] = fastICA(F2s',dim);
ICAmatrix=reshape(Zica',size(F,1),size(F,2),dim);
try
    close(h);
catch
end
%extracting ROIs
ICAmatrixfilt=imgaussfilt(ICAmatrix,1.5); %or sigma=5
ROIsbw=zeros(size(F,1),size(F,2),dim);
smallestAcceptableArea=30;

singleFrame=d.mip;
if d.dF==1 || d.pre==1
    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
else
    axes(handles.axes1); imshow(singleFrame); hold on;
end

for k=1:size(ICAmatrixfilt,3)
    %converting to numbers between 0 and 1
    ROIs=ICAmatrixfilt(:,:,k)+abs(min(min(ICAmatrixfilt(:,:,k))));
    ROIs=ROIs./max(max(ROIs));
    ROIsBW=bwareaopen(im2bw(ROIs,0.8),smallestAcceptableArea);
    ROIsbw(:,:,k)=bwlabel(ROIsBW);
    if sum(sum(ROIsBW))>1000
        ROIs=imcomplement(ROIs);
        ROIsBW=bwareaopen(im2bw(ROIs,0.8),smallestAcceptableArea);
        ROIsbw(:,:,k)=bwlabel(ROIsBW);
        B = bwboundaries(ROIsbw(:,:,k));
        if sum(sum(ROIsBW))>1000 || length(B)>1
            ROIsbw(:,:,k)=zeros(size(F,1),size(F,2),1); %deleting huge ROIs or ROIs with multiple cells in one picture
        end
    end   
end

%deleting non-round objects
for j=1:size(ROIsbw,3)
    stats = regionprops(ROIsbw(:,:,j),'Area','Centroid');
    B = bwboundaries(ROIsbw(:,:,j),'noholes');
    threshold = 0.5;
    if isempty(B)==0
        % obtain (X,Y) boundary coordinates
        boundary = B{1,1};
        % compute a simple estimate of the object's perimeter
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2)));
        % obtain the area calculation corresponding to label 'k'
        area = stats(1).Area;
        % compute the roundness metric
        metric= 4*pi*area/perimeter^2;
        if metric<threshold;
            ROIsbw(:,:,j)=zeros(size(F,1),size(F,2),1);
        end
    end
end

%deleting the double assignments
for m=1:size(ROIsbw,3)
    sumM=sum(sum(ROIsbw(:,:,m)));
    for n=1:size(ROIsbw,3)
        if m~=n
            sumN=sum(sum(ROIsbw(:,:,n)));
            ROIboth=ROIsbw(:,:,m)+ROIsbw(:,:,n);
            overlay=numel(find(ROIboth==2));
            if overlay>0
                percMover=overlay/sumM*100;
                percNover=overlay/sumN*100;
                if percMover>=70 || percNover>=70 %if overlap of ROIs is greater than 70% it is interpreted as one ROI
                    ROIboth(ROIboth>1)=1;
                    ROIsbw(:,:,m)=ROIboth;
                    ROIsbw(:,:,n)=zeros(size(F,1),size(F,2),1);
                end
            end
        end
    end
end

%determining indices where there are ROIs
c=0;
for j=1:size(ROIsbw,3)
    if sum(sum(ROIsbw(:,:,j)))>0
        c=c+1;
        ROIindices(c,1)=j;
    end
end
ROIsbw=ROIsbw(:,:,ROIindices);

end