function [ROIsbw] = pcaica(F,mip,handles)

%FUNCTION for calculating PCA and ICA in order to automatically find ROIs
%in the calcium imaging video. First the deimencions are reduced by PCA and
%then independent components are identified by ICA. Finally those
%components are thresholded and processed to only include round objects and
%objects smaller than 500 pixels. The resulting spatial filters are the ROIs. 

%INPUT      F: delta F/F filtered calcium imaging video.
%           mip: maximum intensity projection of CI video
%           handles: input from GUI handles, specifically the axes
%           displaying the CI video

%OUTPUT     ROIsbw: resulting spatial filters each representing an
%           individual ROI.

global p

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
%selecting only first *defined* dimensions
prompt = {'Enter approximate number of desired cells:'};
dlg_title = 'Cell number';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
%if cancel was pressed
if isempty(answer)==1
    ROIsbw=[];
    return;
end

dim=str2num(cell2mat(answer));
h=msgbox('Please wait...');
%checking for enough memory
%segmenting array
mem=memory; %how much memory available
memval=struct2cell(mem); %converting to cell array to get values
memval=memval{1};
currentSize=dim*dim*size(F2,1)*8; %current needed memory, array size * 8 because it is class double that has 8 bits per element
if currentSize>memval
    segments=ceil(currentSize/memval);
    start=1;
    finish=round(dim/segments);
    increment=round(dim/segments);
    adding=0;
    for k=1:segments
        F2s=F2(:,start:finish);
        [Zica] = fastICA(F2s',increment);
        ICAmatrix=reshape(Zica',size(F,1),size(F,2),increment);
        try
            close(h);
        catch
        end

        %extracting ROIs
        ICAmatrixfilt=imgaussfilt(ICAmatrix,p.options.pigausss);
        ROIsbw=zeros(size(F,1),size(F,2),dim);

        singleFrame=mip;
        axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        
        for l=1:size(ICAmatrixfilt,3)
            %converting to numbers between 0 and 1
            ROIs=ICAmatrixfilt(:,:,l)+abs(min(min(ICAmatrixfilt(:,:,l))));
            ROIs=ROIs./max(max(ROIs));
            ROIsBW=bwareaopen(im2bw(ROIs,p.options.pibwP),p.options.pisaa);
            ROIsbw(:,:,l+adding)=bwlabel(ROIsBW);
            if sum(sum(ROIsBW))>p.options.picsize %reverses bw image if components bigger than 300 pixels
                ROIs=imcomplement(ROIs);
                ROIsBW=bwareaopen(im2bw(ROIs,p.options.pibwP),p.options.pisaa);
                ROIsbw(:,:,l+adding)=bwlabel(ROIsBW);
                B = bwboundaries(ROIsbw(:,:,l+adding));
                if sum(sum(ROIsBW))>p.options.picsize || length(B)>1
                    ROIsbw(:,:,l+adding)=zeros(size(F,1),size(F,2),1); %deleting huge ROIs or ROIs with multiple cells in one picture
                end
            end   
        end
        adding=adding+increment;
        start=finish+1;
        finish=finish+increment;
    end
else  
    F2s=F2(:,1:dim);
    [Zica] = fastICA(F2s',dim);
    ICAmatrix=reshape(Zica',size(F,1),size(F,2),dim);
    try
        close(h);
    catch
    end

    %extracting ROIs
    ICAmatrixfilt=imgaussfilt(ICAmatrix,p.options.pigausss);
    ROIsbw=zeros(size(F,1),size(F,2),dim);

    singleFrame=mip;
    axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;

    for k=1:size(ICAmatrixfilt,3)
        %converting to numbers between 0 and 1
        ROIs=ICAmatrixfilt(:,:,k)+abs(min(min(ICAmatrixfilt(:,:,k))));
        ROIs=ROIs./max(max(ROIs));
        ROIsBW=bwareaopen(im2bw(ROIs,p.options.pibwP),p.options.pisaa);
        ROIsbw(:,:,k)=bwlabel(ROIsBW);
        if sum(sum(ROIsBW))>p.options.picsize %reverses bw image if components bigger than 300 pixels
            ROIs=imcomplement(ROIs);
            ROIsBW=bwareaopen(im2bw(ROIs,p.options.pibwP),p.options.pisaa);
            ROIsbw(:,:,k)=bwlabel(ROIsBW);
            B = bwboundaries(ROIsbw(:,:,k));
            if sum(sum(ROIsBW))>p.options.picsize || length(B)>1
                ROIsbw(:,:,k)=zeros(size(F,1),size(F,2),1); %deleting huge ROIs or ROIs with multiple cells in one picture
            end
        end   
    end
end

%deleting non-round objects
for j=1:size(ROIsbw,3)
    stats = regionprops(ROIsbw(:,:,j),'Area','Centroid');
    B = bwboundaries(ROIsbw(:,:,j),'noholes');
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
        if metric<p.options.pinroT
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
                if percMover>=p.options.piolO || percNover>=p.options.piolO %if overlap of ROIs is greater than 30% it is interpreted as one ROI
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
if sum(sum(sum(ROIsbw)))==0
    msgbox('No cells found!','Attention')
    return;
else
    for j=1:size(ROIsbw,3)
        if sum(sum(ROIsbw(:,:,j)))>0
            c=c+1;
            ROIindices(c,1)=j;
        end
    end
    ROIsbw=ROIsbw(:,:,ROIindices);
end

%splitting up multiple cell detections
for j=1:size(ROIsbw,3)
    [~,ROInum]=bwlabel(ROIsbw(:,:,j));
    if ROInum>1
        CC = bwconncomp(ROIsbw(:,:,j));
        ROIseg=CC.PixelIdxList;
        ROItemp = zeros(size(ROIsbw,1),size(ROIsbw,2));
        ROItemp(ROIseg{1,1}) = 1;
        ROIsbw(:,:,j)=ROItemp;
        for jj=2:ROInum
            ROItemp = zeros(size(ROIsbw,1),size(ROIsbw,2));
            ROItemp(ROIseg{1,jj}) = 1;
            ROIsbw(:,:,size(ROIsbw,3)+1) = ROItemp;
        end
    end
end

end