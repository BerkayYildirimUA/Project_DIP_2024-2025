


originalImage = squeeze(frames(269, :, :));

mask = roipoly(originalImage);

cutout = bsxfun(@times, originalImage, cast(mask, 'like', originalImage));

imwrite(cutout, "cutout.png")