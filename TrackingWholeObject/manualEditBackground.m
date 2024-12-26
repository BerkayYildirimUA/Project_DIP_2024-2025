% We used ChatGPT to write this code, but the method was thought up by us.
%
% The basic idea is to select a set of regions in each frame that we know 
% are the background.
% Then, a matrix with the same dimensions as the frame is created, 
% where the pixel values of the selected regions are copied over, 
% and all other values are set to -1.
% 
% At the end, we calculate the mean of all pixels, excluding the -1 values.
% This should result in a better mask.

background = imread('median_image_filtered.png');

% Define frames of interest
frameIndices = [179 229 316 532 936 949 966 971 1001 1069 1078]; % Frames to process

% Normalize the background for brightness reference
topRows = 1:30;
referenceBrightness = mean(background(topRows, :), 'all');

% Initialize a 3D matrix to store pixel values
[frameHeight, frameWidth] = size(background);
pixelData = -ones(length(frameIndices), frameHeight, frameWidth); % Set all to -1 initially

% Loop through frames and collect pixel data
for i = 1:length(frameIndices)
    % Load and normalize the current frame
    frame = squeeze(frames(frameIndices(i), :, :));
    frame = normalizeFrame(frame, referenceBrightness);

    % Allow multiple masks for each frame
    figure;
    imshow(frame, []);
    title(sprintf('Define regions for frame %d. Press Enter when done.', frameIndices(i)));
    hold on;

    % Loop for multiple masks
    while true
        mask = roipoly; % Create a binary mask
        if isempty(mask) % Break if no mask is defined
            break;
        end

        % Copy the pixel data where the mask is true
        currentFrameData = squeeze(pixelData(i, :, :)); % Extract current frame's data
        currentFrameData(mask) = frame(mask); % Update with new mask's pixel values
        pixelData(i, :, :) = currentFrameData; % Store back into 3D matrix

        % Display the mask's boundary
        boundary = bwboundaries(mask); % Find mask boundary
        for k = 1:length(boundary)
            plot(boundary{k}(:, 2), boundary{k}(:, 1), 'r', 'LineWidth', 1); % Plot boundary
        end
    end
    hold off;
    close(gcf); % Close the figure after defining all masks for this frame
end

% Calculate the mean for each pixel location
meanImage = zeros(frameHeight, frameWidth); % Initialize mean image
for row = 1:frameHeight
    for col = 1:frameWidth
        pixelValues = squeeze(pixelData(:, row, col)); % Extract pixel values for this location
        validPixels = pixelValues(pixelValues ~= -1); % Filter out -1 values
        if ~isempty(validPixels)
            meanImage(row, col) = mean(validPixels); % Compute mean of valid pixels
        else
            meanImage(row, col) = background(row, col); % Use background value if no valid pixels
        end
    end
end

% Save and display the updated background image
updatedBackground = uint8(meanImage);
imwrite(updatedBackground, 'updated_background.png');
disp('Updated background saved as "updated_background.png".');

figure;
imshow(updatedBackground, []);
title('Updated Background');

