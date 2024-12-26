function [areaOfIntrest] = getAreaOfIntrest(backGround,frame)

%make filter the frame a bit to make the impact of the imperfact background
%image less
kernel = fspecial('average', [10, 10]);
backGround = imfilter(backGround, kernel, 'replicate');
frame = imfilter(frame, kernel, 'replicate');


diffResult = imabsdiff(backGround, frame);

%make the era bigger than what we found. imabsdiff will miss a lot, so we
%do some generous dilations.
binVersion = imbinarize(diffResult, 0.12);
binVersion = logical(binVersion);
noDots = bwareaopen(binVersion, 200);
areaOfIntrestWithShadows = imdilate(noDots, strel('line', 35, 45));
areaOfIntrestWithShadows = imdilate(areaOfIntrestWithShadows, strel('line', 35, -45));

%get rid of shadows
binFrameWithNoShadows = imbinarize(frame, 'adaptive', 'Sensitivity', 0.8);
areaOfIntrestWithHoles = binFrameWithNoShadows & areaOfIntrestWithShadows;

%clean it up a bit
areaOfIntrestWithPepperNoise = imfill(areaOfIntrestWithHoles, 'holes');
areaOfIntrest = bwareaopen(areaOfIntrestWithPepperNoise, 100);
end