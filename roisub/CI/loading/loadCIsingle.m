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
    imd=uint8(zeros(Height,Width,frames)); %video preallocation
else
    eightBit = false;
    imd=uint16(zeros(Height,Width,frames)); %video preallocation
end

%putting each frame into variable 'images'
h=waitbar(0,'Loading');
for k = 1:length(Files)
    baseFileName = Files(k).name;
    fullFileName = fullfile([pn '\' baseFileName]);
    imdd = imread(fullFileName);
    if eightBit==false
        imddou=double(imdd);
        imd(:,:,k)=uint16(imddou./max(max(imddou,[],2))*65535);
    else
        imd(:,:,k)=imdd;
    end
    waitbar(k/length(Files),h);
end
close(h);