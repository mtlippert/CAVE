function [imd] = faultyFrames(imd)

%FUNCTION for identifying skipped frames, black frames, or any abnormal
%frame that shows a sudden and huge change in brightness.

%INPUT      imd: calcium imaging video as 8-bit/16-bit with dimensions
%           pixel width, pixel height, number of frames.

%OUTPUT     imd: calcium imaging video corrected for faulty frames as
%           8-bit/16-bit with dimensions pixel width, pixel height, number
%           of frames.

%variable initialization
meanChange=diff(mean(mean(imd,1),2));

nframes=size(meanChange,3);
threshold=5*median(abs(meanChange)/0.6745); %threshold for detecting faulty frames, quiroga formula used

h=waitbar(0,'Eliminating faulty frames');
for k=1:nframes
    if meanChange(1,1,k) < -threshold || meanChange(1,1,k) > threshold || k==1331 || k==1332 || k==1333 || k==1334 %quiroga, if sudden change in brightness = faulty frame
        if k+1 <= nframes && (meanChange(1,1,k)~=meanChange(1,1,k+1)) %if it is the last frame
            imd(:,:,k+1)=imd(:,:,k);
        else %for all other frames
            imd(:,:,k+1)=imd(:,:,k-1);
        end
    end
    try
        waitbar(k/nframes,h);
    catch
        imd=[];
        return;
    end
end
close(h);