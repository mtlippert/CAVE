function [imd,origCI,pre] = loadCIstack(pn,fn)

%defining dimensions of video
frames=size(imfinfo([pn '\' fn]),1);
x=imfinfo([pn '\' fn]);
Width=x(1).Width;
Height=x(1).Height;

if frames<=4500
    % Check to see if it's an 8-bit image needed later for scaling).
    fullFileName = fullfile([pn '\' fn]);
    Image = imread(fullFileName,1);
    if strcmpi(class(Image), 'uint8')
        % Flag for 256 gray levels.
        eightBit = true;
        imd=uint8(zeros(Width,Height,frames)); %video preallocation
    else
        eightBit = false;
        imd=uint16(zeros(Width,Height,frames)); %video preallocation
    end
else
    % Check to see if it's an 8-bit image needed later for scaling).
    fullFileName = fullfile([pn '\' fn]);
    Image = imread(fullFileName,1);
    if strcmpi(class(Image), 'uint8')
        % Flag for 256 gray levels.
        eightBit = true;
        imdd=uint8(zeros(Width*0.4,Height*0.4,frames)); %video preallocation
    else
        eightBit = false;
        imdd=uint16(zeros(Width*0.4,Height*0.4,frames)); %video preallocation
    end
end

if frames>4500
    %putting each frame into variable 'Images'
    h=waitbar(0,'Loading');
    for k = 1:frames
        % Read in image into an array.
        imdp = imread(fullFileName,k);
        if eightBit==false
            imddou=double(imdp);
            imd=uint16(imddou./max(max(imddou,[],2))*65535);
        end
        if frames>4500
            %Downsampling
            imdd(:,:,k)=imresize(imd,0.4);
        end
        waitbar(k/frames,h);
    end
    close(h);
    %function for eliminating faulty frames
    [imd] = faultyFrames(imdd);
    origCI=imresize(imd,0.805); %keeping this file stored as original video but resized since original video is bigger than the downsampled video
    %function for flatfield correction
    [imdd] = flatFieldCorrection(imd);
    imd=imdd;
    pre=1; %preprocessing was done
    %plotting mean change along the video
    meanChange=diff(mean(mean(imd,1),2));
    a=figure;plot(squeeze(meanChange));title('Mean brightness over frames');xlabel('Number of frames');ylabel('Brightness in uint16');
    name=('Mean Change');
    path=[pn '/',name,'.png'];
    path=regexprep(path,'\','/');
    print(a,'-dpng','-r100',path); %-depsc for vector graphic
    close(a);
else
    %putting each frame into variable 'Images'
    h=waitbar(0,'Loading');
    for k = 1:frames
        % Read in image into an array.
        imdd = imread(fullFileName,k);
        if eightBit==false
            imddou=double(imdd);
            imd(:,:,k)=uint16(imddou./max(max(imddou,[],2))*65535);
        end
        if frames>4500
            %Downsampling
            imd=imresize(imd,0.4);
        end
        waitbar(k/frames,h);
    end
    close(h);
    origCI=[];
    pre=0;
end