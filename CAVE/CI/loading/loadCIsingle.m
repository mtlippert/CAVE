function [imd] = loadCIsingle(pn,fn,Files)

%FUNCTION for loading multiple TIFF pictures as one video.

%INPUT      pathname (pn), filename (fn), and list of all files in the
%           directory (Files)

%OUTPUT     imd: single pictures of calcium imaging video stored as 16-bit or
%           8-bit depending on the original format. The dimensions are as
%           follows: pixel width, pixel height, number of frames

global p

%defining dimensions of video
h=msgbox('Please wait...');
frames=length(Files);
x=imfinfo([pn '\' fn]);
Width=x(1).Width;
Height=x(1).Height;
try
    close(h);
catch
end

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
    imd(:,:,k) = imread(fullFileName);
    try
        waitbar(k/length(Files),h);
    catch
        imd=[];
        return;
    end
end
close(h);
if eightBit==false
    imddou=double(imd);
    maxVal=max(max(max(imddou,[],2)));
    h=waitbar(0,'Converting');
    for j = 1:frames
        imd(:,:,j)=uint16((imddou(:,:,j)./maxVal).*p.options.bitconv);
        try
            waitbar(j/frames,h);
        catch
            imd=[];
            return;
        end
    end
    close(h);
end