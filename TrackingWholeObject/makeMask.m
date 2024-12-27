


%originalImage = squeeze(frames(269, :, :));

originalImage = imread('cutout5.png');

%originalImage = adapthisteq(originalImage, "Distribution", "exponential");

mask = ~roipoly(originalImage);

cutout = bsxfun(@times, originalImage, cast(mask, 'like', originalImage));

imwrite(cutout, "cutout5.png")