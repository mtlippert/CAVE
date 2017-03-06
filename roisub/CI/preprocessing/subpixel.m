function [imdC] = subpixel(ROI)
global d

%subpixel registration to align images
imgA = ROI(:,:,1);
imdC = cast(zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3)),class(d.imd));
imdC(:,:,1) = d.imd(:,:,1);
%aligning images to first image
h=waitbar(0,'Aligning images');
for k=1:size(d.imd,3)-1
    imgB=ROI(:,:,k+1);
    imdB=d.imd(:,:,k+1);
    [output] = dftregistration(fft2(imgA),fft2(imgB),100);
    if isempty(output)==1
        imdC(:,:,k+1)=imdB;
    else
        [wimage] = imtranslate(imdB, [output(3) output(4)],'nearest','FillValues',mean(mean(imdB)));
        imdC(:,:,k+1)=wimage;
    end
    waitbar(k/(size(ROI,3)-1),h);
end
close(h);