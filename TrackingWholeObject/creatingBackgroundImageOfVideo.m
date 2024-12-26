if  ~exist('processedFrames', 'var')

    [numFrames, frameHeight, frameWidth] = size(frames);

    % Apply adapthisteq to all frames
    processedFrames = arrayfun(@(idx) ...
    adapthisteq(squeeze(frames(idx, :, :)), "Distribution", "exponential"), ...
    1:numFrames, 'UniformOutput', false);

    % Reassemble into a 3D array with the same dimensions as the original
    processedFrames = reshape(cell2mat(processedFrames), frameHeight, frameWidth, numFrames);
    processedFrames = permute(processedFrames, [3, 1, 2]); % Ensure the frame index is the first dimension

end


%filter frames, only ones with a lot of movement
frameDiffs = squeeze(sum(abs(diff(processedFrames, 1, 1)), [2, 3])); % Sum of pixel differences for each frame
movementThreshold = 15000000; % number from trail and error
movingFramesIdx = find(frameDiffs > movementThreshold);
fprintf('Retained %d out of %d frames based on movement threshold.\n', length(movingFramesIdx), size(frames, 1));
filteredFrames = processedFrames(movingFramesIdx, :, :);

%make frame
medianFrame = squeeze(median(filteredFrames, 1));
medianImage = uint8(medianFrame);
outputFile = 'median_image_filtered.png';
imwrite(medianImage, outputFile);

% Display the result
imshow(medianImage);
title('Median Image of High-Movement Frames');