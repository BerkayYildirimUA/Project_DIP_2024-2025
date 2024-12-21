function updatedImage = connect_all_points(image, xPoints, yPoints)
    
% Ensure coordinates are integers
    xPoints = round(xPoints);
    yPoints = round(yPoints);
    
    % Initialize updated image
    updatedImage = image;
    
    % Create a list of unconnected points
    points = [xPoints(:), yPoints(:)];
    numPoints = size(points, 1);
    connected = false(numPoints, 1); % Tracks whether a point is connected
    connected(1) = true; % Start with the first point connected
    
    currentPoint = points(1, :); % Start from the first point
    
    % Connect all points
    for i = 1:numPoints - 1
        % Calculate distances to all unconnected points
        unconnectedIndices = find(~connected);
        distances = sqrt((points(unconnectedIndices, 1) - currentPoint(1)).^2 + ...
                         (points(unconnectedIndices, 2) - currentPoint(2)).^2);
        
        % Find the nearest unconnected point
        [~, nearestIdx] = min(distances);
        nearestPointIdx = unconnectedIndices(nearestIdx);
        nearestPoint = points(nearestPointIdx, :);
        
        % Connect the current point to the nearest unconnected point
        updatedImage = connect_pixels(updatedImage, currentPoint(1), currentPoint(2), ...
                                       nearestPoint(1), nearestPoint(2));
        
        % Mark the nearest point as connected
        connected(nearestPointIdx) = true;
        
        % Move to the nearest point
        currentPoint = nearestPoint;
    end
    
    % Optional: Connect the last point back to the first to form a loop
    updatedImage = connect_pixels(updatedImage, currentPoint(1), currentPoint(2), ...
                                   points(1, 1), points(1, 2));
end

