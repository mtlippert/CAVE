function [imdd] = donwsampleBV(imd)

% FUNCTION for cropping the behavioral video.
%
% INPUT     imd: cropped video
%
% OUTPUT    imd: downsampled & cropped video

%downsampling
imdd = struct('cdata',zeros(size(imd(1).cdata,1),size(imd(1).cdata,2),3,'uint8'));
h=waitbar(0,'Downsampling');
for k=1:size(imd,2)
    imdd(k).cdata=imresize(imd(k).cdata,0.6);
    try
        waitbar(k/size(imd,2),h);
    catch
        imdd=[];
        return;
    end
end
close(h);