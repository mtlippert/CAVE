function [imd] = faultyFrames(imd)
global d

%variable initialization
meanChange=diff(mean(mean(d.imd,1),2));

h=waitbar(0,'Eliminating faulty frames');
for k=1:size(meanChange,3);
    if meanChange(1,1,k)<-(5*median(abs(meanChange)/0.6745)) || meanChange(1,1,k)>5*median(abs(meanChange)/0.6745); %quiroga, if sudden change in brightness = faulty frame
        if k+1 <= size(meanChange,3) && (meanChange(1,1,k)~=meanChange(1,1,k+1)); %if it is the last frame
            imd(:,:,k+1)=imd(:,:,k);
        else %for all other frames
            imd(:,:,k+1)=imd(:,:,k-1);
        end
    end
    waitbar(k/size(meanChange,3),h);
end
close(h);