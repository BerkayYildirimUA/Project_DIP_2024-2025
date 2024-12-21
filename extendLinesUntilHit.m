function result = extendLinesUntilHit(binaryMask, lines, numIterations, gapThreshold)
% EXTENDLINESUNTILHIT Extends lines in a binary mask until they hit another 1 or the boundary.
% 
%   resultMask = extendLinesUntilHit(binaryMask, lines, numIterations, gapThreshold)
% 
% INPUTS:
%   binaryMask    - Binary mask (logical matrix) where lines are extended.
%   lines         - Struct array of lines from `houghlines`, containing `point1` and `point2`.
%   numIterations - Number of iterations to run the line extension process.
%   gapThreshold  - Minimum number of consecutive black pixels before starting to extend the line.
% 
% OUTPUT:
%   result    - Binary mask with extended lines combined with the input binary mask.

    % Create a blank binary image to draw the extended lines
    extendedLinesImage = false(size(binaryMask));
    temp = binaryMask;

    % Iterate the line extension process
    for iter = 1:numIterations
        % Temporary storage for new lines added in this iteration
        newLinesImage = false(size(binaryMask));

        % Loop through each detected line
        for k = 1:length(lines)
            % Extract the endpoints of the line
            point1 = lines(k).point1;
            point2 = lines(k).point2;

            x1 = point1(1); y1 = point1(2);
            x2 = point2(1); y2 = point2(2);

            % Calculate the direction vector of the line
            dx = x2 - x1;
            dy = y2 - y1;
            normFactor = sqrt(dx^2 + dy^2);
            dirX = dx / normFactor; % Unit vector in x-direction
            dirY = dy / normFactor; % Unit vector in y-direction

            % Step forward until hitting another `1` or leaving bounds
            currentX = x1; currentY = y1;
            gapCount = 0; % Counter for consecutive black pixels
            tempPixels = []; % Temporary storage for black pixels in the gap
            while true
                % Move forward along the line
                currentX = currentX + dirX;
                currentY = currentY + dirY;

                % Round to nearest pixel
                pixelX = round(currentX);
                pixelY = round(currentY);

                % Stop if out of bounds
                if pixelX < 1 || pixelX > size(binaryMask, 2) || ...
                   pixelY < 1 || pixelY > size(binaryMask, 1)
                    break;
                end

                % Check if the current pixel is white or black
                if binaryMask(pixelY, pixelX) || extendedLinesImage(pixelY, pixelX)
                    % If it's white, reset the gap counter and add gap pixels
                    if gapCount >= gapThreshold
                        for p = 1:size(tempPixels, 1)
                            newLinesImage(tempPixels(p, 2), tempPixels(p, 1)) = true;
                        end
                    end
                    break;
                else
                    % If it's black, increment the gap counter and store the pixel
                    gapCount = gapCount + 1;
                    tempPixels = [tempPixels; pixelX, pixelY];
                end
            end

            % Repeat the same process for the backward direction
            currentX = x1; currentY = y1;
            gapCount = 0; % Reset gap counter
            tempPixels = []; % Reset temporary storage for black pixels
            while true
                % Move backward along the line
                currentX = currentX - dirX;
                currentY = currentY - dirY;

                % Round to nearest pixel
                pixelX = round(currentX);
                pixelY = round(currentY);

                % Stop if out of bounds
                if pixelX < 1 || pixelX > size(binaryMask, 2) || ...
                   pixelY < 1 || pixelY > size(binaryMask, 1)
                    break;
                end

                % Check if the current pixel is white or black
                if binaryMask(pixelY, pixelX) || extendedLinesImage(pixelY, pixelX)
                    % If it's white, reset the gap counter and add gap pixels
                    if gapCount >= gapThreshold
                        for p = 1:size(tempPixels, 1)
                            newLinesImage(tempPixels(p, 2), tempPixels(p, 1)) = true;
                        end
                    end
                    break;
                else
                    % If it's black, increment the gap counter and store the pixel
                    gapCount = gapCount + 1;
                    tempPixels = [tempPixels; pixelX, pixelY];
                end
            end
        end

        % Update the extendedLinesImage to include the new lines
        extendedLinesImage = extendedLinesImage | newLinesImage;

        % Update the binaryMask to include the new lines (if needed for subsequent iterations)
        binaryMask = binaryMask | extendedLinesImage;
    end

    % Combine the extended lines with the original binary mask
    result = (binaryMask | extendedLinesImage) & ~temp;
end
