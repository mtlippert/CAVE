function [] = cropBV(cc)
global v

%cropping frames
h=waitbar(0,'Cropping frames');
for k=1:size(v.imd,2)
    v.imd(k).cdata=v.imd(k).cdata(cc(2):cc(2)+cc(4),cc(1):cc(1)+cc(3),:);
    waitbar(k/size(v.imd,2),h);
end
v.crop=1; %signals that video was cropped
close(h);