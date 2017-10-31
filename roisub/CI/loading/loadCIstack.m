function [imd,origCI,pre] = loadCIstack(pn,fn)

%FUNCTION for loading a single stack of TIFF files.

%INPUT      pathname (pn) and filename (fn)

%OUTPUT     imd: single pictures of calcium imaging video stored as 16-bit or
%           8-bit depending on the original format. The dimensions are as
%           follows: pixel width, pixel height, number of frames
%
%           origCI: contains original non processed but downsampled verison
%           of the original calcium imaging video, ONLY if file is too big
%           to load all at onces, meaning bigger than 4500 frames. The
%           video will be in 8-bit or 16-bit format depending on the
%           original format. The dimensions are as
%           follows: pixel width, pixel height, number of frames
%
%           pre: signals that preporcessing was done (value 0 = not done,
%           vlaue 1 = done). ONLY 1 if the file is too big to load all at
%           once, meaning bigger than 4500 frames.

global p

%defining dimensions of video
h=msgbox('Please wait...');
frames=size(imfinfo([pn '\' fn]),1);
x=imfinfo([pn '\' fn]);
Width=x(1).Width;
Height=x(1).Height;
try
    close(h);
catch
end

if frames<=4500 || Width<100 % if video has fewer than 4500 frames and fewer than 100 pixels in width
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
else
    % Check to see if it's an 8-bit image needed later for scaling).
    fullFileName = fullfile([pn '\' fn]);
    Image = imread(fullFileName,1);
    if strcmpi(class(Image), 'uint8')
        % Flag for 256 gray levels.
        eightBit = true;
        imdd=uint8(zeros(round(Height*p.options.dsr),round(Width*p.options.dsr),frames)); %video preallocation as downsampled version
    else
        eightBit = false;
        imdd=uint16(zeros(round(Height*p.options.dsr),round(Width*p.options.dsr),frames)); %video preallocation as downsampled version
    end
end

if frames>4500 && Width>100 %if file is bigger than 4500 frames and width is more than 100 pixels, the video will be already preprocessed to reduce size
    %putting each frame into variable 'Images'
    h=waitbar(0,'Loading');
    for k = 1:frames
        % Read in image into an array.
        imdp = imread(fullFileName,k);
        %Downsampling
        imdd(:,:,k)=imresize(imdp,p.options.dsr);
        try
            waitbar(k/frames,h);
        catch
            imd=[];
            origCI=[];
            pre=[];
            return;
        end
    end
    close(h);
    
    %ask if dust needs to be removed
    %display current image to select ROI
    singleFrame=imresize(double(imread(fullFileName,1)),p.options.dsr);
    singleFrame=singleFrame./max(max(singleFrame));
    figure,imagesc(singleFrame),colormap(gray);

    %function for removing dust
    % Construct a questdlg with two options
    choice = questdlg('Would you like to remove dust?', ...
        'Attention', ...
        'Yes','No','No');
    % Handle response
    if isempty(choice)==1
        return;
    end
    switch choice
        case 'Yes'
            close(gcf);
            %question how many
            prompt = {'How many?'};
            dlg_title = 'Amount';
            num_lines = 1;
            answer = inputdlg(prompt,dlg_title,num_lines);
            if isempty(answer)==1
                return;
            end
            amount=str2num(cell2mat(answer));
            %loop of removing specified number of dust specs
            for k=1:amount
                figure;
                %removing dust
                [imdd,~] = removeDust(singleFrame,k,imdd);
                if isempty(imdd)==1
                    return;
                end
                close(gcf);
            end
        case 'No'
            close(gcf);
    end

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
        imd(:,:,k) = imread(fullFileName,k);
        try
            waitbar(k/frames,h);
        catch
            imd=[];
            origCI=[];
            pre=[];
            return;
        end
    end
    if eightBit==false
        imddou=double(imd);
        maxVal=max(max(max(imddou,[],2)));
        hh=waitbar(0,'Converting');
        for j = 1:frames
            imd(:,:,j)=uint16((imddou(:,:,j)./maxVal).*p.options.bitconv);
            try
                waitbar(j/frames,hh);
            catch
                imd=[];
                origCI=[];
                pre=[];
                return;
            end
        end
        close(hh);
    end
    
    close(h);
    origCI=[]; %no original calcium imaging video saved
    pre=0; %not preprocessed
end