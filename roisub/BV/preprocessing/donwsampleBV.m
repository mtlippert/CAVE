function [] = donwsampleBV
global v

%downsampling
imd = struct('cdata',zeros(size(v.imd(1),1),size(v.imd(1),2),3,'uint8'));
h=waitbar(0,'Downsampling');
for k=1:size(v.imd,2);
    imd(k).cdata=imresize(v.imd(k).cdata,0.6);
    waitbar(k/size(v.imd,2),h);
end
v.imd=imd;
close(h);