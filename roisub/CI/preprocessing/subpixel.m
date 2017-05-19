function [imdC] = subpixel(ROI)
global d

%subpixel registration to align images
imgA = ROI(:,:,1);
imdC = cast(zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3)),class(d.imd));
imdC(:,:,1) = d.imd(:,:,1);
Bvector=zeros(2,2);
%aligning images to first image
h=waitbar(0,'Aligning images');
for k=1:size(d.imd,3)-1
    imgB=ROI(:,:,k+1);
    imdB=d.imd(:,:,k+1);
    [output] = dftregistration(fft2(imgA),fft2(imgB),100);
    if isempty(output)==1
        imdC(:,:,k+1)=imdB;
    else
        [wimage] = imtranslate(imdB, [output(4) output(3)],'nearest','FillValues',mean(mean(imdB)));
        imdC(:,:,k+1)=wimage;

        %biggest transform vector for cutting out middle part of the image
        if output(4)>Bvector(1,1)
            Bvector(1,1)=output(4);
        end
        if output(3)>Bvector(2,1)
            Bvector(2,1)=output(3);
        end
        if output(4)<Bvector(1,2)
            Bvector(1,2)=output(4);
        end
        if output(3)<Bvector(2,2)
            Bvector(2,2)=output(3);
        end
    end
    waitbar(k/(size(ROI,3)-1),h);
end
imdC=imdC(ceil(abs(Bvector(2,2))):round(size(wimage,1)-floor(abs(Bvector(2,1)))),ceil(abs(Bvector(1,2))):round(size(wimage,2)-floor(abs(Bvector(1,1)))),:);  %cut middle of image
close(h);