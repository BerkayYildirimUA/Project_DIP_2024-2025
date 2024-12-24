function updatedImage = connect_pixels(image, x1, y1, x2, y2)
    % Ensure coordinates are integers
    x1 = round(x1);
    x2 = round(x2);
    y1 = round(y1);
    y2 = round(y2);
    
    % Calculate the number of steps needed for interpolation
    numSteps = max(abs(x2 - x1), abs(y2 - y1));
    
    % Generate linearly spaced points between the two coordinates
    xLine = linspace(x1, x2, numSteps);
    yLine = linspace(y1, y2, numSteps);
    
    % Ensure coordinates are within bounds of the image
    validMask = xLine > 0 & xLine <= size(image, 2) & yLine > 0 & yLine <= size(image, 1);
    xLine = xLine(validMask);
    yLine = yLine(validMask);
    
    % Convert to integer indices
    xLine = round(xLine);
    yLine = round(yLine);
    
    % Set pixels along the line to 1 using logical indexing
    linearIndices = sub2ind(size(image), yLine, xLine); % Convert (x, y) to linear indices
    updatedImage = image;
    updatedImage(linearIndices) = 1; % Set all pixels in one step

end
