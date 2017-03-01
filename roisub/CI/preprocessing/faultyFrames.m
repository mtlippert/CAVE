function [imd] = faultyFrames(imd)

%variable initialization
meanChange=diff(mean(mean(imd,1),2));

nframes=size(meanChange,3);
threshold=5*median(abs(meanChange)/0.6745);
h=waitbar(0,'Eliminating faulty frames');
for k=1:nframes;
    if meanChange(1,1,k) < -threshold || meanChange(1,1,k) > threshold; %quiroga, if sudden change in brightness = faulty frame
        if k+1 <= nframes && (meanChange(1,1,k)~=meanChange(1,1,k+1)); %if it is the last frame
            imd(:,:,k+1)=imd(:,:,k);
        else %for all other frames
            imd(:,:,k+1)=imd(:,:,k-1);
        end
    end
    waitbar(k/nframes,h);
end
close(h);