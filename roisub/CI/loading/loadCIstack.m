function [imd] = loadCIstack
global d

%defining dimensions of video
frames=size(imfinfo([d.pn '\' d.fn]),1);
x=imfinfo([d.pn '\' d.fn]);
Width=x(1).Width;
Height=x(1).Height;

% Check to see if it's an 8-bit image needed later for scaling).
fullFileName = fullfile([d.pn '\' d.fn]);
Image = imread(fullFileName,1);
if strcmpi(class(Image), 'uint8')
    % Flag for 256 gray levels.
    eightBit = true;
else
    eightBit = false;
end
if eightBit
    imd=uint8(zeros(Width,Height,frames)); %video preallocation
else
    imd=uint16(zeros(Width,Height,frames)); %video preallocation
end

%putting each frame into variable 'Images'
h=waitbar(0,'Loading');
for k = 1:frames;
    % Read in image into an array.
    Image = imread(fullFileName,k);
    if eightBit
        imd(:,:,k) = Image;
    else
        Imaged=double(Image);
        imd(:,:,k) =uint16(Imaged./max(max(Imaged,[],2))*65535);
    end
    waitbar(k/frames,h);
end
close(h);