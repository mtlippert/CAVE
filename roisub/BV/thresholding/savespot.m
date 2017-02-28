function [x,y] = savespot(x,y,k)
global v

% Convert RGB image to HSV
hsvImage= rgb2hsv(v.imd(k).cdata);

% Now apply each color band's particular thresholds to the color band
hueMask = (hsvImage(:,:,1) >= v.hueThresholdLow) & (hsvImage(:,:,1) <= v.hueThresholdHigh);
saturationMask = (hsvImage(:,:,2) >= v.saturationThresholdLow) & (hsvImage(:,:,2) <= v.saturationThresholdHigh);
valueMask = (hsvImage(:,:,3) >= v.valueThresholdLow) & (hsvImage(:,:,3) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = v.smallestArea;
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
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(1).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(1).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(1).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(1).cdata(:,:,3);
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