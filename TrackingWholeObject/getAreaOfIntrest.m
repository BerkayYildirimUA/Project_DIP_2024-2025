function [areaOfIntrest] = getAreaOfIntrest(backGround,frame)
kernel = fspecial('average', [10, 10]); % Create a 10x10 averaging filter

backGround = imfilter(backGround, kernel, 'replicate'); % Apply the filter
frame = imfilter(frame, kernel, 'replicate'); % Apply the filter

diffResult = imabsdiff(backGround, frame);

% Binarize the grayscale image
binVersion = imbinarize(diffResult, 0.12);

binVersion = logical(binVersion);
noDots = bwareaopen(binVersion, 200);
areaOfIntrestWithShadows = imdilate(noDots, strel('line', 35, 45));
areaOfIntrestWithShadows = imdilate(areaOfIntrestWithShadows, strel('line', 35, -45));

binFrameWithNoShadows = imbinarize(frame, 'adaptive', 'Sensitivity', 0.8);

areaOfIntrestWithHoles = binFrameWithNoShadows & areaOfIntrestWithShadows;

areaOfIntrestWithPepperNoise = imfill(areaOfIntrestWithHoles, 'holes');

areaOfIntrest = bwareaopen(areaOfIntrestWithPepperNoise, 100);
end