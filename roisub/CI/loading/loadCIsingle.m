function [imd] = loadCIsingle(pn,fn,Files)

%defining dimensions of video
frames=size(imfinfo([pn '\' fn]),1);
x=imfinfo([pn '\' fn]);
Width=x(1).Width;
Height=x(1).Height;

% Check to see if it's an 8-bit image needed later for scaling).
fullFileName = fullfile([pn '\' fn]);
Image = imread(fullFileName,1);
if strcmpi(class(Image), 'uint8')
    % Flag for 256 gray levels.
    eightBit = true;
else
    eightBit = false;
end
imdd=double(zeros(Width,Height,frames)); %video preallocation

%putting each frame into variable 'images'
h=waitbar(0,'Loading');
for k = 1:length(Files);
    baseFileName = Files(k).name;
    fullFileName = fullfile([pn '\' baseFileName]);
    imdd(:,:,k) = imread(fullFileName);
    waitbar(k/length(Files),h);
end
%scaling images iof 16Bit
maxim=max(max(max(imdd)));
if eightBit==false
    imd=uint16(imdd./maxim*65535);
end
close(h);