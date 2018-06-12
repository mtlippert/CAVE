function [x,y] = savespot(x,y,k,thresh,imd)

% FUNCTION for applying color mask to every frame of the behavioral video.
%
% INPUT     x: X-coordinates of the center of the color spot over time.
%           y: Y-coordinates of the center of the color spot over time.
%           k: current frame number
%           thresh: threshold values of the color setting.
%           imd: behavioral video
% 
% OUTPUT    x: X-coordinates of the center of the color spot over time.
%           y: Y-coordinates of the center of the color spot over time.
%
%*********************************
% Title: SimpleColorDetectionByHue
% Author: Image Analyst
% Date: 2015
% Code version: 1.2
% Availability: https://de.mathworks.com/matlabcentral/fileexchange/28512-simplecolordetectionbyhue--
%*********************************

% Convert RGB image to HSV
hsvImage= rgb2hsv(imd);

% Now apply each color band's particular thresholds to the color band
hueMask = (hsvImage(:,:,1) >= thresh.hueThresholdLow) & (hsvImage(:,:,1) <= thresh.hueThresholdHigh);
saturationMask = (hsvImage(:,:,2) >= thresh.saturationThresholdLow) & (hsvImage(:,:,2) <= thresh.saturationThresholdHigh);
valueMask = (hsvImage(:,:,3) >= thresh.valueThresholdLow) & (hsvImage(:,:,3) <= thresh.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = thresh.smallestArea;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(imd(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* imd(:,:,1);
maskedImageG = coloredObjectsMask .* imd(:,:,2);
maskedImageB = coloredObjectsMask .* imd(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%tracing
stats=regionprops(maskedRGBImage, {'Centroid','Area'});
if ~isempty([stats.Area])
    areaArray = [stats.Area];
    [~,idx] = max(areaArray);
    c = stats(idx).Centroid;
    x(k,:) = c(1);
    y(k,:) = c(2);
else
    x(k,:) = 0;
    y(k,:) = 0;
end