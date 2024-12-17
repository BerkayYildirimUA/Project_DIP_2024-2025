frameRange = 900:1000;

% Extract the specific frames
selectedFrames = frames(frameRange, :, :);

% Compute the median across the first dimension (frame index)
medianFrame = median(selectedFrames, 1); % Median along the frame axis

% Squeeze the resulting image to remove singleton dimensions
medianImage = squeeze(medianFrame);

% Display the median image
imshow(medianImage, []);
title('Median of Frames 900 to 1000');
