function [] = deltaFF
global d

%deltaF/F
h=msgbox('Calculating deltaF/F... please wait!');
Fmean=mean(d.imd(:,:,1:100:end),3); %mean frame of whole video
imddF=bsxfun(@rdivide,bsxfun(@minus,double(d.imd),Fmean),Fmean); %frame minus meanframe divided by meanframe

hhh = fspecial('gaussian', 5, 5); %gaussian blur

imddFF=imfilter(imddF,hhh); %filter taken from miniscope msRun ()
d.imd=imddFF;
close(h);

%saving deltaF video
h=msgbox('Saving progress... Program might seem unresponsive, please wait!');
filename=[d.pn '\' d.fn(1:end-4) 'dFvid'];
deltaFimd=d.imd;
save(filename, 'deltaFimd');
%saving whether images were aligned
filename=[d.pn '\' d.fn(1:end-4) 'vidalign'];
vidalign=d.align;
save(filename, 'vidalign');
close(h);