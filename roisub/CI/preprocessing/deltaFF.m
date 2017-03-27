function [imddFF] = deltaFF(imd,pn,fn,align)

%deltaF/F
h=msgbox('Calculating deltaF/F... please wait!');
Fmean=mean(imd(:,:,1:100:end),3); %mean frame of whole video
imddF=bsxfun(@rdivide,bsxfun(@minus,double(imd),Fmean),Fmean); %frame minus meanframe divided by meanframe

hhh = fspecial('gaussian', 5, 5); %gaussian blur

imddFF=imfilter(imddF,hhh); %filter taken from miniscope msRun ()
close(h);

%saving deltaF video
h=msgbox('Saving progress... Program might seem unresponsive, please wait!');
filename=[pn '\' fn(1:end-4) 'dFvid.mat'];
deltaFimd=imddFF;
save(filename, 'deltaFimd','-v7.3');
%saving whether images were aligned
filename=[pn '\' fn(1:end-4) 'vidalign'];
vidalign=align;
save(filename, 'vidalign');
close(h);